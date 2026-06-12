package com.protype.vocatio.common.entities;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.jpl7.Term;

import java.util.ArrayList;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Result {
    private String careerId;
    private String careerName;
    private Integer percentage;
    private String summary;
    private List<ActivatedRule> activatedRules;

    public static Result fromTerm(Term term) {
        if (!term.hasFunctor("resultado", 5)) {
            throw new IllegalArgumentException("El término no es un resultado válido: " + term);
        }

        List<ActivatedRule> rules = new ArrayList<>();
        Term reglasTerm = term.arg(4);
        while (reglasTerm.isListPair()) {
            rules.add(ActivatedRule.fromTerm(reglasTerm.arg(1)));
            reglasTerm = reglasTerm.arg(2);
        }

        return Result.builder()
                .careerId(term.arg(1).name())
                .careerName(term.arg(2).name())
                .percentage(term.arg(3).intValue())
                .activatedRules(rules)
                .summary(term.arg(5).name())
                .build();
    }
}
