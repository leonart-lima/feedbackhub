package com.fiap.feedbackhub.dto;

import java.time.LocalDateTime;
import java.util.Map;

/**
 * DTO para relatório semanal
 * View layer do padrão MVC
 */
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

    public RelatorioSemanalDTO() {
    }

    public RelatorioSemanalDTO(String titulo, LocalDateTime dataInicio, LocalDateTime dataFim, Long totalAvaliacoes,
                               Double mediaNotas, Map<String, Long> quantidadePorDia, Map<String, Long> quantidadePorUrgencia,
                               Long avaliacoesCriticas, Long avaliacoesMedias, Long avaliacoesPositivas) {
        this.titulo = titulo;
        this.dataInicio = dataInicio;
        this.dataFim = dataFim;
        this.totalAvaliacoes = totalAvaliacoes;
        this.mediaNotas = mediaNotas;
        this.quantidadePorDia = quantidadePorDia;
        this.quantidadePorUrgencia = quantidadePorUrgencia;
        this.avaliacoesCriticas = avaliacoesCriticas;
        this.avaliacoesMedias = avaliacoesMedias;
        this.avaliacoesPositivas = avaliacoesPositivas;
    }

    public String getTitulo() {
        return titulo;
    }

    public void setTitulo(String titulo) {
        this.titulo = titulo;
    }

    public LocalDateTime getDataInicio() {
        return dataInicio;
    }

    public void setDataInicio(LocalDateTime dataInicio) {
        this.dataInicio = dataInicio;
    }

    public LocalDateTime getDataFim() {
        return dataFim;
    }

    public void setDataFim(LocalDateTime dataFim) {
        this.dataFim = dataFim;
    }

    public Long getTotalAvaliacoes() {
        return totalAvaliacoes;
    }

    public void setTotalAvaliacoes(Long totalAvaliacoes) {
        this.totalAvaliacoes = totalAvaliacoes;
    }

    public Double getMediaNotas() {
        return mediaNotas;
    }

    public void setMediaNotas(Double mediaNotas) {
        this.mediaNotas = mediaNotas;
    }

    public Map<String, Long> getQuantidadePorDia() {
        return quantidadePorDia;
    }

    public void setQuantidadePorDia(Map<String, Long> quantidadePorDia) {
        this.quantidadePorDia = quantidadePorDia;
    }

    public Map<String, Long> getQuantidadePorUrgencia() {
        return quantidadePorUrgencia;
    }

    public void setQuantidadePorUrgencia(Map<String, Long> quantidadePorUrgencia) {
        this.quantidadePorUrgencia = quantidadePorUrgencia;
    }

    public Long getAvaliacoesCriticas() {
        return avaliacoesCriticas;
    }

    public void setAvaliacoesCriticas(Long avaliacoesCriticas) {
        this.avaliacoesCriticas = avaliacoesCriticas;
    }

    public Long getAvaliacoesMedias() {
        return avaliacoesMedias;
    }

    public void setAvaliacoesMedias(Long avaliacoesMedias) {
        this.avaliacoesMedias = avaliacoesMedias;
    }

    public Long getAvaliacoesPositivas() {
        return avaliacoesPositivas;
    }

    public void setAvaliacoesPositivas(Long avaliacoesPositivas) {
        this.avaliacoesPositivas = avaliacoesPositivas;
    }
}
