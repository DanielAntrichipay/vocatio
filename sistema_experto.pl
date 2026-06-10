% sistema_experto_carreras.pl
% Sistema experto vocacional adaptativo.
%
% Responsabilidades:
% - React: muestra preguntas y resultados.
% - Java: guarda la sesion y llama a Prolog.
% - Prolog: decide la siguiente pregunta, calcula afinidad,
%   activa reglas y genera el ranking.
%
% Escala de respuesta:
% 1 = muy bajo / nada
% 2 = bajo
% 3 = medio / neutral
% 4 = alto
% 5 = muy alto
%
% Formato de respuestas:
% r(IdPregunta, Valor)
%
% Ejemplo:
% [
%   r(q_interes_tecnologia, 5),
%   r(q_interes_salud, 1),
%   r(q_matematica_logica, 4)
% ]

:- use_module(library(lists)).

% ============================================================
% CONFIGURACION GENERAL
% ============================================================

min_preguntas(8).
max_preguntas(15).

umbral_afinidad_alta(75).
umbral_ventaja_clara(15).

% ============================================================
% AREAS
% ============================================================

area(tecnologia).
area(salud).
area(social).
area(economia).
area(arte_diseno).
area(comunicacion).
area(leyes).
area(investigacion).

% ============================================================
% CARRERAS
% ============================================================

carrera(ingenieria_sistemas).
carrera(tecnicatura_programacion).
carrera(ciencia_datos).
carrera(medicina).
carrera(enfermeria).
carrera(psicologia).
carrera(derecho).
carrera(contador_publico).
carrera(administracion_empresas).
carrera(diseno_grafico).
carrera(arquitectura).
carrera(comunicacion_social).

nombre_carrera(ingenieria_sistemas, 'Ingenieria en Sistemas').
nombre_carrera(tecnicatura_programacion, 'Tecnicatura en Programacion').
nombre_carrera(ciencia_datos, 'Ciencia de Datos').
nombre_carrera(medicina, 'Medicina').
nombre_carrera(enfermeria, 'Enfermeria').
nombre_carrera(psicologia, 'Psicologia').
nombre_carrera(derecho, 'Derecho').
nombre_carrera(contador_publico, 'Contador Publico').
nombre_carrera(administracion_empresas, 'Administracion de Empresas').
nombre_carrera(diseno_grafico, 'Diseno Grafico').
nombre_carrera(arquitectura, 'Arquitectura').
nombre_carrera(comunicacion_social, 'Comunicacion Social').

% ============================================================
% PREGUNTAS
% pregunta(Id, Tipo, Area, Texto).
%
% Tipo:
% - general: sirve para explorar areas amplias.
% - especifica: profundiza en un area prometedora.
% ============================================================

pregunta(q_interes_tecnologia, general, tecnologia,
    'Cuanto te interesa la tecnologia, las computadoras o el mundo digital?').

pregunta(q_interes_salud, general, salud,
    'Cuanto te interesa la salud, el cuerpo humano o el cuidado de personas?').

pregunta(q_interes_personas, general, social,
    'Cuanto te interesa trabajar con personas y comprender sus necesidades?').

pregunta(q_creatividad_visual, general, arte_diseno,
    'Cuanto te interesan la creatividad, el diseno, lo visual o lo estetico?').

pregunta(q_economia_gestion, general, economia,
    'Cuanto te interesan la economia, la gestion, las empresas o los negocios?').

pregunta(q_comunicacion, general, comunicacion,
    'Cuanto te interesa comunicar ideas, escribir, hablar o producir contenidos?').

pregunta(q_matematica_logica, general, tecnologia,
    'Que tan comodo te sentis con la matematica, la logica o los problemas abstractos?').

pregunta(q_lectura_teoria, general, investigacion,
    'Cuanto te gusta leer, estudiar teoria y analizar textos complejos?').

pregunta(q_leyes_normas, general, leyes,
    'Cuanto te interesan las leyes, las normas, la justicia o los derechos?').

pregunta(q_investigacion, general, investigacion,
    'Cuanto te interesa investigar, analizar informacion o buscar explicaciones profundas?').

pregunta(q_trabajo_equipo, general, social,
    'Cuanto te gusta trabajar en equipo y coordinar con otras personas?').

pregunta(q_salida_laboral, general, economia,
    'Que tan importante es para vos una salida laboral rapida o concreta?').

% Tecnologia

pregunta(q_programacion, especifica, tecnologia,
    'Cuanto te atrae programar, crear software o automatizar tareas?').

pregunta(q_datos_estadistica, especifica, tecnologia,
    'Cuanto te interesa analizar datos, patrones, estadisticas o predicciones?').

pregunta(q_software_apps, especifica, tecnologia,
    'Cuanto te gustaria construir aplicaciones, sistemas web o herramientas digitales?').

pregunta(q_resolver_errores, especifica, tecnologia,
    'Cuanto disfrutas resolver errores, probar soluciones y mejorar sistemas?').

% Salud

pregunta(q_biologia_cuerpo, especifica, salud,
    'Cuanto te interesa la biologia, el cuerpo humano o las enfermedades?').

pregunta(q_cuidado_pacientes, especifica, salud,
    'Cuanto te interesa cuidar, asistir o acompanar pacientes?').

pregunta(q_contextos_clinicos, especifica, salud,
    'Que tan comodo estarias en hospitales, clinicas o contextos de atencion sanitaria?').

pregunta(q_estudio_largo, especifica, salud,
    'Que tan dispuesto estas a estudiar una carrera larga y exigente?').

% Social

pregunta(q_escucha_empatia, especifica, social,
    'Cuanto te consideras una persona empatica y con buena escucha?').

pregunta(q_comportamiento_humano, especifica, social,
    'Cuanto te interesa comprender la conducta, las emociones o los conflictos humanos?').

pregunta(q_acompanar_personas, especifica, social,
    'Cuanto te interesa orientar, acompanar o ayudar a otras personas?').

% Economia

pregunta(q_numeros_finanzas, especifica, economia,
    'Cuanto te interesan los numeros, las finanzas, los impuestos o la contabilidad?').

pregunta(q_organizacion_empresas, especifica, economia,
    'Cuanto te interesa organizar recursos, procesos o equipos dentro de una empresa?').

pregunta(q_toma_decisiones_negocios, especifica, economia,
    'Cuanto te interesa tomar decisiones de negocio, planificar o gestionar proyectos?').

% Arte y diseno

pregunta(q_diseno_visual, especifica, arte_diseno,
    'Cuanto te interesa crear piezas visuales, marcas, interfaces o composiciones graficas?').

pregunta(q_espacios_objetos, especifica, arte_diseno,
    'Cuanto te interesa disenar espacios, edificios, objetos o ambientes?').

pregunta(q_creacion_multimedia, especifica, arte_diseno,
    'Cuanto te interesa crear contenido audiovisual, imagen, video o piezas multimedia?').

% Comunicacion

pregunta(q_redaccion, especifica, comunicacion,
    'Cuanto te gusta escribir, redactar, argumentar o contar historias?').

pregunta(q_medios_sociales, especifica, comunicacion,
    'Cuanto te interesan los medios, las redes sociales, la cultura o la opinion publica?').

pregunta(q_presentar_ideas, especifica, comunicacion,
    'Cuanto te gusta explicar, presentar o defender ideas frente a otras personas?').

% Leyes

pregunta(q_argumentacion_debate, especifica, leyes,
    'Cuanto te interesa argumentar, debatir y defender una postura?').

pregunta(q_conflictos_normas, especifica, leyes,
    'Cuanto te interesa analizar conflictos, normas, responsabilidades o derechos?').

% Investigacion

pregunta(q_experimentos_hipotesis, especifica, investigacion,
    'Cuanto te interesa formular hipotesis, comparar evidencias o investigar problemas?').

pregunta(q_analisis_datos, especifica, investigacion,
    'Cuanto te interesa transformar informacion en conclusiones utiles?').

% ============================================================
% ORDEN ESTABLE DE PREGUNTAS
% Se usa como criterio secundario si dos preguntas tienen
% puntaje adaptativo similar.
% ============================================================

orden_pregunta(q_interes_tecnologia, 10).
orden_pregunta(q_interes_salud, 20).
orden_pregunta(q_interes_personas, 30).
orden_pregunta(q_creatividad_visual, 40).
orden_pregunta(q_economia_gestion, 50).
orden_pregunta(q_comunicacion, 60).
orden_pregunta(q_matematica_logica, 70).
orden_pregunta(q_lectura_teoria, 80).
orden_pregunta(q_leyes_normas, 90).
orden_pregunta(q_investigacion, 100).
orden_pregunta(q_trabajo_equipo, 110).
orden_pregunta(q_salida_laboral, 120).

orden_pregunta(q_programacion, 210).
orden_pregunta(q_datos_estadistica, 220).
orden_pregunta(q_software_apps, 230).
orden_pregunta(q_resolver_errores, 240).

orden_pregunta(q_biologia_cuerpo, 310).
orden_pregunta(q_cuidado_pacientes, 320).
orden_pregunta(q_contextos_clinicos, 330).
orden_pregunta(q_estudio_largo, 340).

orden_pregunta(q_escucha_empatia, 410).
orden_pregunta(q_comportamiento_humano, 420).
orden_pregunta(q_acompanar_personas, 430).

orden_pregunta(q_numeros_finanzas, 510).
orden_pregunta(q_organizacion_empresas, 520).
orden_pregunta(q_toma_decisiones_negocios, 530).

orden_pregunta(q_diseno_visual, 610).
orden_pregunta(q_espacios_objetos, 620).
orden_pregunta(q_creacion_multimedia, 630).

orden_pregunta(q_redaccion, 710).
orden_pregunta(q_medios_sociales, 720).
orden_pregunta(q_presentar_ideas, 730).

orden_pregunta(q_argumentacion_debate, 810).
orden_pregunta(q_conflictos_normas, 820).

orden_pregunta(q_experimentos_hipotesis, 910).
orden_pregunta(q_analisis_datos, 920).

% ============================================================
% REGLAS DE AREAS
% area_regla(Area, Pregunta, Peso, Descripcion).
%
% Sirven para que Prolog detecte que areas son prometedoras
% y decida que pregunta conviene hacer despues.
% ============================================================

area_regla(tecnologia, q_interes_tecnologia, 5, 'interes general en tecnologia').
area_regla(tecnologia, q_matematica_logica, 3, 'comodidad con logica y matematica').
area_regla(tecnologia, q_programacion, 5, 'interes en programacion').
area_regla(tecnologia, q_datos_estadistica, 4, 'interes en datos y estadistica').
area_regla(tecnologia, q_software_apps, 4, 'interes en crear software').
area_regla(tecnologia, q_resolver_errores, 3, 'interes en resolver problemas tecnicos').

area_regla(salud, q_interes_salud, 5, 'interes general en salud').
area_regla(salud, q_biologia_cuerpo, 5, 'interes en biologia y cuerpo humano').
area_regla(salud, q_cuidado_pacientes, 4, 'interes en cuidado de pacientes').
area_regla(salud, q_contextos_clinicos, 4, 'comodidad con contextos clinicos').
area_regla(salud, q_estudio_largo, 3, 'disposicion a estudiar carreras largas').

area_regla(social, q_interes_personas, 5, 'interes en trabajar con personas').
area_regla(social, q_escucha_empatia, 5, 'empatia y escucha').
area_regla(social, q_comportamiento_humano, 4, 'interes en conducta humana').
area_regla(social, q_acompanar_personas, 4, 'interes en acompanar personas').
area_regla(social, q_trabajo_equipo, 3, 'preferencia por trabajo en equipo').

area_regla(economia, q_economia_gestion, 5, 'interes en economia y gestion').
area_regla(economia, q_numeros_finanzas, 5, 'interes en numeros y finanzas').
area_regla(economia, q_organizacion_empresas, 4, 'interes en organizacion empresarial').
area_regla(economia, q_toma_decisiones_negocios, 4, 'interes en decisiones de negocio').
area_regla(economia, q_salida_laboral, 2, 'valoracion de salida laboral concreta').

area_regla(arte_diseno, q_creatividad_visual, 5, 'interes creativo y visual').
area_regla(arte_diseno, q_diseno_visual, 5, 'interes en diseno visual').
area_regla(arte_diseno, q_espacios_objetos, 4, 'interes en espacios y objetos').
area_regla(arte_diseno, q_creacion_multimedia, 4, 'interes en contenido multimedia').

area_regla(comunicacion, q_comunicacion, 5, 'interes general en comunicacion').
area_regla(comunicacion, q_redaccion, 5, 'interes en redaccion').
area_regla(comunicacion, q_medios_sociales, 4, 'interes en medios y cultura').
area_regla(comunicacion, q_presentar_ideas, 4, 'interes en presentar ideas').

area_regla(leyes, q_leyes_normas, 5, 'interes en leyes y normas').
area_regla(leyes, q_argumentacion_debate, 5, 'interes en argumentacion').
area_regla(leyes, q_conflictos_normas, 4, 'interes en conflictos y responsabilidades').
area_regla(leyes, q_lectura_teoria, 3, 'gusto por lectura teorica').

area_regla(investigacion, q_investigacion, 5, 'interes en investigacion').
area_regla(investigacion, q_lectura_teoria, 4, 'gusto por teoria y analisis').
area_regla(investigacion, q_experimentos_hipotesis, 5, 'interes en hipotesis y evidencias').
area_regla(investigacion, q_analisis_datos, 4, 'interes en analisis de informacion').

% ============================================================
% REGLAS DE RECOMENDACION DE CARRERAS
%
% regla(IdRegla, Carrera, Pregunta, Peso, Descripcion).
%
% Si la respuesta es 5 o 4, suma puntos.
% Si la respuesta es 3, es neutral.
% Si la respuesta es 2 o 1, resta puntos.
%
% Solo las contribuciones positivas aparecen en la explicacion.
% ============================================================

% Ingenieria en Sistemas

regla(r_sis_tecnologia, ingenieria_sistemas, q_interes_tecnologia, 5,
    'muestra interes en tecnologia').

regla(r_sis_logica, ingenieria_sistemas, q_matematica_logica, 5,
    'se siente comodo con logica, matematica y abstraccion').

regla(r_sis_programacion, ingenieria_sistemas, q_programacion, 5,
    'le interesa programar y construir soluciones con software').

regla(r_sis_software, ingenieria_sistemas, q_software_apps, 4,
    'le interesa crear aplicaciones o sistemas digitales').

regla(r_sis_errores, ingenieria_sistemas, q_resolver_errores, 3,
    'disfruta resolver errores y mejorar sistemas').

regla(r_sis_salida, ingenieria_sistemas, q_salida_laboral, 2,
    'valora una salida laboral concreta').

% Tecnicatura en Programacion

regla(r_prog_tecnologia, tecnicatura_programacion, q_interes_tecnologia, 4,
    'muestra interes en tecnologia').

regla(r_prog_programacion, tecnicatura_programacion, q_programacion, 6,
    'tiene alto interes en programacion').

regla(r_prog_software, tecnicatura_programacion, q_software_apps, 5,
    'le interesa construir aplicaciones').

regla(r_prog_errores, tecnicatura_programacion, q_resolver_errores, 4,
    'disfruta resolver problemas tecnicos').

regla(r_prog_salida, tecnicatura_programacion, q_salida_laboral, 4,
    'busca una salida laboral rapida o concreta').

regla(r_prog_logica, tecnicatura_programacion, q_matematica_logica, 3,
    'tiene afinidad con razonamiento logico').

% Ciencia de Datos

regla(r_datos_tecnologia, ciencia_datos, q_interes_tecnologia, 4,
    'muestra interes en tecnologia').

regla(r_datos_matematica, ciencia_datos, q_matematica_logica, 5,
    'se siente comodo con matematica y razonamiento abstracto').

regla(r_datos_estadistica, ciencia_datos, q_datos_estadistica, 6,
    'le interesa analizar datos, patrones y estadisticas').

regla(r_datos_investigacion, ciencia_datos, q_investigacion, 4,
    'tiene interes por investigar y analizar informacion').

regla(r_datos_analisis, ciencia_datos, q_analisis_datos, 5,
    'le interesa convertir informacion en conclusiones utiles').

regla(r_datos_hipotesis, ciencia_datos, q_experimentos_hipotesis, 3,
    'le interesa trabajar con hipotesis y evidencia').

% Medicina

regla(r_med_salud, medicina, q_interes_salud, 6,
    'muestra fuerte interes en salud').

regla(r_med_biologia, medicina, q_biologia_cuerpo, 6,
    'le interesa la biologia y el cuerpo humano').

regla(r_med_clinica, medicina, q_contextos_clinicos, 5,
    'se siente comodo con contextos clinicos').

regla(r_med_pacientes, medicina, q_cuidado_pacientes, 4,
    'le interesa el cuidado de pacientes').

regla(r_med_estudio_largo, medicina, q_estudio_largo, 5,
    'esta dispuesto a estudiar una carrera larga y exigente').

regla(r_med_lectura, medicina, q_lectura_teoria, 3,
    'tolera el estudio teorico intenso').

% Enfermeria

regla(r_enf_salud, enfermeria, q_interes_salud, 5,
    'muestra interes en salud').

regla(r_enf_pacientes, enfermeria, q_cuidado_pacientes, 6,
    'tiene interes en cuidar y asistir pacientes').

regla(r_enf_clinica, enfermeria, q_contextos_clinicos, 5,
    'se siente comodo en contextos sanitarios').

regla(r_enf_personas, enfermeria, q_interes_personas, 4,
    'le interesa trabajar con personas').

regla(r_enf_empatia, enfermeria, q_escucha_empatia, 4,
    'muestra empatia y capacidad de escucha').

regla(r_enf_biologia, enfermeria, q_biologia_cuerpo, 3,
    'tiene interes en biologia y salud').

% Psicologia

regla(r_psi_personas, psicologia, q_interes_personas, 5,
    'muestra interes en las personas').

regla(r_psi_empatia, psicologia, q_escucha_empatia, 6,
    'muestra empatia y buena escucha').

regla(r_psi_comportamiento, psicologia, q_comportamiento_humano, 6,
    'le interesa comprender la conducta humana').

regla(r_psi_acompanar, psicologia, q_acompanar_personas, 5,
    'le interesa acompanar u orientar a otras personas').

regla(r_psi_lectura, psicologia, q_lectura_teoria, 4,
    'tolera lectura y estudio teorico').

regla(r_psi_comunicacion, psicologia, q_comunicacion, 3,
    'tiene interes en comunicarse con otros').

% Derecho

regla(r_der_leyes, derecho, q_leyes_normas, 6,
    'muestra interes en leyes, normas y justicia').

regla(r_der_argumentacion, derecho, q_argumentacion_debate, 6,
    'le interesa argumentar y defender posturas').

regla(r_der_conflictos, derecho, q_conflictos_normas, 5,
    'le interesa analizar conflictos, responsabilidades y derechos').

regla(r_der_lectura, derecho, q_lectura_teoria, 5,
    'tolera lectura teorica y textos complejos').

regla(r_der_redaccion, derecho, q_redaccion, 4,
    'le gusta redactar y construir argumentos').

regla(r_der_presentar, derecho, q_presentar_ideas, 3,
    'le interesa presentar y defender ideas').

% Contador Publico

regla(r_cont_economia, contador_publico, q_economia_gestion, 5,
    'muestra interes en economia y gestion').

regla(r_cont_numeros, contador_publico, q_numeros_finanzas, 6,
    'le interesan numeros, finanzas e impuestos').

regla(r_cont_matematica, contador_publico, q_matematica_logica, 4,
    'se siente comodo con calculos y razonamiento logico').

regla(r_cont_organizacion, contador_publico, q_organizacion_empresas, 4,
    'le interesa la organizacion administrativa').

regla(r_cont_salida, contador_publico, q_salida_laboral, 3,
    'valora una salida laboral concreta').

regla(r_cont_lectura, contador_publico, q_lectura_teoria, 2,
    'tolera normas, teoria y documentacion').

% Administracion de Empresas

regla(r_adm_economia, administracion_empresas, q_economia_gestion, 5,
    'muestra interes en economia, gestion y negocios').

regla(r_adm_organizacion, administracion_empresas, q_organizacion_empresas, 6,
    'le interesa organizar recursos, procesos y equipos').

regla(r_adm_decisiones, administracion_empresas, q_toma_decisiones_negocios, 6,
    'le interesa tomar decisiones de negocio').

regla(r_adm_comunicacion, administracion_empresas, q_comunicacion, 3,
    'tiene interes en comunicar y coordinar ideas').

regla(r_adm_equipo, administracion_empresas, q_trabajo_equipo, 4,
    'le gusta trabajar en equipo').

regla(r_adm_salida, administracion_empresas, q_salida_laboral, 3,
    'valora una salida laboral concreta').

% Diseno Grafico

regla(r_diseno_creatividad, diseno_grafico, q_creatividad_visual, 6,
    'muestra interes creativo y visual').

regla(r_diseno_visual, diseno_grafico, q_diseno_visual, 6,
    'le interesa crear piezas visuales o interfaces').

regla(r_diseno_multimedia, diseno_grafico, q_creacion_multimedia, 5,
    'le interesa crear contenido grafico o multimedia').

regla(r_diseno_comunicacion, diseno_grafico, q_comunicacion, 3,
    'tiene interes en comunicar ideas').

regla(r_diseno_presentar, diseno_grafico, q_presentar_ideas, 3,
    'le interesa expresar y presentar ideas visualmente').

regla(r_diseno_medios, diseno_grafico, q_medios_sociales, 2,
    'muestra interes en medios, cultura o redes').

% Arquitectura

regla(r_arq_creatividad, arquitectura, q_creatividad_visual, 5,
    'muestra interes creativo y visual').

regla(r_arq_espacios, arquitectura, q_espacios_objetos, 6,
    'le interesa disenar espacios, edificios u objetos').

regla(r_arq_matematica, arquitectura, q_matematica_logica, 4,
    'se siente comodo con razonamiento matematico y espacial').

regla(r_arq_diseno, arquitectura, q_diseno_visual, 4,
    'le interesa el diseno visual').

regla(r_arq_estudio_largo, arquitectura, q_estudio_largo, 3,
    'esta dispuesto a sostener una carrera exigente').

regla(r_arq_presentar, arquitectura, q_presentar_ideas, 3,
    'le interesa presentar y defender proyectos').

% Comunicacion Social

regla(r_comsoc_comunicacion, comunicacion_social, q_comunicacion, 6,
    'muestra interes general en comunicacion').

regla(r_comsoc_redaccion, comunicacion_social, q_redaccion, 6,
    'le gusta escribir, redactar o contar historias').

regla(r_comsoc_medios, comunicacion_social, q_medios_sociales, 6,
    'le interesan los medios, redes, cultura u opinion publica').

regla(r_comsoc_presentar, comunicacion_social, q_presentar_ideas, 4,
    'le gusta presentar o explicar ideas').

regla(r_comsoc_personas, comunicacion_social, q_interes_personas, 3,
    'le interesa trabajar con personas').

regla(r_comsoc_investigacion, comunicacion_social, q_investigacion, 3,
    'le interesa investigar temas sociales o culturales').

% ============================================================
% VALIDACION DE RESPUESTAS
% ============================================================

respuesta_valida(r(IdPregunta, Valor)) :-
    pregunta(IdPregunta, _, _, _),
    integer(Valor),
    Valor >= 1,
    Valor =< 5.

respuestas_validas([]).
respuestas_validas([R|Rs]) :-
    respuesta_valida(R),
    respuestas_validas(Rs).

respondida(IdPregunta, Respuestas) :-
    member(r(IdPregunta, _), Respuestas).

valor_respuesta(IdPregunta, Respuestas, Valor) :-
    member(r(IdPregunta, Valor), Respuestas).

% ============================================================
% CALCULO DE CONTRIBUCIONES
% ============================================================

% La respuesta 3 es neutral.
% 5 genera +2 * Peso.
% 4 genera +1 * Peso.
% 3 genera 0.
% 2 genera -1 * Peso.
% 1 genera -2 * Peso.

contribucion(Peso, Valor, Contribucion) :-
    Contribucion is (Valor - 3) * Peso.

maximo_absoluto(Peso, Maximo) :-
    Maximo is abs(Peso) * 2.

normalizar_porcentaje(_, 0, 50) :- !.
normalizar_porcentaje(Puntos, Maximo, PorcentajeFinal) :-
    Porcentaje is ((Puntos + Maximo) / (2 * Maximo)) * 100,
    limitar_0_100(Porcentaje, Limitado),
    PorcentajeFinal is round(Limitado).

limitar_0_100(Valor, 0) :-
    Valor < 0,
    !.
limitar_0_100(Valor, 100) :-
    Valor > 100,
    !.
limitar_0_100(Valor, Valor).

% ============================================================
% PUNTAJE POR AREA
% ============================================================

puntaje_area(Area, Respuestas, Porcentaje) :-
    findall(
        Contribucion-Maximo,
        (
            member(r(IdPregunta, Valor), Respuestas),
            area_regla(Area, IdPregunta, Peso, _),
            contribucion(Peso, Valor, Contribucion),
            maximo_absoluto(Peso, Maximo)
        ),
        Pares
    ),
    sumar_pares(Pares, Puntos, MaximoTotal),
    normalizar_porcentaje(Puntos, MaximoTotal, Porcentaje).

areas_por_puntaje(Respuestas, AreasOrdenadas) :-
    findall(
        Negativo-Area,
        (
            area(Area),
            puntaje_area(Area, Respuestas, Porcentaje),
            Negativo is -Porcentaje
        ),
        Pares
    ),
    keysort(Pares, Ordenados),
    valores_de_pares(Ordenados, AreasOrdenadas).

area_prometedora(Area, Respuestas) :-
    puntaje_area(Area, Respuestas, Porcentaje),
    Porcentaje >= 55.

% ============================================================
% PUNTAJE POR CARRERA
% ============================================================

puntaje_carrera(Carrera, Respuestas, Porcentaje, Puntos, MaximoTotal) :-
    carrera(Carrera),
    findall(
        Contribucion-Maximo,
        (
            member(r(IdPregunta, Valor), Respuestas),
            regla(_, Carrera, IdPregunta, Peso, _),
            contribucion(Peso, Valor, Contribucion),
            maximo_absoluto(Peso, Maximo)
        ),
        Pares
    ),
    sumar_pares(Pares, Puntos, MaximoTotal),
    normalizar_porcentaje(Puntos, MaximoTotal, Porcentaje).

% ============================================================
% SELECCION ADAPTATIVA DE PREGUNTAS
%
% Esta es la parte central:
% Prolog decide que pregunta hacer despues.
%
% La eleccion depende de:
% - respuestas anteriores;
% - areas con mayor afinidad;
% - preguntas ya respondidas;
% - utilidad de la pregunta para diferenciar carreras;
% - cantidad de preguntas realizadas.
% ============================================================

siguiente_pregunta(Respuestas, pregunta(Id, Texto, Area, Tipo)) :-
    respuestas_validas(Respuestas),
    \+ debe_finalizar(Respuestas),
    elegir_pregunta_adaptativa(Respuestas, Id),
    pregunta(Id, Tipo, Area, Texto).

elegir_pregunta_adaptativa([], q_interes_tecnologia) :- !.

elegir_pregunta_adaptativa(Respuestas, IdPregunta) :-
    findall(
        Clave-Id,
        (
            pregunta(Id, Tipo, Area, _),
            \+ respondida(Id, Respuestas),
            pregunta_habilitada(Respuestas, Id, Tipo, Area),
            puntaje_pregunta(Respuestas, Id, Tipo, Area, Puntaje),
            orden_pregunta(Id, Orden),
            Clave is -Puntaje * 10000 + Orden
        ),
        Candidatas
    ),
    keysort(Candidatas, [_-IdPregunta|_]).

% Una pregunta esta habilitada si todavia tiene sentido hacerla.
% Las preguntas generales siempre pueden hacerse.
% Las especificas solo se habilitan cuando su area ya parece prometedora,
% o cuando todavia hay pocas respuestas y necesitamos explorar un poco.

pregunta_habilitada(_, _, general, _) :- !.

pregunta_habilitada(Respuestas, _, especifica, Area) :-
    length(Respuestas, Cantidad),
    (
        Cantidad < 4
        ->
            puntaje_area(Area, Respuestas, Porcentaje),
            Porcentaje >= 70
        ;
            area_prometedora(Area, Respuestas)
    ).

% Puntaje adaptativo de cada pregunta.
% Cuanto mayor es, mas probable es que Prolog la elija.

puntaje_pregunta(Respuestas, IdPregunta, Tipo, Area, PuntajeFinal) :-
    length(Respuestas, Cantidad),
    puntaje_area(Area, Respuestas, PuntajeArea),
    utilidad_pregunta_carreras(IdPregunta, UtilidadCarreras),
    bono_por_tipo(Cantidad, Tipo, PuntajeArea, BonoTipo),
    bono_por_area(PuntajeArea, BonoArea),
    bono_por_no_explorada(Respuestas, Area, BonoExploracion),
    PuntajeFinal is BonoTipo + BonoArea + UtilidadCarreras + BonoExploracion.

% Al principio se favorecen preguntas generales para no sesgar demasiado.
% Luego se favorecen preguntas especificas de areas prometedoras.

bono_por_tipo(Cantidad, general, _, 45) :-
    Cantidad < 5,
    !.

bono_por_tipo(Cantidad, especifica, PuntajeArea, 55) :-
    Cantidad >= 5,
    PuntajeArea >= 55,
    !.

bono_por_tipo(_, general, _, 20) :- !.
bono_por_tipo(_, especifica, PuntajeArea, Bono) :-
    Bono is max(0, PuntajeArea - 35).

% Las areas con alto porcentaje empujan preguntas relacionadas.
% Las areas con bajo porcentaje pierden prioridad.

bono_por_area(PuntajeArea, Bono) :-
    Bono is PuntajeArea - 50.

% Si un area todavia no fue explorada, recibe un pequeno bono.
% Esto evita que el sistema se cierre demasiado rapido con una sola area.

bono_por_no_explorada(Respuestas, Area, 15) :-
    \+ area_respondida(Area, Respuestas),
    !.

bono_por_no_explorada(_, _, 0).

area_respondida(Area, Respuestas) :-
    member(r(IdPregunta, _), Respuestas),
    pregunta(IdPregunta, _, Area, _).

% Utilidad de una pregunta para diferenciar carreras.
% Una pregunta es mas util si aparece en varias reglas de carrera
% o si tiene pesos fuertes.

utilidad_pregunta_carreras(IdPregunta, Utilidad) :-
    findall(
        PesoAbs,
        (
            regla(_, _, IdPregunta, Peso, _),
            PesoAbs is abs(Peso)
        ),
        Pesos
    ),
    sum_list(Pesos, Suma),
    Utilidad is Suma / 2.

% ============================================================
% CRITERIO DE FINALIZACION
% ============================================================

debe_finalizar(Respuestas) :-
    length(Respuestas, Cantidad),
    max_preguntas(Max),
    Cantidad >= Max,
    !.

debe_finalizar(Respuestas) :-
    length(Respuestas, Cantidad),
    min_preguntas(Min),
    Cantidad >= Min,
    mejores_dos_porcentajes(Respuestas, Primero, Segundo),
    umbral_afinidad_alta(UmbralAfinidad),
    umbral_ventaja_clara(UmbralVentaja),
    Primero >= UmbralAfinidad,
    Diferencia is Primero - Segundo,
    Diferencia >= UmbralVentaja.

mejores_dos_porcentajes(Respuestas, Primero, Segundo) :-
    findall(
        Negativo-Porcentaje,
        (
            carrera(Carrera),
            puntaje_carrera(Carrera, Respuestas, Porcentaje, _, _),
            Negativo is -Porcentaje
        ),
        Pares
    ),
    keysort(Pares, [_-Primero, _-Segundo|_]).

% ============================================================
% REGLAS ACTIVADAS Y EXPLICACION
% ============================================================

reglas_activadas(Carrera, Respuestas, ReglasOrdenadas) :-
    findall(
        Negativo-regla(IdRegla, Descripcion, Contribucion),
        (
            member(r(IdPregunta, Valor), Respuestas),
            regla(IdRegla, Carrera, IdPregunta, Peso, Descripcion),
            contribucion(Peso, Valor, Contribucion),
            Contribucion > 0,
            Negativo is -Contribucion
        ),
        Pares
    ),
    keysort(Pares, Ordenados),
    valores_de_pares(Ordenados, ReglasOrdenadas).

resumen_recomendacion(Carrera, Respuestas, Resumen) :-
    nombre_carrera(Carrera, Nombre),
    reglas_activadas(Carrera, Respuestas, Reglas),
    findall(
        Descripcion,
        member(regla(_, Descripcion, _), Reglas),
        DescripcionesTodas
    ),
    primeros(3, DescripcionesTodas, Principales),
    construir_resumen(Nombre, Principales, Resumen).

construir_resumen(Nombre, [], Resumen) :-
    format(
        atom(Resumen),
        '~a aparece en el ranking por afinidad general, aunque todavia no tiene reglas positivas fuertes activadas.',
        [Nombre]
    ).

construir_resumen(Nombre, Motivos, Resumen) :-
    Motivos \= [],
    atomic_list_concat(Motivos, '; ', TextoMotivos),
    format(
        atom(Resumen),
        'Se recomienda ~a porque: ~a.',
        [Nombre, TextoMotivos]
    ).

% ============================================================
% RANKING
% ============================================================

ranking_completo(Respuestas, Ranking) :-
    respuestas_validas(Respuestas),
    findall(
        Clave-resultado(Carrera, Nombre, Porcentaje, Reglas, Resumen),
        (
            carrera(Carrera),
            nombre_carrera(Carrera, Nombre),
            puntaje_carrera(Carrera, Respuestas, Porcentaje, _, _),
            reglas_activadas(Carrera, Respuestas, Reglas),
            resumen_recomendacion(Carrera, Respuestas, Resumen),
            Clave is -Porcentaje
        ),
        Pares
    ),
    keysort(Pares, Ordenados),
    valores_de_pares(Ordenados, Ranking).

ranking_top5(Respuestas, Top5) :-
    ranking_completo(Respuestas, Ranking),
    primeros(5, Ranking, Top5).

% ============================================================
% PREDICADO PRINCIPAL PARA JAVA
%
% estado_sesion(+Respuestas, -Estado).
%
% Posibles respuestas:
%
% Estado = preguntar(pregunta(Id, Texto, Area, Tipo)).
%
% Estado = finalizar(RankingTop5).
%
% Esta es la unica consulta principal que necesitarias llamar
% desde Java despues de cada respuesta del usuario.
% ============================================================

estado_sesion(Respuestas, error(respuestas_invalidas)) :-
    \+ respuestas_validas(Respuestas),
    !.

estado_sesion(Respuestas, finalizar(RankingTop5)) :-
    debe_finalizar(Respuestas),
    !,
    ranking_top5(Respuestas, RankingTop5).

estado_sesion(Respuestas, preguntar(Pregunta)) :-
    siguiente_pregunta(Respuestas, Pregunta),
    !.

estado_sesion(Respuestas, finalizar(RankingTop5)) :-
    ranking_top5(Respuestas, RankingTop5).

% ============================================================
% UTILIDADES
% ============================================================

sumar_pares([], 0, 0).
sumar_pares([Puntos-Maximo|Resto], TotalPuntos, TotalMaximo) :-
    sumar_pares(Resto, PuntosResto, MaximoResto),
    TotalPuntos is Puntos + PuntosResto,
    TotalMaximo is Maximo + MaximoResto.

valores_de_pares([], []).
valores_de_pares([_-Valor|Resto], [Valor|Valores]) :-
    valores_de_pares(Resto, Valores).

primeros(_, [], []) :- !.
primeros(0, _, []) :- !.
primeros(N, [X|Xs], [X|Ys]) :-
    N > 0,
    N1 is N - 1,
    primeros(N1, Xs, Ys).
