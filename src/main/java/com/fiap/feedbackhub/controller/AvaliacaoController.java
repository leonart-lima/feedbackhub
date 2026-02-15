package com.fiap.feedbackhub.controller;

import com.fiap.feedbackhub.dto.AvaliacaoRequestDTO;
import com.fiap.feedbackhub.dto.AvaliacaoResponseDTO;
import com.fiap.feedbackhub.service.AvaliacaoService;
import jakarta.validation.Valid;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

/**
 * Controller REST para gerenciar avaliações
 * Controller layer do padrão MVC
 */
@RestController
@RequestMapping("/api")
public class AvaliacaoController {

    private static final Logger log = LoggerFactory.getLogger(AvaliacaoController.class);
    private final AvaliacaoService avaliacaoService;

    public AvaliacaoController(AvaliacaoService avaliacaoService) {
        this.avaliacaoService = avaliacaoService;
    }

    /**
     * Endpoint para receber nova avaliação
     * POST /api/avaliacao
     */
    @PostMapping("/avaliacao")
    public ResponseEntity<AvaliacaoResponseDTO> criarAvaliacao(
            @Valid @RequestBody AvaliacaoRequestDTO requestDTO) {

        log.info("Recebendo nova avaliação: nota={}", requestDTO.getNota());

        try {
            AvaliacaoResponseDTO response = avaliacaoService.processarAvaliacao(requestDTO);
            return ResponseEntity.status(HttpStatus.CREATED).body(response);
        } catch (Exception e) {
            log.error("Erro ao processar avaliação: {}", e.getMessage(), e);
            AvaliacaoResponseDTO errorResponse = new AvaliacaoResponseDTO();
            errorResponse.setMensagem("Erro ao processar avaliação: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(errorResponse);
        }
    }

    /**
     * Endpoint de health check
     */
    @GetMapping("/health")
    public ResponseEntity<String> health() {
        return ResponseEntity.ok("FeedbackHub API está funcionando!");
    }
}

