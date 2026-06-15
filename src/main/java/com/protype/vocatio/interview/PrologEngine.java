package com.protype.vocatio.interview;

import com.protype.vocatio.common.entities.Answer;
import jakarta.annotation.PostConstruct;
import jakarta.annotation.PreDestroy;
import lombok.extern.log4j.Log4j2;
import org.jpl7.Query;
import org.jpl7.Term;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.Map;
import java.util.concurrent.Callable;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

@Log4j2
@Component
public class PrologEngine {

    private final ExecutorService prologExecutor = Executors.newSingleThreadExecutor(runnable -> {
        Thread thread = new Thread(runnable, "vocatio-prolog-engine");
        thread.setDaemon(true);
        return thread;
    });

    private int minQuestions = 8;
    private int maxQuestions = 15;

    @PostConstruct
    public void init() {
        runOnPrologThread(() -> {
            log.info("Inicializando Motor Prolog...");
            Query q = new Query("consult('sistema_experto.pl')");
            try {
                if (q.hasSolution()) {
                    log.info("Archivo sistema_experto.pl cargado correctamente.");
                } else {
                    log.error("No se pudo cargar sistema_experto.pl. Verifique la ruta.");
                    throw new RuntimeException("Error al cargar la base de conocimiento Prolog.");
                }
            } finally {
                q.close();
            }

            minQuestions = queryIntegerUnsafe("min_preguntas", minQuestions);
            maxQuestions = queryIntegerUnsafe("max_preguntas", maxQuestions);
            return null;
        });
    }

    @PreDestroy
    public void shutdown() {
        prologExecutor.shutdownNow();
    }

    public Term estadoSesion(List<Answer> answers) {
        return runOnPrologThread(() -> estadoSesionUnsafe(answers));
    }

    private Term estadoSesionUnsafe(List<Answer> answers) {
        Term[] answersTerms = answers.stream()
                .map(Answer::toTerm)
                .toArray(Term[]::new);

        Term respuestasList = org.jpl7.Util.termArrayToList(answersTerms);
        
        Query query = new Query("estado_sesion", new Term[]{respuestasList, new org.jpl7.Variable("Estado")});

        Map<String, Term> solution;
        try {
            solution = query.oneSolution();
        } finally {
            query.close();
        }

        if (solution != null) {
            return solution.get("Estado");
        }

        throw new RuntimeException("Prolog no pudo determinar el estado de la sesión.");
    }
    
    public int getMinQuestions() {
        return minQuestions;
    }

    public int getMaxQuestions() {
        return maxQuestions;
    }

    private int queryIntegerUnsafe(String predicate, int fallback) {
        Query query = new Query(predicate, new Term[]{new org.jpl7.Variable("X")});

        Map<String, Term> solution;
        try {
            solution = query.oneSolution();
        } finally {
            query.close();
        }

        if (solution != null) {
            return solution.get("X").intValue();
        }

        return fallback;
    }

    private <T> T runOnPrologThread(Callable<T> task) {
        try {
            return prologExecutor.submit(task).get();
        } catch (InterruptedException exception) {
            Thread.currentThread().interrupt();
            throw new RuntimeException("La consulta Prolog fue interrumpida.", exception);
        } catch (ExecutionException exception) {
            Throwable cause = exception.getCause();
            if (cause instanceof RuntimeException runtimeException) {
                throw runtimeException;
            }
            if (cause instanceof Error error) {
                throw error;
            }
            throw new RuntimeException("Falló la consulta Prolog.", cause);
        }
    }
}
