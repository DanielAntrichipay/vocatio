package com.protype.vocatio.interview.answer;

import com.protype.vocatio.common.exceptions.BadRequestException;
import com.protype.vocatio.common.mediator.Validator;
import com.protype.vocatio.interview.InterviewSessionRepository;
import lombok.RequiredArgsConstructor;

@Validator
@RequiredArgsConstructor
public class AnswerInterviewValidator {

    private final InterviewSessionRepository sessionRepository;

    public void validate(AnswerInterviewRequest request) {
        if (!sessionRepository.exists(request.getSessionId())) {
            throw new BadRequestException("La sesión de entrevista no existe o ha expirado.");
        }
        
        if (request.getValue() == null || request.getValue() < 1 || request.getValue() > 5) {
            throw new BadRequestException("El valor de la respuesta debe estar entre 1 y 5.");
        }
        
        if (request.getQuestionId() == null || request.getQuestionId().trim().isEmpty()) {
            throw new BadRequestException("El ID de la pregunta no puede estar vacío.");
        }
    }
}
