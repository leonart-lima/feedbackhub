package com.fiap.feedbackhub.functions;

import com.fiap.feedbackhub.dto.AvaliacaoRequestDTO;
import com.fiap.feedbackhub.dto.AvaliacaoResponseDTO;
import com.fiap.feedbackhub.service.AvaliacaoService;
import com.microsoft.azure.functions.*;
import com.microsoft.azure.functions.annotation.AuthorizationLevel;
import com.microsoft.azure.functions.annotation.FunctionName;
import com.microsoft.azure.functions.annotation.HttpTrigger;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.Optional;

/**
 * Azure Function para receber avaliações via HTTP
 * Primeira função serverless - Responsabilidade: Receber e processar avaliações
 */
@Component
public class RecepcionarAvaliacaoFunction {

    private static final Logger log = LoggerFactory.getLogger(RecepcionarAvaliacaoFunction.class);

    @Autowired
    private AvaliacaoService avaliacaoService;

    /**
     * Função HTTP que recebe POST /api/avaliacao
     * Trigger: HTTP POST
     * Input: JSON com descricao e nota
     * Output: Confirmação e dados da avaliação salva
     */
    @FunctionName("receberAvaliacao")
    public HttpResponseMessage receberAvaliacao(
            @HttpTrigger(
                name = "req",
                methods = {HttpMethod.POST},
                authLevel = AuthorizationLevel.FUNCTION,
                route = "avaliacao"
            ) HttpRequestMessage<Optional<AvaliacaoRequestDTO>> request,
            final ExecutionContext context) {

        context.getLogger().info("Azure Function: Recebendo nova avaliação");

        try {
            // Validar body
            Optional<AvaliacaoRequestDTO> requestBody = request.getBody();
            if (requestBody.isEmpty()) {
                return request.createResponseBuilder(HttpStatus.BAD_REQUEST)
                        .body("Corpo da requisição está vazio")
                        .build();
            }

            AvaliacaoRequestDTO avaliacaoDTO = requestBody.get();

            // Validar campos obrigatórios
            if (avaliacaoDTO.getDescricao() == null || avaliacaoDTO.getDescricao().trim().isEmpty()) {
                return request.createResponseBuilder(HttpStatus.BAD_REQUEST)
                        .body("Campo 'descricao' é obrigatório")
                        .build();
            }

            if (avaliacaoDTO.getNota() == null) {
                return request.createResponseBuilder(HttpStatus.BAD_REQUEST)
                        .body("Campo 'nota' é obrigatório")
                        .build();
            }

            if (avaliacaoDTO.getNota() < 0 || avaliacaoDTO.getNota() > 10) {
                return request.createResponseBuilder(HttpStatus.BAD_REQUEST)
                        .body("Nota deve estar entre 0 e 10")
                        .build();
            }

            // Processar avaliação
            AvaliacaoResponseDTO response = avaliacaoService.processarAvaliacao(avaliacaoDTO);

            context.getLogger().info("Avaliação processada com sucesso: ID=" + response.getId());

            return request.createResponseBuilder(HttpStatus.OK)
                    .header("Content-Type", "application/json")
                    .body(response)
                    .build();

        } catch (Exception e) {
            context.getLogger().severe("Erro ao processar avaliação: " + e.getMessage());
            return request.createResponseBuilder(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Erro ao processar avaliação: " + e.getMessage())
                    .build();
        }
    }
}

