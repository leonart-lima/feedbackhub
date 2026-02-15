package com.fiap.feedbackhub.model;

import com.fiap.feedbackhub.enums.Urgencia;
import jakarta.persistence.*;

import java.time.LocalDateTime;

/**
 * Entidade que representa uma avaliação no sistema
 * Model layer do padrão MVC
 */
@Entity
@Table(name = "avaliacoes", indexes = {
    @Index(name = "idx_data_envio", columnList = "dataEnvio"),
    @Index(name = "idx_urgencia", columnList = "urgencia"),
    @Index(name = "idx_nota", columnList = "nota")
})
public class Avaliacao {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = 1000)
    private String descricao;

    @Column(nullable = false)
    private Integer nota;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private Urgencia urgencia;

    @Column(nullable = false)
    private LocalDateTime dataEnvio;

    @Column(nullable = false)
    private Boolean notificacaoEnviada = false;

    public Avaliacao() {
    }

    public Avaliacao(Long id, String descricao, Integer nota, Urgencia urgencia, LocalDateTime dataEnvio, Boolean notificacaoEnviada) {
        this.id = id;
        this.descricao = descricao;
        this.nota = nota;
        this.urgencia = urgencia;
        this.dataEnvio = dataEnvio;
        this.notificacaoEnviada = notificacaoEnviada;
    }

    @PrePersist
    protected void onCreate() {
        if (dataEnvio == null) {
            dataEnvio = LocalDateTime.now();
        }
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

    public Boolean getNotificacaoEnviada() {
        return notificacaoEnviada;
    }

    public void setNotificacaoEnviada(Boolean notificacaoEnviada) {
        this.notificacaoEnviada = notificacaoEnviada;
    }
}
