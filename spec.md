# Contexto del Negocio: Sistema Experto Vocacional
Vocatio es un sistema experto de orientación vocacional cuyo núcleo de inferencia está desarrollado en Prolog. Su objetivo es inferir qué carreras universitarias se adaptan mejor a los gustos, habilidades e intereses del usuario mediante una entrevista dinámica y adaptativa.

A diferencia de un formulario estático o un cuestionario tradicional basado en sumatorias de base de datos, Vocatio utiliza Prolog para evaluar lógicamente cada respuesta (valor numérico) en tiempo real. Esto permite que el sistema descarte caminos o preguntas que se alejan de las preferencias demostradas por el usuario y, en su lugar, priorice y seleccione nuevas preguntas que profundicen en las áreas de mayor afinidad (por ejemplo, si el usuario muestra rechazo a la biología, el sistema descartará ramas médicas y enfocará la entrevista en otras áreas).

Flujo de la Entrevista (Motor de Inferencia)
El ciclo de interacción entre el Frontend (React), el Backend (Java) y el Motor de Inferencia (Prolog) sigue un flujo de "ida y vuelta" que se divide arquitectónicamente en dos etapas funcionales principales (Slices):

Iteración de Preguntas y Respuestas (Slice: Interview)

El usuario inicia la sesión y recibe una pregunta inicial.
El usuario responde a la pregunta con un valor numérico (ej. escala del 1 al 5) y envía la respuesta al backend.
El backend recopila el historial de respuestas de la sesión actual y se lo envía a Prolog.
Prolog procesa los hechos, poda el árbol de decisiones (descartando preguntas irrelevantes) y determina la siguiente mejor pregunta a realizar.
El backend devuelve esta nueva pregunta al usuario, repitiendo el ciclo.
Resolución y Recomendación Final (Slice: Recommendation / Result)

Cuando Prolog determina que ha recopilado suficiente información (alcanzando un límite de preguntas o un umbral de certeza alto sobre una carrera), el ciclo de iteración se rompe.
Prolog deja de devolver preguntas y en su lugar emite un veredicto de finalización.
El backend procesa este estado y devuelve al frontend una lista estructurada con las carreras más afines (Top 5).
Esta respuesta final incluye el nombre de la carrera, el porcentaje de afinidad calculado, un resumen explicativo y el detalle de las reglas lógicas (respuestas específicas) que sumaron puntos para llegar a esa conclusión.



# Constitución del Proyecto — Vocatio

> **Versión:** 1.0  
> **Última actualización:** 2026-04-24  
> **Alcance:** Este documento define los principios, restricciones y estándares **no negociables** que rigen el
> desarrollo del backend de *Vocatio*. Todo contribuyente (humano o IA) debe cumplirlos sin excepción.

---

## 1. Estándares Tecnológicos

### 1.1 Stack Aprobado

| Capa              | Tecnología                                                | Versión Mínima   | Estado     |
|-------------------|-----------------------------------------------------------|------------------|------------|
| **Lenguaje**      | Java (LTS)                                                | 21               | ✅ Aprobado |
| **Framework**     | Spring Boot                                               | 4.0.x            | ✅ Aprobado |
| **Documentación** | SpringDoc OpenAPI (`springdoc-openapi-starter-webmvc-ui`) | 3.0.x            | ✅ Aprobado |
| **Mapping**       | MapStruct                                                 | 1.6.x            | ✅ Aprobado |
| **Boilerplate**   | Lombok                                                    | (heredada de SB) | ✅ Aprobado |
| **Build**         | Apache Maven (Maven Wrapper)                              | —                | ✅ Aprobado |

### 1.2 Tecnologías Prohibidas

| Tecnología                                         | Motivo                                                                   |
|----------------------------------------------------|--------------------------------------------------------------------------|
| Gradle                                             | El proyecto utiliza Maven exclusivamente.                                |
| Bases de datos NoSQL                               | El dominio es relacional; toda persistencia debe ser vía JPA/PostgreSQL. |
| Spring WebFlux / Reactor                           | La arquitectura es bloqueante (Spring MVC). No mezclar modelos.          |
| Dependencias con `@Deprecated` en SB 4             | Verificar siempre compatibilidad con Spring Boot 4.0.x.                  |
| Frameworks de testing alternativos (TestNG, Spock) | Se usa JUnit 5 + Spring Boot Test exclusivamente.                        |

### 1.3 Versiones y Actualizaciones

- **Java:** Solo se permiten versiones LTS (actualmente 21). No se permite usar preview features en producción.
- **Spring Boot:** Mantenerse dentro de la línea `4.0.x`. Las actualizaciones de versión mayor requieren revisión
  arquitectónica formal.
- **Dependencias externas:** Toda nueva dependencia debe justificarse y verificar compatibilidad con Spring Boot 4.0.x
  antes de incluirse en el `pom.xml`.

---

## 2. Arquitectura de Software

### 2.1 Patrón Arquitectónico: Vertical Slice Architecture

El proyecto sigue **Vertical Slice Architecture**, donde cada funcionalidad (slice) se organiza de forma autónoma dentro
de su contexto de dominio.

```
com.poc.ventanillaunicadelibredeuda/
├── common/                          # Infraestructura transversal
│   ├── config/                      # Configuración global (Security, CORS, Swagger)
│   ├── entities/                    # Entidades base
│   ├── enums/                       # Enumeraciones de dominio
│   ├── exceptions/                  # Excepciones personalizadas
│   ├── mediator/                    # Motor JMediator (Handler, Validator, IRequest)
│   └── utils/                       # Utilidades (UserLogged, YmlProperties)
├── <contexto-dominio>/             # Ej: user, area, deuda, ciudadano
│   ├── <funcionalidad>/            # Ej: create, findAll, softDelete
│   │   ├── *Request.java           # Implementa IRequest<T>
│   │   ├── *Response.java          # DTO de respuesta❌
│   │   ├── *Handler.java           # Anotado con @Handler
│   │   ├── *Validator.java         # Anotado con @Validator (si aplica)
│   │   └── *Controller.java        # Endpoint REST (si aplica)
│   └── <otra-funcionalidad>/
└── VentanillaUnicaDeLibreDeudaApplication.java
```

#### Reglas de Estructura

1. **Un slice, una responsabilidad:** Cada paquete de slice contiene exclusivamente la lógica de una sola operación
   (crear, listar, eliminar, etc.).
2. **Sin dependencias laterales entre slices:** Los slices del mismo contexto NO deben importarse entre sí. Si se
   necesita lógica compartida, esta pertenece al paquete `common` o al nivel del contexto de dominio.
3. **Paquetes en minúsculas:** Todos los paquetes Java deben seguir la convención `lowercase` sin excepciones.

### 2.2 Patrón Mediator (JMediator)

El desacoplamiento entre controladores y lógica de negocio se logra mediante `JMediator`, un mediador personalizado.

#### Contrato Obligatorio

| Componente    | Interfaz/Anotación | Responsabilidad                                    |
|---------------|--------------------|----------------------------------------------------|
| **Request**   | `IRequest<T>`      | DTO que porta los datos de entrada                 |
| **Handler**   | `@Handler`         | Ejecuta la lógica de negocio principal             |
| **Validator** | `@Validator`       | Valida la request **antes** de ejecutar el handler |

#### Reglas del Mediator

- **PROHIBIDO modificar `JMediator`** salvo que exista un defecto crítico documentado. Es infraestructura estable.
- Cada `Handler` debe aceptar exactamente **un parámetro** de tipo `IRequest<T>`.
- Los `Validator` se ejecutan automáticamente **antes** del `Handler` para la misma `IRequest`.
- Los `Handler` y `Validator` son registrados como Spring Beans automáticamente (las anotaciones incluyen `@Component`).

---

### 3 Reglas de Seguridad No Negociables

#### Reglas de Secretos

- **PROHIBIDO** hardcodear credenciales, tokens, claves privadas o URLs de producción en el código fuente.
- Toda configuración sensible debe extraerse a variables de entorno referenciadas desde `application.yaml`.
- El archivo `.env` está excluido del control de versiones. Se provee `.env.example` como plantilla.
- Antes de cada commit, verificar que no se filtren secretos.

---

## 4. Rendimiento y Escalabilidad

1. **Cache del Mediator:** `JMediator` mantiene un `ConcurrentHashMap` como cache de resolución de métodos. No
   invalidar ni manipular este cache externamente.
2. **Proyecciones:** Para endpoints de solo lectura con muchos campos, preferir proyecciones DTO (vía MapStruct)
   sobre devolver entidades completas.
3. **Logging:** Usar niveles de log apropiados:
    - `DEBUG` para flujo del mediator y resolución de beans.
    - `INFO` para eventos de negocio relevantes.
    - `ERROR` para excepciones no recuperables.
    - **PROHIBIDO** loguear datos sensibles (tokens, contraseñas, datos personales).

---

## 5. Estándares de Código

### 5.1 Convenciones de Nomenclatura

| Elemento                | Convención                                                 | Ejemplo                                   |
|-------------------------|------------------------------------------------------------|-------------------------------------------|
| Paquetes                | `lowercase` sin separadores                                | `com.poc.ventanillaunicadelibredeuda`     |
| Clases                  | `PascalCase`                                               | `CiudadanoHandler`, `DeudaValidator`      |
| Métodos/Variables       | `camelCase`                                                | `findByCiudadanoId`, `estadoDeDeuda`      |
| Constantes              | `UPPER_SNAKE_CASE`                                         | `MAX_RETRY_COUNT`                         |
| Enums                   | `PascalCase` para el tipo, `UPPER_SNAKE_CASE` para valores | `EstadoDeDeuda.ACTIVA`                    |
| DTOs (Request/Response) | `PascalCase` con sufijo                                    | `CreateCiudadanoRequest`, `DeudaResponse` |

### 5.2 Uso de Lombok

- **Obligatorio en entidades y DTOs:** `@Getter`, `@Setter` como mínimo.
- **Recomendado:** `@Builder` para DTOs de respuesta y requests complejas.
- **Logs:** Usar `@Log4j2` para inyección de logger.

### 5.3 Documentación OpenAPI

**Es obligatorio documentar con anotaciones de OpenAPI:**

- **Controllers:** `@Tag`, `@Operation`, `@ApiResponse` en cada endpoint.
- **Requests:** `@Schema` con `description` en cada campo del DTO de entrada.
- **Responses:** `@Schema` con `description` en cada campo del DTO de salida.

Ejemplo mínimo:

```java

@Tag(name = "Ciudadanos", description = "Operaciones sobre ciudadanos")
@RestController
@RequestMapping("/api/ciudadanos")
public class CiudadanoController {

    @Operation(summary = "Crear un ciudadano")
    @ApiResponse(responseCode = "201", description = "Ciudadano creado exitosamente")
    @PostMapping
    public ResponseEntity<CiudadanoResponse> create(@RequestBody CreateCiudadanoRequest request) { ...}
}
```

### 5.4 Manejo de Errores

- **Formato:** Todas las respuestas de error deben seguir **RFC 7807** (`ProblemDetail`).
- **Centralización:** Todo manejo de excepciones debe pasar por `ExceptionController` (`@RestControllerAdvice`).
- **Jerarquía de excepciones del proyecto:**

```
RuntimeException
├── BadRequestException          → HTTP 400
│   └── EntityNotFoundException  → HTTP 400 (entidad no encontrada)
└── ForbiddenException           → HTTP 403 (sin permisos)
```

- **Prohibido:** Lanzar excepciones genéricas (`Exception`, `RuntimeException`) desde la lógica de negocio. Siempre
  usar las excepciones tipadas del proyecto.
- **Prohibido:** Retornar mensajes de error en formato libre (strings sueltos). Siempre retornar `ProblemDetail`.

### 5.5 MapStruct

- Usar `@Mapper(componentModel = "spring")` para que los mappers sean beans de Spring.
- Un mapper por contexto de dominio (ej. `CiudadanoMapper`, `DeudaMapper`).
- **Prohibido** hacer mapping manual (con builders) cuando la conversión es directa. Delegar a MapStruct.

### 5.6 Testing

- **Framework:** JUnit 5 + Spring Boot Test.
- **Anotaciones de test:**
  - `@SpringBootTest` para tests de integración.
  - `@WebMvcTest` para tests de controllers (capa web aislada).
  - `@DataJpaTest` para tests de repositorios.
- **Nombrado de tests:** Método de prueba debe describir el escenario:
  `shouldReturnBadRequest_whenDniIsEmpty()`.

---

## 6. Cumplimiento y Gobernanza

### 6.1 Control de Versiones (Git)

| Aspecto                | Estándar                                                            |
|------------------------|---------------------------------------------------------------------|
| **Plataforma**         | GitLab                                                              |
| **Rama principal**     | `main`                                                              |
| **Rama de desarrollo** | `develop`                                                           |
| **Ramas de features**  | `feature/<nombre-descriptivo>` (ej. `feature/users`)                |
| **Commits**            | Mensajes descriptivos en español; un commit = un cambio lógico      |
| **Archivos excluidos** | Todo secreto, artefacto de build, y archivo de IDE vía `.gitignore` |

---

## 7. Directrices para Agentes de IA

### 7.1 Lo que SÍ hacer

- ✅ Seguir la estructura de Vertical Slice al crear nuevas funcionalidades.
- ✅ Crear `Request`, `Handler`, `Validator`, `Response` y `Controller` para cada nuevo slice.
- ✅ Documentar con OpenAPI todo endpoint, request y response nuevo.
- ✅ Validar que nuevos endpoints requieran autenticación revisando `WebSecurityConfig`.
- ✅ Usar las excepciones tipadas del proyecto (`BadRequestException`, `EntityNotFoundException`, etc.).
- ✅ Verificar la compilación con `./mvnw clean install` después de cambios significativos.
- ✅ Agregar `@SQLRestriction("enabled = true")` en toda nueva entidad.

### 7.2 Lo que NO hacer

- ❌ **NO** modificar el motor de `JMediator` salvo defectos críticos.
- ❌ **NO** refactorizar código existente que no esté relacionado con la tarea actual.
- ❌ **NO** cambiar la versión de Spring Boot sin autorización explícita.
- ❌ **NO** agregar dependencias sin verificar compatibilidad con SB 4.0.x.
- ❌ **NO** hardcodear valores de configuración (URLs, credenciales, client-ids).
- ❌ **NO** usar `FetchType.EAGER` en relaciones JPA.
- ❌ **NO** exponer entidades JPA directamente en las respuestas de la API.
- ❌ **NO** crear endpoints públicos sin justificación documentada.
- ❌ **NO** loguear datos personales o credenciales.
- ❌ **NO** Modificar este documento.

---

## 8. Comandos de Referencia

| Comando                  | Descripción                                            |
|--------------------------|--------------------------------------------------------|
| `./mvnw clean install`   | Compilar y ejecutar todos los tests                    |
| `./mvnw test`            | Ejecutar solo los tests                                |
| `./mvnw spring-boot:run` | Levantar la aplicación (con Docker Compose automático) |

---

## 9. URLs del Entorno de Desarrollo

| Servicio            | URL por defecto                         |
|---------------------|-----------------------------------------|
| API Backend         | `http://localhost:8080`                 |
| Swagger UI          | `http://localhost:8080/swagger-ui.html` |
| OpenAPI Docs        | `http://localhost:8080/api-docs`        |

---

## 10. Nomenclatura para Ramas

| **Prefijo**     | **Propósito / Cuándo usarlo**                                                           | **Ejemplo**                               |
|-----------------|-----------------------------------------------------------------------------------------|-------------------------------------------|
| **`feature/`**  | Desarrollo de una nueva funcionalidad o "vertical slice".                               | `feature/registro-usuario-social`         |
| **`fix/`**      | Corrección de un error (bug) que no es crítico para producción.                         | `fix/formato-fecha-reporte`               |
| **`hotfix/`**   | Parche urgente para un error crítico que ya está en producción.                         | `hotfix/caida-login-oauth`                |
| **`refactor/`** | Cambios en el código que no añaden funciones ni arreglan bugs.                          | `refactor/mejorar-clausula-where`         |
| **`chore/`**    | Tareas repetitivas, configuración, o actualización de librerías.                        | `chore/actualizar-dependencias-maven`     |
| **`test/`**     | Creación, edición o limpieza de pruebas unitarias o de integración.                     | `test/cobertura-servicio-pagos`           |
| **`docs/`**     | Cambios exclusivos en la documentación (Markdown, Javadoc).                             | `docs/manual-configuracion-db`            |
| **`perf/`**     | Cambios de código destinados exclusivamente a mejorar el rendimiento.                   | `perf/cache-consultas-lentas`             |
| **`ci/`**       | Cambios en archivos de configuración y scripts de CI (Jenkins, GitHub Actions).         | `ci/agregar-paso-de-escaneo-saas`         |
| **`style/`**    | Cambios estéticos que no afectan la lógica (formateo, espacios, puntos y coma).         | `style/formateo-google-java-format`       |
| **`infra/`**    | Creación de un `docker-compose.yml` para levantar tu base de datos y Keycloak en local. | `infra/setup-docker-keycloak`             |
| **`ci/`**       | Modificación del archivo `.github/workflows/deploy.yml` para automatizar el build.      | `ci/arreglar-cache-maven-pipeline`        |
| **`feature/`**  | Configuración de Spring Security y controladores para conectar con Keycloak.            | `feature/autenticacion-usuarios-keycloak` |

> **Este documento es la fuente de verdad del proyecto.** Cualquier desviación debe ser discutida y aprobada antes de
> implementarse. Las reglas marcadas como "PROHIBIDO" no admiten excepciones sin revisión formal.
