package com.protype.vocatio.interview.answer;

import com.fasterxml.jackson.annotation.JsonInclude;
import com.protype.vocatio.common.entities.Question;
import com.protype.vocatio.common.entities.Result;
import com.protype.vocatio.common.enums.InterviewStatus;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Builder;
import lombok.Data;

import java.util.List;

@Data
@Builder
@JsonInclude(JsonInclude.Include.NON_NULL)
@Schema(description = "Respuesta dinámica del sistema experto tras evaluar una respuesta")
public class AnswerInterviewResponse {
    
    @Schema(description = "Estado actual de la entrevista")
    private InterviewStatus status;
    
    @Schema(description = "Siguiente pregunta, si el status es QUESTION")
    private Question question;
    
    @Schema(description = "Ranking de carreras, si el status es FINISHED")
    private List<Result> ranking;
    
    @Schema(description = "Progreso de la entrevista")
    private ProgressDTO progress;
}
