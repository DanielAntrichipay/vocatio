package com.protype.vocatio.interview.start;

import com.protype.vocatio.common.mediator.JMediator;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@Tag(name = "Interview", description = "Operaciones de la entrevista vocacional")
@RestController
@RequestMapping("/api/interview")
@RequiredArgsConstructor
public class StartInterviewController {

    private final JMediator jMediator;

    @Operation(summary = "Iniciar una nueva entrevista")
    @ApiResponse(responseCode = "201", description = "Entrevista iniciada exitosamente")
    @PostMapping("/start")
    public ResponseEntity<StartInterviewResponse> start() throws Throwable {
        StartInterviewRequest request = new StartInterviewRequest();
        StartInterviewResponse response = jMediator.send(request);
        return new ResponseEntity<>(response, HttpStatus.CREATED);
    }
}
