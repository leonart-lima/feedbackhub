package com.fiap.feedbackhub.repository;

import com.fiap.feedbackhub.enums.Urgencia;
import com.fiap.feedbackhub.model.Avaliacao;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

/**
 * Repository para acesso aos dados de Avaliacao
 * Data access layer do padrão MVC
 */
@Repository
public interface AvaliacaoRepository extends JpaRepository<Avaliacao, Long> {

    /**
     * Busca avaliações por urgência
     */
    List<Avaliacao> findByUrgencia(Urgencia urgencia);

    /**
     * Busca avaliações por período
     */
    List<Avaliacao> findByDataEnvioBetween(LocalDateTime inicio, LocalDateTime fim);

    /**
     * Busca avaliações críticas que ainda não tiveram notificação enviada
     */
    List<Avaliacao> findByUrgenciaAndNotificacaoEnviadaFalse(Urgencia urgencia);

    /**
     * Calcula a média das notas em um período
     */
    @Query("SELECT AVG(a.nota) FROM Avaliacao a WHERE a.dataEnvio BETWEEN :inicio AND :fim")
    Double calcularMediaNotas(@Param("inicio") LocalDateTime inicio, @Param("fim") LocalDateTime fim);

    /**
     * Conta avaliações por urgência em um período
     */
    @Query("SELECT COUNT(a) FROM Avaliacao a WHERE a.urgencia = :urgencia AND a.dataEnvio BETWEEN :inicio AND :fim")
    Long contarPorUrgencia(@Param("urgencia") Urgencia urgencia, @Param("inicio") LocalDateTime inicio, @Param("fim") LocalDateTime fim);

    /**
     * Conta total de avaliações em um período
     */
    Long countByDataEnvioBetween(LocalDateTime inicio, LocalDateTime fim);
}

