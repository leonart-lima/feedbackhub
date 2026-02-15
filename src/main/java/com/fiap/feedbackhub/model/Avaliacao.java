package com.fiap.feedbackhub.model;

import com.fiap.feedbackhub.enums.Urgencia;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

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
@Data
@NoArgsConstructor
@AllArgsConstructor
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

    @PrePersist
    protected void onCreate() {
        if (dataEnvio == null) {
            dataEnvio = LocalDateTime.now();
        }
    }
}

