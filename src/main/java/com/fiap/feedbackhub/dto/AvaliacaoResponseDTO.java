package com.fiap.feedbackhub.dto;

import com.fiap.feedbackhub.enums.Urgencia;

import java.time.LocalDateTime;

/**
 * DTO para resposta de avaliação
 * View layer do padrão MVC
 */
public class AvaliacaoResponseDTO {

    private Long id;
    private String descricao;
    private Integer nota;
    private Urgencia urgencia;
    private LocalDateTime dataEnvio;
    private String mensagem;

    public AvaliacaoResponseDTO() {
    }

    public AvaliacaoResponseDTO(Long id, String descricao, Integer nota, Urgencia urgencia, LocalDateTime dataEnvio, String mensagem) {
        this.id = id;
        this.descricao = descricao;
        this.nota = nota;
        this.urgencia = urgencia;
        this.dataEnvio = dataEnvio;
        this.mensagem = mensagem;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getDescricao() {
        return descricao;
    }

    public void setDescricao(String descricao) {
        this.descricao = descricao;
    }

    public Integer getNota() {
        return nota;
    }

    public void setNota(Integer nota) {
        this.nota = nota;
    }

    public Urgencia getUrgencia() {
        return urgencia;
    }

    public void setUrgencia(Urgencia urgencia) {
        this.urgencia = urgencia;
    }

    public LocalDateTime getDataEnvio() {
        return dataEnvio;
    }

    public void setDataEnvio(LocalDateTime dataEnvio) {
        this.dataEnvio = dataEnvio;
    }

    public String getMensagem() {
        return mensagem;
    }

    public void setMensagem(String mensagem) {
        this.mensagem = mensagem;
    }
}
