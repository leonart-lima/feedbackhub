package com.fiap.feedbackhub.service;

import com.fiap.feedbackhub.dto.AvaliacaoRequestDTO;
import com.fiap.feedbackhub.dto.AvaliacaoResponseDTO;
import com.fiap.feedbackhub.enums.Urgencia;
import com.fiap.feedbackhub.model.Avaliacao;
import com.fiap.feedbackhub.repository.AvaliacaoRepository;
import com.fiap.feedbackhub.util.UrgenciaClassificador;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Service principal para gerenciar avaliações
 * Business layer do padrão MVC
 */
@Service
@Slf4j
@RequiredArgsConstructor
public class AvaliacaoService {

    private final AvaliacaoRepository avaliacaoRepository;
    private final UrgenciaClassificador urgenciaClassificador;
    private final AzureQueueService azureQueueService;

    /**
     * Processa e salva uma nova avaliação
     */
    @Transactional
    public AvaliacaoResponseDTO processarAvaliacao(AvaliacaoRequestDTO requestDTO) {
        log.info("Processando nova avaliação com nota: {}", requestDTO.getNota());

        // Classificar urgência
        Urgencia urgencia = urgenciaClassificador.classificar(requestDTO.getNota());

        // Criar entidade
        Avaliacao avaliacao = new Avaliacao();
        avaliacao.setDescricao(requestDTO.getDescricao());
        avaliacao.setNota(requestDTO.getNota());
        avaliacao.setUrgencia(urgencia);
        avaliacao.setDataEnvio(LocalDateTime.now());
        avaliacao.setNotificacaoEnviada(false);

        // Salvar no banco
        avaliacao = avaliacaoRepository.save(avaliacao);
        log.info("Avaliação salva com ID: {} e urgência: {}", avaliacao.getId(), urgencia);

        // Se for crítica, enviar para fila de notificação
        if (urgencia == Urgencia.CRITICA) {
            try {
                Map<String, Object> mensagem = new HashMap<>();
                mensagem.put("avaliacaoId", avaliacao.getId());
                mensagem.put("descricao", avaliacao.getDescricao());
                mensagem.put("nota", avaliacao.getNota());
                mensagem.put("urgencia", avaliacao.getUrgencia().toString());
                mensagem.put("dataEnvio", avaliacao.getDataEnvio().toString());

                azureQueueService.enviarMensagem(mensagem);
                log.info("Avaliação crítica enviada para fila de notificação");
            } catch (Exception e) {
                log.error("Erro ao enviar avaliação crítica para fila: {}", e.getMessage(), e);
                // Continua mesmo se falhar o envio para fila
            }
        }

        // Criar resposta
        AvaliacaoResponseDTO responseDTO = new AvaliacaoResponseDTO();
        responseDTO.setId(avaliacao.getId());
        responseDTO.setDescricao(avaliacao.getDescricao());
        responseDTO.setNota(avaliacao.getNota());
        responseDTO.setUrgencia(avaliacao.getUrgencia());
        responseDTO.setDataEnvio(avaliacao.getDataEnvio());
        responseDTO.setMensagem("Avaliação registrada com sucesso!");

        return responseDTO;
    }

    /**
     * Busca todas as avaliações
     */
    public List<Avaliacao> buscarTodas() {
        return avaliacaoRepository.findAll();
    }

    /**
     * Busca avaliações por período
     */
    public List<Avaliacao> buscarPorPeriodo(LocalDateTime inicio, LocalDateTime fim) {
        return avaliacaoRepository.findByDataEnvioBetween(inicio, fim);
    }

    /**
     * Marca avaliação como notificada
     */
    @Transactional
    public void marcarComoNotificada(Long avaliacaoId) {
        avaliacaoRepository.findById(avaliacaoId).ifPresent(avaliacao -> {
            avaliacao.setNotificacaoEnviada(true);
            avaliacaoRepository.save(avaliacao);
            log.info("Avaliação {} marcada como notificada", avaliacaoId);
        });
    }
}

