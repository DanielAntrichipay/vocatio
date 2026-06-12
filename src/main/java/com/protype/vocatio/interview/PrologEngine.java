package com.protype.vocatio.interview;

import com.protype.vocatio.common.entities.Answer;
import jakarta.annotation.PostConstruct;
import lombok.extern.log4j.Log4j2;
import org.jpl7.Query;
import org.jpl7.Term;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.Map;

@Log4j2
@Component
public class PrologEngine {

    @PostConstruct
    public void init() {
        log.info("Inicializando Motor Prolog...");
        Query q = new Query("consult('sistema_experto.pl')");
        if (q.hasSolution()) {
            log.info("Archivo sistema_experto.pl cargado correctamente.");
        } else {
            log.error("No se pudo cargar sistema_experto.pl. Verifique la ruta.");
            throw new RuntimeException("Error al cargar la base de conocimiento Prolog.");
        }
        q.close();
    }

    public Term estadoSesion(List<Answer> answers) {
        Term[] answersTerms = answers.stream()
                .map(Answer::toTerm)
                .toArray(Term[]::new);

        Term respuestasList = org.jpl7.Util.termArrayToList(answersTerms);
        
        Query query = new Query("estado_sesion", new Term[]{respuestasList, new org.jpl7.Variable("Estado")});
        
        if (query.hasSolution()) {
            Map<String, Term> solution = query.oneSolution();
            query.close();
            return solution.get("Estado");
        }
        
        query.close();
        throw new RuntimeException("Prolog no pudo determinar el estado de la sesión.");
    }
    
    public int getMinQuestions() {
        Query q = new Query("min_preguntas", new Term[]{new org.jpl7.Variable("X")});
        if (q.hasSolution()) {
            Map<String, Term> sol = q.oneSolution();
            q.close();
            return sol.get("X").intValue();
        }
        q.close();
        return 15;
    }

    public int getMaxQuestions() {
        Query q = new Query("max_preguntas", new Term[]{new org.jpl7.Variable("X")});
        if (q.hasSolution()) {
            Map<String, Term> sol = q.oneSolution();
            q.close();
            return sol.get("X").intValue();
        }
        q.close();
        return 30;
    }
}
