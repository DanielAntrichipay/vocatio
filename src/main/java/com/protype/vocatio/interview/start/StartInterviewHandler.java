package com.protype.vocatio.interview.start;

import com.protype.vocatio.common.entities.Question;
import com.protype.vocatio.common.enums.InterviewStatus;
import com.protype.vocatio.common.mediator.Handler;
import com.protype.vocatio.interview.PrologEngine;
import com.protype.vocatio.interview.InterviewSessionRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.log4j.Log4j2;
import org.jpl7.Term;

import java.util.Collections;

@Log4j2
@Handler
@RequiredArgsConstructor
public class StartInterviewHandler {

    private final InterviewSessionRepository sessionRepository;
    private final PrologEngine prologEngine;

    public StartInterviewResponse handle(StartInterviewRequest request) {
        log.info("Iniciando nueva entrevista...");
        String sessionId = sessionRepository.createSession();
        
        Term term = prologEngine.estadoSesion(Collections.emptyList());
        
        if (!term.hasFunctor("preguntar", 1)) {
            throw new RuntimeException("El sistema experto devolvió un estado inesperado al iniciar la sesión: " + term);
        }
        
        Question question = Question.fromTerm(term.arg(1));
        
        return StartInterviewResponse.builder()
                .sessionId(sessionId)
                .status(InterviewStatus.QUESTION)
                .question(question)
                .build();
    }
}
