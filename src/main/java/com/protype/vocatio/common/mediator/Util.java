package com.protype.vocatio.common.mediator;

import org.springframework.aop.framework.AopProxyUtils;
import org.springframework.aop.support.AopUtils;

import java.lang.annotation.Annotation;
import java.util.Arrays;

public class Util {

    private Util() {
    }

    public static boolean hasAnnotation(Object bean, Class<? extends Annotation> annotation) {
        Class<?> targetClass = AopUtils.isAopProxy(bean) ? AopProxyUtils.ultimateTargetClass(bean) : bean.getClass();
        // Verificar si la clase real tiene la anotación
        return Arrays.stream(targetClass.getDeclaredAnnotations())
                .anyMatch(a -> a.annotationType().equals(annotation));
    }
}
