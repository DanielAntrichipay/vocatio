# 🎓 Vocatio — Sistema Experto de Orientación Vocacional

Sistema experto de orientación vocacional que recomienda carreras universitarias a través de una **entrevista adaptativa impulsada por inteligencia artificial basada en reglas (Prolog)**.

El motor de inferencia evalúa las respuestas del usuario en tiempo real, descarta preguntas irrelevantes, profundiza en áreas de interés y genera un ranking personalizado de carreras con explicaciones transparentes.

---

## 📋 Tabla de Contenidos

- [Arquitectura](#-arquitectura)
- [Tecnologías](#-tecnologías)
- [Requisitos Previos](#-requisitos-previos)
- [Instalación](#-instalación)
- [Ejecución](#-ejecución)
- [API](#-api)
- [Estructura del Proyecto](#-estructura-del-proyecto)

---

## 🏗 Arquitectura

```
┌──────────────┐     HTTP/JSON     ┌──────────────────┐      JPL/JNI      ┌─────────────────┐
│   Frontend   │ ◄──────────────►  │  Spring Boot 4   │ ◄──────────────►  │   SWI-Prolog    │
│   (React)    │                   │  (Java 25)       │                   │ Motor Experto   │
└──────────────┘                   └──────────────────┘                   └─────────────────┘
                                          │
                                   Vertical Slice
                                    Architecture
```

El backend sigue una **Vertical Slice Architecture (VSA)** estricta donde cada funcionalidad es un slice independiente con sus propias capas: `Controller → Handler → Request/Response → Validator`.

La comunicación con Prolog se realiza mediante **JPL (Java Prolog Library)**, un puente bidireccional que conecta la JVM con el motor SWI-Prolog a través de JNI.

---

## 🛠 Tecnologías

| Componente | Tecnología |
|-----------|-----------|
| Backend | Java 25, Spring Boot 4.0.7 |
| Motor Experto | SWI-Prolog 9.x |
| Puente Java↔Prolog | JPL (Java Prolog Library) |
| Documentación API | Swagger / OpenAPI 3.0 |
| Build | Maven |

---

## 📦 Requisitos Previos

- **Java JDK 25** (OpenJDK)
- **SWI-Prolog** con bindings de Java (JPL)
- **Maven** (incluido via wrapper `./mvnw`)

---

## 🐳 Docker

Si no querés instalar Java ni SWI-Prolog localmente, podés levantar el proyecto con Docker:

```bash
docker build -t vocatio .
docker run -p 8080:8080 vocatio
```

La imagen incluye JDK 25, SWI-Prolog y JPL. No requiere ninguna dependencia en el host.

---

## 🚀 Instalación (sin Docker)

### 1. Clonar el repositorio

```bash
git clone https://github.com/DanielAntrichipay/vocatio.git
cd vocatio
```

### 2. Instalar SWI-Prolog y JPL

#### Fedora / RHEL

```bash
sudo dnf install swi-prolog-core swi-prolog-java java-25-openjdk-devel
```

#### Ubuntu / Debian

```bash
sudo apt install swi-prolog swi-prolog-java openjdk-25-jdk
```

### 3. Verificar instalación

```bash
# Verificar SWI-Prolog
swipl --version

# Verificar Java 25
/usr/lib/jvm/java-25-openjdk/bin/java -version

# Verificar que libjpl.so existe
find /usr/lib64 -name "libjpl.so" 2>/dev/null
```

---

## ▶ Ejecución

```bash
JAVA_HOME=/usr/lib/jvm/java-25-openjdk \
LD_LIBRARY_PATH=/usr/lib64/swipl/lib/x86_64-linux/ \
./mvnw spring-boot:run
```

Una vez que veas en la consola:

```
Started VocatioApplication in X.XXX seconds
```

El servidor estará escuchando en **<http://localhost:8080>**.

### Swagger UI

Documentación interactiva disponible en: **<http://localhost:8080/swagger-ui.html>**

## 📡 API

### Iniciar Entrevista

```bash
curl -X POST http://localhost:8080/api/interview/start \
  -H "Content-Type: application/json"
```

**Respuesta (201):**

```json
{
  "sessionId": "85dd3db6-71cb-43da-aa3e-caf9b8911012",
  "status": "question",
  "question": {
    "id": "q_interes_tecnologia",
    "text": "Cuanto te interesa la tecnologia, las computadoras o el mundo digital?",
    "area": "tecnologia",
    "type": "general"
  }
}
```

### Responder una Pregunta

```bash
curl -X POST http://localhost:8080/api/interview/{sessionId}/answer \
  -H "Content-Type: application/json" \
  -d '{
    "questionId": "q_interes_tecnologia",
    "value": 5
  }'
```

El valor va de **1** (nada de interés) a **5** (mucho interés).

**Respuesta — Siguiente pregunta:**

```json
{
  "status": "question",
  "question": { "id": "q_programacion", "text": "...", "area": "tecnologia", "type": "especifica" },
  "progress": { "answered": 1, "minQuestions": 8, "maxQuestions": 15 }
}
```

**Respuesta — Resultado final:**

```json
{
  "status": "finished",
  "progress": { "answered": 15, "minQuestions": 8, "maxQuestions": 15 },
  "ranking": [
    {
      "careerId": "ingenieria_sistemas",
      "careerName": "Ingenieria en Sistemas",
      "percentage": 82,
      "summary": "Se recomienda porque: muestra interes en tecnologia...",
      "activatedRules": [
        { "id": "r_sis_tecnologia", "description": "muestra interes en tecnologia", "score": 10 }
      ]
    }
  ]
}
```

> 📄 Para la documentación completa de la API ver [`flujo-sistema.md`](flujo-sistema.md).

---

## 📁 Estructura del Proyecto

```
vocatio/
├── sistema_experto.pl                    # Base de conocimiento Prolog
├── lib/jpl.jar                           # Librería JPL (system scope)
├── pom.xml                               # Configuración Maven
├── src/main/java/com/protype/vocatio/
│   ├── VocatioApplication.java           # Punto de entrada
│   ├── ExceptionController.java          # Manejo global de errores
│   ├── common/
│   │   ├── entities/                     # Entidades del dominio
│   │   │   ├── Answer.java               #   Respuesta del usuario
│   │   │   ├── Question.java             #   Pregunta del sistema
│   │   │   ├── Result.java               #   Resultado (carrera + score)
│   │   │   └── ActivatedRule.java        #   Regla activada
│   │   ├── enums/
│   │   │   └── InterviewStatus.java      #   QUESTION | FINISHED
│   │   ├── exceptions/                   # Excepciones personalizadas
│   │   └── mediator/                     # Patrón Mediator (JMediator)
│   └── interview/                        # Feature: Entrevista
│       ├── PrologEngine.java             #   Puente con SWI-Prolog
│       ├── InterviewSessionRepository.java  # Sesiones en memoria
│       ├── start/                        #   Slice: Iniciar entrevista
│       │   ├── StartInterviewController.java
│       │   ├── StartInterviewHandler.java
│       │   ├── StartInterviewRequest.java
│       │   └── StartInterviewResponse.java
│       └── answer/                       #   Slice: Responder pregunta
│           ├── AnswerInterviewController.java
│           ├── AnswerInterviewHandler.java
│           ├── AnswerInterviewRequest.java
│           ├── AnswerInterviewResponse.java
│           ├── AnswerInterviewValidator.java
│           └── ProgressDTO.java
├── especificacion.md                     # Especificación del frontend
├── flujo-sistema.md                      # Documentación del flujo API
└── spec.md                               # Especificación del sistema
```

---

## ⚠ Notas Importantes

- Las sesiones se almacenan **en memoria**. Se pierden al reiniciar el servidor.
- El número de preguntas varía entre **8 y 15** según las respuestas del usuario.
- Prolog adapta las preguntas dinámicamente descartando ramas irrelevantes.
- Este sistema **no reemplaza** una orientación vocacional profesional. Es una herramienta de orientación inicial.

---

## 👥 Autores

- Daniel Antrichipay.
- Franco Cabeza.
- Tomas Acosta.

---

## 📄 Licencia

Este proyecto es parte de un trabajo académico.
