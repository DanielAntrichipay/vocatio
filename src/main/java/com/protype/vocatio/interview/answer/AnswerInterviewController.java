package com.protype.vocatio.interview.answer;

import com.protype.vocatio.common.mediator.JMediator;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@Tag(name = "Interview", description = "Operaciones de la entrevista vocacional")
@RestController
@RequestMapping("/api/interview")
@RequiredArgsConstructor
public class AnswerInterviewController {

    private final JMediator jMediator;

    @Operation(summary = "Responder una pregunta de la entrevista")
    @ApiResponse(responseCode = "200", description = "Respuesta procesada exitosamente")
    @PostMapping("/{sessionId}/answer")
    public ResponseEntity<AnswerInterviewResponse> answer(
            @PathVariable String sessionId,
            @RequestBody AnswerInterviewRequest request) throws Throwable {
        
        request.setSessionId(sessionId);
        AnswerInterviewResponse response = jMediator.send(request);
        return ResponseEntity.ok(response);
    }
}
