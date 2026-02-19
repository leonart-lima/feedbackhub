package com.fiap.feedbackhub.dto;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.fiap.feedbackhub.enums.Urgencia;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

/**
 * DTO para resposta de avaliação
 * View layer do padrão MVC
 */
public class AvaliacaoResponseDTO {

    private Long id;
    private String descricao;
    private Integer nota;
    private String urgencia;  // String para compatibilidade com Azure Functions

    @JsonFormat(pattern = "yyyy-MM-dd'T'HH:mm:ss")
    private String dataEnvio;  // String para compatibilidade com Azure Functions

    private String mensagem;

    private static final DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm:ss");

    public AvaliacaoResponseDTO() {
    }

    public AvaliacaoResponseDTO(Long id, String descricao, Integer nota, Urgencia urgencia, LocalDateTime dataEnvio, String mensagem) {
        this.id = id;
        this.descricao = descricao;
        this.nota = nota;
        this.urgencia = urgencia != null ? urgencia.toString() : null;
        this.dataEnvio = dataEnvio != null ? dataEnvio.format(formatter) : null;
        this.mensagem = mensagem;
    }

    // Getters and Setters

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

    public String getUrgencia() {
        return urgencia;
    }

    public void setUrgencia(Urgencia urgencia) {
        this.urgencia = urgencia != null ? urgencia.toString() : null;
    }

    public void setUrgencia(String urgencia) {
        this.urgencia = urgencia;
    }

    public String getDataEnvio() {
        return dataEnvio;
    }

    public void setDataEnvio(LocalDateTime dataEnvio) {
        this.dataEnvio = dataEnvio != null ? dataEnvio.format(formatter) : null;
    }

    public void setDataEnvio(String dataEnvio) {
        this.dataEnvio = dataEnvio;
    }

    public String getMensagem() {
        return mensagem;
    }

    public void setMensagem(String mensagem) {
        this.mensagem = mensagem;
    }
}
