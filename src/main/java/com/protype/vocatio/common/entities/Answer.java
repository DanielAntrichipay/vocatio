package com.protype.vocatio.common.entities;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.jpl7.Atom;
import org.jpl7.Compound;
import org.jpl7.Term;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Answer {
    private String questionId;
    private Integer value;

    public Term toTerm() {
        return new Compound("r", new Term[]{
                new Atom(this.questionId),
                new org.jpl7.Integer(this.value)
        });
    }
}
