package com.protype.vocatio.interview.answer;

import com.protype.vocatio.common.entities.Answer;
import com.protype.vocatio.common.entities.Question;
import com.protype.vocatio.common.entities.Result;
import com.protype.vocatio.common.enums.InterviewStatus;
import com.protype.vocatio.common.mediator.Handler;
import com.protype.vocatio.interview.InterviewSessionRepository;
import com.protype.vocatio.interview.PrologEngine;
import lombok.RequiredArgsConstructor;
import lombok.extern.log4j.Log4j2;
import org.jpl7.Term;

import java.util.ArrayList;
import java.util.List;

@Log4j2
@Handler
@RequiredArgsConstructor
public class AnswerInterviewHandler {

    private final InterviewSessionRepository sessionRepository;
    private final PrologEngine prologEngine;

    public AnswerInterviewResponse handle(AnswerInterviewRequest request) {
        Answer newAnswer = Answer.builder()
                .questionId(request.getQuestionId())
                .value(request.getValue())
                .build();
        
        sessionRepository.addAnswer(request.getSessionId(), newAnswer);
        List<Answer> answers = sessionRepository.getAnswers(request.getSessionId());

        int answered = answers.size();
        ProgressDTO progress = ProgressDTO.builder()
                .answered(answered)
                .minQuestions(prologEngine.getMinQuestions())
                .maxQuestions(prologEngine.getMaxQuestions())
                .build();

        Term term = prologEngine.estadoSesion(answers);

        if (term.hasFunctor("preguntar", 1)) {
            Question question = Question.fromTerm(term.arg(1));
            return AnswerInterviewResponse.builder()
                    .status(InterviewStatus.QUESTION)
                    .question(question)
                    .progress(progress)
                    .build();
            
        } else if (term.hasFunctor("finalizar", 1)) {
            List<Result> ranking = new ArrayList<>();
            Term listTerm = term.arg(1);
            while (listTerm.isListPair()) {
                ranking.add(Result.fromTerm(listTerm.arg(1)));
                listTerm = listTerm.arg(2);
            }
            
            return AnswerInterviewResponse.builder()
                    .status(InterviewStatus.FINISHED)
                    .ranking(ranking)
                    .progress(progress)
                    .build();
            
        } else if (term.hasFunctor("error", 1)) {
            throw new RuntimeException("Error en sistema experto: " + term.arg(1).name());
        } else {
            throw new RuntimeException("Estado inesperado retornado por Prolog: " + term);
        }
    }
}
