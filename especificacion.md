# Especificación del frontend para Sistema Experto de Recomendación de Carreras

## 1. Objetivo del sistema

El sistema es una aplicación web de orientación vocacional preliminar que recomienda carreras universitarias genéricas a partir de una entrevista adaptativa.

No debe presentarse como un reemplazo de una orientación vocacional profesional. Su propósito es orientar de forma inicial, explicable y basada en reglas.

El sistema recomienda un ranking de carreras ordenadas de mayor a menor porcentaje de afinidad. El resultado final muestra un Top 5 de carreras y una explicación de por qué cada carrera fue recomendada, basada en reglas positivas activadas por las respuestas del usuario.

---

## 2. Arquitectura general

La aplicación está compuesta por tres capas principales:

```text
React Frontend
↓
Java Backend
↓
Motor Experto en Prolog
```

### 2.1 React Frontend

Responsabilidades:

- Mostrar la pregunta actual.
- Mostrar una escala de respuesta del 1 al 5.
- Enviar cada respuesta al backend.
- Mostrar progreso de la entrevista.
- Mostrar el ranking final de carreras.
- Mostrar el resumen explicativo de cada carrera recomendada.
- No decidir qué pregunta sigue.
- No calcular afinidades.
- No aplicar reglas vocacionales.

El frontend funciona como interfaz visual. La lógica experta pertenece a Prolog.

### 2.2 Java Backend

Responsabilidades:

- Crear y mantener una sesión de entrevista.
- Guardar las respuestas acumuladas del usuario.
- Enviar las respuestas acumuladas al motor Prolog.
- Recibir desde Prolog la próxima pregunta o el ranking final.
- Convertir los términos Prolog a JSON.
- Exponer endpoints HTTP para el frontend.

Java actúa como intermediario entre React y Prolog.

### 2.3 Prolog

Responsabilidades:

- Contener la base de conocimiento del sistema experto.
- Definir preguntas, áreas, carreras y reglas.
- Decidir cuál es la próxima pregunta en base a las respuestas previas.
- Calcular puntajes y porcentajes de afinidad.
- Generar el ranking final Top 5.
- Generar las explicaciones de las carreras recomendadas.

Prolog es el motor experto. La entrevista es adaptativa porque Prolog decide dinámicamente la próxima pregunta.

---

## 3. Concepto central: entrevista adaptativa

El sistema no usa un cuestionario fijo. La próxima pregunta depende de las respuestas anteriores.

Después de cada respuesta, Prolog realiza este proceso:

1. Recibe todas las respuestas acumuladas.
2. Valida que las respuestas sean correctas.
3. Recalcula la afinidad por áreas.
4. Recalcula la afinidad por carreras.
5. Determina qué áreas parecen más prometedoras.
6. Decide qué pregunta conviene hacer después.
7. Si todavía falta información, devuelve una nueva pregunta.
8. Si ya hay información suficiente, devuelve el ranking final.

Ejemplo:

```text
Usuario responde alto en tecnología y matemática:
→ Prolog prioriza preguntas sobre programación, datos, software y resolución de errores.

Usuario responde bajo en tecnología y alto en salud/personas:
→ Prolog evita profundizar en tecnología y prioriza salud, pacientes, biología, empatía, etc.

Usuario responde alto en creatividad y comunicación:
→ Prolog prioriza diseño, comunicación visual, redacción y medios.
```

---

## 4. Carreras incluidas

El sistema trabaja con 12 carreras genéricas:

1. Ingeniería en Sistemas
2. Tecnicatura en Programación
3. Ciencia de Datos
4. Medicina
5. Enfermería
6. Psicología
7. Derecho
8. Contador Público
9. Administración de Empresas
10. Diseño Gráfico
11. Arquitectura
12. Comunicación Social

El resultado final debe mostrar solo carreras, no materias/asignaturas.

---

## 5. Áreas evaluadas

El sistema organiza las preguntas y reglas en áreas vocacionales:

- Tecnología
- Salud
- Social
- Economía
- Arte y diseño
- Comunicación
- Leyes
- Investigación

Estas áreas no son necesariamente el resultado final. Sirven para guiar la entrevista adaptativa y decidir qué preguntas hacer.

---

## 6. Escala de respuestas

Cada pregunta se responde con una escala de 1 a 5.

```text
1 = muy bajo / nada
2 = bajo
3 = medio / neutral
4 = alto
5 = muy alto
```

Recomendación para la interfaz:

- Usar botones grandes del 1 al 5.
- Mostrar etiquetas textuales debajo o al lado de la escala.
- Permitir cambiar la respuesta antes de continuar, si todavía no fue enviada.
- Una vez enviada, el backend actualiza la sesión y devuelve la próxima pregunta.

Ejemplo visual sugerido:

```text
¿Cuánto te interesa la tecnología, las computadoras o el mundo digital?

[1] Nada
[2] Poco
[3] Medio
[4] Bastante
[5] Mucho
```

---

## 7. Formato lógico de respuestas en Prolog

Internamente, Prolog espera respuestas con este formato:

```prolog
r(IdPregunta, Valor)
```

Ejemplo:

```prolog
[
  r(q_interes_tecnologia, 5),
  r(q_interes_salud, 1),
  r(q_matematica_logica, 4)
]
```

El frontend no necesita usar este formato directamente. React debería trabajar con JSON y el backend Java debería convertir JSON a términos Prolog.

---

## 8. Formato recomendado para requests del frontend

### 8.1 Iniciar entrevista

Endpoint sugerido:

```http
POST /api/interview/start
```

No requiere body o puede recibir metadata opcional.

Respuesta esperada:

```json
{
  "status": "question",
  "sessionId": "abc123",
  "question": {
    "id": "q_interes_tecnologia",
    "text": "Cuanto te interesa la tecnologia, las computadoras o el mundo digital?",
    "area": "tecnologia",
    "type": "general"
  },
  "progress": {
    "answered": 0,
    "minQuestions": 8,
    "maxQuestions": 15
  }
}
```

### 8.2 Responder pregunta

Endpoint sugerido:

```http
POST /api/interview/{sessionId}/answer
```

Body:

```json
{
  "questionId": "q_interes_tecnologia",
  "value": 5
}
```

Respuesta si hay nueva pregunta:

```json
{
  "status": "question",
  "question": {
    "id": "q_matematica_logica",
    "text": "Que tan comodo te sentis con la matematica, la logica o los problemas abstractos?",
    "area": "tecnologia",
    "type": "general"
  },
  "progress": {
    "answered": 1,
    "minQuestions": 8,
    "maxQuestions": 15
  }
}
```

Respuesta si finaliza:

```json
{
  "status": "finished",
  "ranking": [
    {
      "careerId": "ingenieria_sistemas",
      "careerName": "Ingenieria en Sistemas",
      "percentage": 86,
      "summary": "Se recomienda Ingenieria en Sistemas porque: muestra interes en tecnologia; se siente comodo con logica, matematica y abstraccion; le interesa programar y construir soluciones con software.",
      "activatedRules": [
        {
          "id": "r_sis_tecnologia",
          "description": "muestra interes en tecnologia",
          "score": 10
        },
        {
          "id": "r_sis_logica",
          "description": "se siente comodo con logica, matematica y abstraccion",
          "score": 10
        },
        {
          "id": "r_sis_programacion",
          "description": "le interesa programar y construir soluciones con software",
          "score": 10
        }
      ]
    }
  ],
  "progress": {
    "answered": 12,
    "minQuestions": 8,
    "maxQuestions": 15
  }
}
```

---

## 9. Estados posibles de la entrevista

El frontend debe contemplar al menos estos estados:

### 9.1 Loading

Mientras se inicia la entrevista o se espera respuesta del backend.

### 9.2 Question

Cuando el backend devuelve una pregunta.

Campos esperados:

```json
{
  "status": "question",
  "question": {
    "id": "q_interes_tecnologia",
    "text": "Pregunta...",
    "area": "tecnologia",
    "type": "general"
  }
}
```

### 9.3 Finished

Cuando el backend devuelve el ranking final.

Campos esperados:

```json
{
  "status": "finished",
  "ranking": []
}
```

### 9.4 Error

Cuando el backend detecta un problema.

Ejemplo:

```json
{
  "status": "error",
  "message": "Respuesta invalida. El valor debe estar entre 1 y 5."
}
```

---

## 10. Predicado principal de Prolog

El backend Java debería consultar siempre el mismo predicado principal:

```prolog
estado_sesion(Respuestas, Estado).
```

Donde:

- `Respuestas` es la lista acumulada de respuestas.
- `Estado` es la decisión del sistema experto.

Posibles valores de Estado:

```prolog
preguntar(pregunta(Id, Texto, Area, Tipo))
```

o:

```prolog
finalizar(RankingTop5)
```

o:

```prolog
error(respuestas_invalidas)
```

Ejemplo:

```prolog
estado_sesion([
  r(q_interes_tecnologia, 5),
  r(q_interes_salud, 1)
], Estado).
```

---

## 11. Lógica de puntajes

Cada carrera tiene reglas asociadas. Cada regla conecta una carrera con una pregunta y un peso.

Ejemplo conceptual:

```prolog
regla(r_sis_tecnologia, ingenieria_sistemas, q_interes_tecnologia, 5,
      'muestra interes en tecnologia').
```

La respuesta se transforma en puntos así:

```text
Valor 5 → suma fuerte
Valor 4 → suma leve
Valor 3 → neutral
Valor 2 → resta leve
Valor 1 → resta fuerte
```

Fórmula usada:

```text
contribución = (valorRespuesta - 3) * peso
```

Ejemplo:

```text
Pregunta: interés en tecnología
Peso para Ingeniería en Sistemas: 5
Respuesta del usuario: 5

contribución = (5 - 3) * 5 = 10
```

Si el usuario responde 1:

```text
contribución = (1 - 3) * 5 = -10
```

Las respuestas bajas no descartan carreras de forma absoluta. Solo restan puntos.

---

## 12. Porcentaje de afinidad

El sistema normaliza los puntos obtenidos a un porcentaje entre 0 y 100.

La afinidad representa qué tan compatible es una carrera con las respuestas del usuario.

El frontend debe mostrar el porcentaje como un indicador visual claro.

Ejemplos:

```text
Ingeniería en Sistemas — 86%
Ciencia de Datos — 78%
Tecnicatura en Programación — 73%
Administración de Empresas — 58%
Comunicación Social — 52%
```

Sugerencias visuales:

- Barra de progreso por carrera.
- Porcentaje destacado.
- Orden descendente.
- Top 5 claramente numerado.

---

## 13. Reglas activadas

Cada carrera recomendada incluye reglas positivas activadas.

Una regla activada es una regla cuya contribución fue positiva. Es decir, una respuesta del usuario favoreció esa carrera.

Ejemplo:

```json
{
  "id": "r_sis_programacion",
  "description": "le interesa programar y construir soluciones con software",
  "score": 10
}
```

El frontend puede mostrar estas reglas como explicación detallada.

Sugerencia:

```text
¿Por qué se recomienda?
- Muestra interés en tecnología.
- Se siente cómodo con lógica, matemática y abstracción.
- Le interesa programar y construir soluciones con software.
```

---

## 14. Resumen explicativo

Cada carrera del ranking trae un resumen textual generado por Prolog.

Ejemplo:

```text
Se recomienda Ingeniería en Sistemas porque: muestra interés en tecnología; se siente cómodo con lógica, matemática y abstracción; le interesa programar y construir soluciones con software.
```

El frontend debería mostrar este resumen debajo de cada carrera, especialmente para las primeras posiciones.

---

## 15. Criterios de finalización

La entrevista debe tener:

- mínimo 8 preguntas;
- máximo 15 preguntas.

El sistema puede finalizar antes de llegar a 15 si se cumplen estas condiciones:

- ya se hicieron al menos 8 preguntas;
- la mejor carrera tiene al menos 75% de afinidad;
- la diferencia entre la primera y la segunda carrera es de al menos 15 puntos porcentuales.

Si no se cumple esa condición, continúa preguntando hasta llegar al máximo de 15 preguntas.

---

## 16. Progreso de entrevista

El frontend debería mostrar algún indicador de progreso.

Importante: como la entrevista es adaptativa, no siempre se sabe exactamente cuántas preguntas faltan.

Se recomienda mostrar algo como:

```text
Pregunta 5 de hasta 15
```

o:

```text
Respondidas: 5 / máximo 15
```

También se puede mostrar:

```text
El sistema necesita al menos 8 respuestas para generar una recomendación confiable.
```

---

## 17. Preguntas del sistema

Las preguntas tienen esta estructura lógica:

```json
{
  "id": "q_interes_tecnologia",
  "text": "Cuanto te interesa la tecnologia, las computadoras o el mundo digital?",
  "area": "tecnologia",
  "type": "general"
}
```

Campos:

- `id`: identificador único de pregunta.
- `text`: texto mostrado al usuario.
- `area`: área vocacional asociada.
- `type`: puede ser `"general"` o `"specific"`/`"especifica"`.

El frontend no debe asumir un orden fijo de preguntas. Debe renderizar la pregunta que devuelva el backend.

---

## 18. Lista de preguntas disponibles

### Preguntas generales

- `q_interes_tecnologia`: interés en tecnología, computadoras o mundo digital.
- `q_interes_salud`: interés en salud, cuerpo humano o cuidado de personas.
- `q_interes_personas`: interés en trabajar con personas.
- `q_creatividad_visual`: interés en creatividad, diseño y estética.
- `q_economia_gestion`: interés en economía, gestión, empresas o negocios.
- `q_comunicacion`: interés en comunicar ideas, escribir o hablar.
- `q_matematica_logica`: comodidad con matemática, lógica o abstracción.
- `q_lectura_teoria`: gusto por lectura, teoría y textos complejos.
- `q_leyes_normas`: interés en leyes, normas, justicia o derechos.
- `q_investigacion`: interés en investigar y analizar información.
- `q_trabajo_equipo`: gusto por trabajo en equipo.
- `q_salida_laboral`: importancia de salida laboral rápida o concreta.

### Preguntas específicas de tecnología

- `q_programacion`
- `q_datos_estadistica`
- `q_software_apps`
- `q_resolver_errores`

### Preguntas específicas de salud

- `q_biologia_cuerpo`
- `q_cuidado_pacientes`
- `q_contextos_clinicos`
- `q_estudio_largo`

### Preguntas específicas sociales

- `q_escucha_empatia`
- `q_comportamiento_humano`
- `q_acompanar_personas`

### Preguntas específicas de economía

- `q_numeros_finanzas`
- `q_organizacion_empresas`
- `q_toma_decisiones_negocios`

### Preguntas específicas de arte y diseño

- `q_diseno_visual`
- `q_espacios_objetos`
- `q_creacion_multimedia`

### Preguntas específicas de comunicación

- `q_redaccion`
- `q_medios_sociales`
- `q_presentar_ideas`

### Preguntas específicas de leyes

- `q_argumentacion_debate`
- `q_conflictos_normas`

### Preguntas específicas de investigación

- `q_experimentos_hipotesis`
- `q_analisis_datos`

---

## 19. Recomendaciones para diseño de interfaz

### Pantalla inicial

Debe explicar brevemente:

```text
Este sistema experto te hará algunas preguntas sobre intereses, habilidades y preferencias. 
Con tus respuestas generará un ranking de carreras compatibles y explicará por qué las recomienda.
```

Debe aclarar:

```text
No reemplaza una orientación vocacional profesional. Es una herramienta de exploración inicial.
```

Botón sugerido:

```text
Comenzar entrevista
```

### Pantalla de pregunta

Elementos:

- Número de pregunta o progreso.
- Texto de la pregunta.
- Escala 1 a 5.
- Botón continuar.
- Texto de ayuda sobre la escala.
- Opcional: área de la pregunta.

Ejemplo:

```text
Pregunta 4 de hasta 15

¿Cuánto te interesa trabajar con personas y comprender sus necesidades?

1 Nada | 2 Poco | 3 Medio | 4 Bastante | 5 Mucho

[Continuar]
```

### Pantalla de resultados

Elementos:

- Título: "Carreras recomendadas"
- Texto breve: "Estas son las carreras con mayor afinidad según tus respuestas."
- Ranking Top 5.
- Porcentaje de afinidad.
- Resumen explicativo.
- Reglas activadas, visibles como detalle desplegable.
- Botón para reiniciar entrevista.

Ejemplo:

```text
1. Ingeniería en Sistemas — 86%
Se recomienda porque mostrás interés en tecnología, lógica y programación.

Ver reglas activadas
- r_sis_tecnologia: muestra interés en tecnología.
- r_sis_logica: se siente cómodo con lógica y matemática.
- r_sis_programacion: le interesa programar.
```

---

## 20. Recomendaciones UX

- Evitar mostrar demasiada información técnica durante la entrevista.
- Mostrar el detalle de reglas recién en los resultados.
- Usar lenguaje claro y no determinista.
- Evitar frases como "deberías estudiar X".
- Preferir frases como:
  - "La carrera más compatible es..."
  - "El sistema encontró afinidad con..."
  - "Podrías considerar..."
- Permitir reiniciar la entrevista.
- Opcionalmente permitir descargar o copiar resultados.
- Mostrar un aviso si el ranking está muy parejo:
  - "Las primeras opciones tienen afinidades similares; conviene revisar más de una alternativa."

---

## 21. Consideraciones importantes para la IA que cree el frontend

La IA que implemente el frontend debe respetar estas reglas:

1. No hardcodear el orden de preguntas.
2. No calcular el ranking en React.
3. No decidir qué pregunta sigue en React.
4. Renderizar exactamente la pregunta que devuelva el backend.
5. Tratar el flujo como una entrevista adaptativa.
6. Manejar dos estados principales: `question` y `finished`.
7. Mostrar escala de 1 a 5.
8. Mostrar Top 5 al finalizar.
9. Mostrar explicación de cada carrera.
10. Mostrar reglas activadas como detalle opcional.
11. No mostrar carreras descartadas.
12. No mostrar materias/asignaturas.
13. No presentar el resultado como diagnóstico definitivo.

---

## 22. Contrato de datos sugerido para TypeScript

```ts
export type InterviewStatus = "question" | "finished" | "error";

export type QuestionType = "general" | "especifica";

export interface InterviewQuestion {
  id: string;
  text: string;
  area: string;
  type: QuestionType;
}

export interface ActivatedRule {
  id: string;
  description: string;
  score: number;
}

export interface CareerResult {
  careerId: string;
  careerName: string;
  percentage: number;
  summary: string;
  activatedRules: ActivatedRule[];
}

export interface InterviewProgress {
  answered: number;
  minQuestions: number;
  maxQuestions: number;
}

export interface QuestionResponse {
  status: "question";
  sessionId?: string;
  question: InterviewQuestion;
  progress: InterviewProgress;
}

export interface FinishedResponse {
  status: "finished";
  ranking: CareerResult[];
  progress: InterviewProgress;
}

export interface ErrorResponse {
  status: "error";
  message: string;
}

export type InterviewResponse =
  | QuestionResponse
  | FinishedResponse
  | ErrorResponse;
```

---

## 23. Ejemplo de flujo completo

### Inicio

Frontend:

```http
POST /api/interview/start
```

Backend responde:

```json
{
  "status": "question",
  "sessionId": "abc123",
  "question": {
    "id": "q_interes_tecnologia",
    "text": "Cuanto te interesa la tecnologia, las computadoras o el mundo digital?",
    "area": "tecnologia",
    "type": "general"
  },
  "progress": {
    "answered": 0,
    "minQuestions": 8,
    "maxQuestions": 15
  }
}
```

### Usuario responde

Frontend:

```http
POST /api/interview/abc123/answer
```

Body:

```json
{
  "questionId": "q_interes_tecnologia",
  "value": 5
}
```

Backend consulta a Prolog:

```prolog
estado_sesion([r(q_interes_tecnologia, 5)], Estado).
```

Prolog devuelve otra pregunta.

### Finalización

Después de varias respuestas, Prolog devuelve:

```prolog
finalizar(RankingTop5)
```

Backend transforma eso a JSON:

```json
{
  "status": "finished",
  "ranking": [
    {
      "careerId": "ingenieria_sistemas",
      "careerName": "Ingenieria en Sistemas",
      "percentage": 86,
      "summary": "Se recomienda Ingenieria en Sistemas porque: muestra interes en tecnologia; se siente comodo con logica, matematica y abstraccion; le interesa programar y construir soluciones con software.",
      "activatedRules": [
        {
          "id": "r_sis_tecnologia",
          "description": "muestra interes en tecnologia",
          "score": 10
        }
      ]
    }
  ],
  "progress": {
    "answered": 12,
    "minQuestions": 8,
    "maxQuestions": 15
  }
}
```

---

## 24. Resumen breve para implementación

Construir una interfaz web para una entrevista adaptativa de recomendación de carreras.

El frontend debe:

- iniciar entrevista;
- mostrar preguntas devueltas por backend;
- permitir responder con escala 1 a 5;
- enviar respuestas;
- esperar que backend devuelva nueva pregunta o ranking final;
- mostrar ranking Top 5 con porcentaje, resumen y reglas activadas.

El frontend no debe contener reglas vocacionales ni lógica de decisión. Toda la inteligencia está en Prolog. Java solo actúa como backend intermediario y gestor de sesión.

---

## 25. Tono recomendado de la interfaz

El tono debería ser claro, amable y orientativo.

Evitar:

```text
Tenés que estudiar Ingeniería en Sistemas.
```

Preferir:

```text
Según tus respuestas, Ingeniería en Sistemas aparece como una de las opciones con mayor afinidad.
```

Evitar:

```text
No servís para Medicina.
```

Preferir no mostrar explicaciones negativas, ya que el sistema solo debe mostrar el "por qué sí".

---

## 26. Posibles componentes React

Componentes sugeridos:

```text
InterviewStart
QuestionCard
RatingScale
ProgressIndicator
ResultsRanking
CareerResultCard
ActivatedRulesList
RestartInterviewButton
LoadingState
ErrorState
```

### QuestionCard

Props sugeridas:

```ts
interface QuestionCardProps {
  question: InterviewQuestion;
  progress: InterviewProgress;
  onSubmit: (questionId: string, value: number) => void;
  loading?: boolean;
}
```

### RatingScale

Props sugeridas:

```ts
interface RatingScaleProps {
  value: number | null;
  onChange: (value: number) => void;
}
```

### CareerResultCard

Props sugeridas:

```ts
interface CareerResultCardProps {
  rank: number;
  result: CareerResult;
}
```

---

## 27. Validaciones del frontend

El frontend debe validar:

- que se haya seleccionado un valor antes de continuar;
- que el valor esté entre 1 y 5;
- que exista una pregunta activa;
- que no se envíe dos veces la misma respuesta por doble click;
- que se maneje correctamente el estado loading.

La validación fuerte debe estar también en backend/Prolog.

---

## 28. Consideraciones visuales

Ideas de interfaz:

- Diseño tipo wizard.
- Fondo limpio.
- Una pregunta por pantalla.
- Escala clara y accesible.
- Resultados con tarjetas.
- Barras de afinidad.
- Detalles desplegables para reglas activadas.
- Botón para reiniciar.

No conviene mostrar todas las preguntas de golpe, porque contradice la lógica adaptativa.

---

## 29. Definición final del sistema

El sistema es un motor experto vocacional adaptativo. Su conocimiento está expresado mediante reglas Prolog con pesos. Cada respuesta del usuario modifica los puntajes de áreas y carreras. En función de esos puntajes, Prolog selecciona la siguiente pregunta más relevante. Al finalizar, el sistema devuelve un ranking Top 5 de carreras con porcentaje de afinidad y justificación basada en reglas positivas activadas.

El frontend debe limitarse a representar visualmente este proceso de entrevista y resultados.
