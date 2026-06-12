package com.protype.vocatio.common.entities;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.jpl7.Term;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Question {
    private String id;
    private String text;
    private String area;
    private String type;

    public static Question fromTerm(Term term) {
        if (!term.hasFunctor("pregunta", 4)) {
            throw new IllegalArgumentException("El término no es una pregunta válida: " + term);
        }
        return Question.builder()
                .id(term.arg(1).name())
                .text(term.arg(2).name())
                .area(term.arg(3).name())
                .type(term.arg(4).name())
                .build();
    }
}
