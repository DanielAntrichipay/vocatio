package com.protype.vocatio.interview.start;

import com.protype.vocatio.common.entities.Question;
import com.protype.vocatio.common.enums.InterviewStatus;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Builder;
import lombok.Data;

@Data
@Builder
@Schema(description = "Respuesta al iniciar una nueva entrevista")
public class StartInterviewResponse {
    
    @Schema(description = "ID de la sesión de la entrevista, necesario para responder")
    private String sessionId;
    
    @Schema(description = "Estado de la entrevista")
    private InterviewStatus status;
    
    @Schema(description = "Primera pregunta a responder")
    private Question question;
}
