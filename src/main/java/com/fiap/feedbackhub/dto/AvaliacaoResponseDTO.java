package com.fiap.feedbackhub.dto;

import com.fiap.feedbackhub.enums.Urgencia;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * DTO para resposta de avaliação
 * View layer do padrão MVC
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class AvaliacaoResponseDTO {

    private Long id;
    private String descricao;
    private Integer nota;
    private Urgencia urgencia;
    private LocalDateTime dataEnvio;
    private String mensagem;
}

