package com.protype.vocatio.interview.answer;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Builder;
import lombok.Data;

@Data
@Builder
@Schema(description = "Progreso actual de la entrevista")
public class ProgressDTO {
    
    @Schema(description = "Cantidad de preguntas respondidas")
    private Integer answered;
    
    @Schema(description = "Mínimo de preguntas requeridas antes de poder finalizar")
    private Integer minQuestions;
    
    @Schema(description = "Límite máximo de preguntas")
    private Integer maxQuestions;
}
