package com.protype.vocatio.common.mediator;

import lombok.extern.log4j.Log4j2;
import org.springframework.aop.framework.Advised;
import org.springframework.aop.support.AopUtils;
import org.springframework.beans.BeansException;
import org.springframework.context.ApplicationContext;
import org.springframework.context.ApplicationContextAware;
import org.springframework.stereotype.Component;

import java.lang.annotation.Annotation;
import java.lang.invoke.MethodHandle;
import java.lang.invoke.MethodHandles;
import java.lang.reflect.Method;
import java.lang.reflect.Modifier;
import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.concurrent.ConcurrentHashMap;

import static com.protype.vocatio.common.mediator.Util.hasAnnotation;


@Log4j2
@Component
public class JMediator implements ApplicationContextAware {

    private ApplicationContext context;

    /**
     * Cache: requestType + beanClass -> invocable method
     */
    private final Map<CacheKey, BeanAndMethod> methodCache = new ConcurrentHashMap<>();

    @Override
    public void setApplicationContext(ApplicationContext ctx) throws BeansException {
        context = ctx;
    }

    private static BeanAndMethod getFirstHandler(List<BeanAndMethod> bm) {
        return bm.stream().filter(JMediator::isHandler)
                .findFirst()
                .orElseThrow(() -> new RuntimeException("No handler found!"));
    }

    static boolean isHandler(BeanAndMethod bam) {
        return hasAnnotation(bam.bean(), Handler.class);
    }

    /**
     * Obtiene la clase real del bean (si es proxy de Spring)
     */
    private static Class<?> getTargetClass(Object bean) {
        try {
            if (bean instanceof Advised advised) {
                Object targetBean = advised.getTargetSource().getTarget();
                if (targetBean != null) {
                    return targetBean.getClass();
                }
            }
            return AopUtils.getTargetClass(bean);
        } catch (Exception e) {
            return bean.getClass();
        }
    }

    /**
     * Busca un método válido en la clase y jerarquía
     */
    private static Optional<Method> findMatchingMethod(Class<?> clazz, Object parameter) {
        return Arrays.stream(clazz.getDeclaredMethods())
                .filter(m -> matches(m, parameter))
                .findFirst()
                .or(() -> Arrays.stream(clazz.getMethods())
                        .filter(m -> matches(m, parameter))
                        .findFirst());
    }

    private static boolean matches(Method method, Object parameter) {
        Class<?>[] pts = method.getParameterTypes();
        return pts.length == 1
                && IRequest.class.isAssignableFrom(pts[0])
                && pts[0].isAssignableFrom(parameter.getClass());
    }

    public <T> List<BeanAndMethod> getBeansAndMethods(IRequest<T> request, Class<? extends Annotation> annotation) {
        return context.getBeansWithAnnotation(annotation).values().stream()
                .map(bean -> resolveBeanAndMethod(request, bean))
                .filter(Optional::isPresent)
                .map(Optional::get)
                .toList();
    }

    public <T> T send(IRequest<T> request) throws Throwable {
        log.debug("Processing request: {}", request.getClass().getSimpleName());
        
        for (BeanAndMethod validators : getBeansAndMethods(request, Validator.class)) {
            try {
                validators.invoke(request);
            } catch (Throwable e) {
                log.debug("Validation of request {} failed.", request, e);
                throw e.getCause() != null ? e.getCause() : e;
            }
        }

        List<BeanAndMethod> handlers = getBeansAndMethods(request, Handler.class);
        log.debug("Found {} handlers for request {}", handlers.size(), request.getClass().getSimpleName());
        
        if (handlers.isEmpty()) {
            log.error("No handlers found for request: {}", request.getClass().getSimpleName());
            throw new RuntimeException("No handler found for request: " + request.getClass().getSimpleName());
        }
        
        BeanAndMethod bam = getFirstHandler(handlers);
        log.debug("Using handler: {} with method: {}", bam.bean().getClass().getSimpleName(), bam.method().getName());
        
        try {
            return bam.invoke(request);
        } catch (Throwable e) {
            log.error("Cannot call method {} on {}.", bam.method().getName(), bam.bean().getClass(), e);
            throw e.getCause() != null ? e.getCause() : e;
        }
    }

    /**
     * Busca o recupera del cache el BeanAndMethod
     */
    private Optional<BeanAndMethod> resolveBeanAndMethod(Object parameter, Object bean) {
        Class<?> reqClass = parameter.getClass();
        Class<?> beanClass = getTargetClass(bean);

        log.debug("Resolving method for request: {} and bean: {}", reqClass.getSimpleName(), beanClass.getSimpleName());

        CacheKey key = new CacheKey(reqClass, beanClass);

        return Optional.ofNullable(methodCache.computeIfAbsent(key, k -> {
            Optional<Method> m = findMatchingMethod(beanClass, parameter);
            if (m.isEmpty()) {
                log.debug("No matching method found for request: {} in bean: {}", reqClass.getSimpleName(), beanClass.getSimpleName());
                return null;
            }
            try {
                Method method = m.get();
                log.debug("Found method: {} in bean: {}", method.getName(), beanClass.getSimpleName());
                method.setAccessible(true); // solo una vez
                MethodHandle handle = MethodHandles.lookup().unreflect(method);
                if (!Modifier.isStatic(method.getModifiers())) {
                    handle = handle.bindTo(bean);
                }
                return new BeanAndMethod(bean, method, handle);
            } catch (IllegalAccessException e) {
                log.error("Cannot access method {} on {}", m.get(), beanClass, e);
                return null;
            }
        }));
    }

    /**
     * Estructura para clave de cache
     */
    private record CacheKey(Class<?> requestType, Class<?> beanClass) {
    }

    /**
     * Bean + método ya resuelto con MethodHandle
     */
    public record BeanAndMethod(Object bean, Method method, MethodHandle handle) {

        @SuppressWarnings("unchecked")
        <T> T invoke(IRequest<?> request) throws Throwable {
            // El handle ya está ligado al bean si es de instancia; si es estático no lo necesita
            return (T) handle.invoke(request);
        }
    }
}
