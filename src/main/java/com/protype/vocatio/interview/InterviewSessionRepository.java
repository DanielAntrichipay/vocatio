package com.protype.vocatio.interview;

import com.protype.vocatio.common.entities.Answer;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

@Component
public class InterviewSessionRepository {
    
    private final Map<String, List<Answer>> sessions = new ConcurrentHashMap<>();

    public String createSession() {
        String sessionId = UUID.randomUUID().toString();
        sessions.put(sessionId, new ArrayList<>());
        return sessionId;
    }

    public List<Answer> getAnswers(String sessionId) {
        return sessions.getOrDefault(sessionId, new ArrayList<>());
    }

    public void addAnswer(String sessionId, Answer answer) {
        if (!sessions.containsKey(sessionId)) {
            throw new IllegalArgumentException("La sesión " + sessionId + " no existe o ha expirado.");
        }
        sessions.get(sessionId).add(answer);
    }
    
    public boolean exists(String sessionId) {
        return sessions.containsKey(sessionId);
    }
}
