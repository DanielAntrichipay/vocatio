package com.protype.vocatio.interview.answer;

import com.protype.vocatio.common.mediator.IRequest;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

@Data
@Schema(description = "Petición para responder una pregunta")
public class AnswerInterviewRequest implements IRequest<AnswerInterviewResponse> {
    
    @Schema(description = "ID de la sesión (provisto en la URL)", hidden = true)
    private String sessionId;
    
    @Schema(description = "ID de la pregunta que se está respondiendo")
    private String questionId;
    
    @Schema(description = "Valor numérico de la respuesta (1 a 5)")
    private Integer value;
}
