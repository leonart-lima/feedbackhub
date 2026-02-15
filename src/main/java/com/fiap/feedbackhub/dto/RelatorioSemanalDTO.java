package com.fiap.feedbackhub.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.Map;

/**
 * DTO para relatório semanal
 * View layer do padrão MVC
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class RelatorioSemanalDTO {

    private String titulo;
    private LocalDateTime dataInicio;
    private LocalDateTime dataFim;
    private Long totalAvaliacoes;
    private Double mediaNotas;
    private Map<String, Long> quantidadePorDia;
    private Map<String, Long> quantidadePorUrgencia;
    private Long avaliacoesCriticas;
    private Long avaliacoesMedias;
    private Long avaliacoesPositivas;
}

