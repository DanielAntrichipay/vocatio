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
public class ActivatedRule {
    private String id;
    private String description;
    private Integer score;

    public static ActivatedRule fromTerm(Term term) {
        if (!term.hasFunctor("regla", 3)) {
            throw new IllegalArgumentException("El término no es una regla válida: " + term);
        }
        return ActivatedRule.builder()
                .id(term.arg(1).name())
                .description(term.arg(2).name())
                .score(term.arg(3).intValue())
                .build();
    }
}
