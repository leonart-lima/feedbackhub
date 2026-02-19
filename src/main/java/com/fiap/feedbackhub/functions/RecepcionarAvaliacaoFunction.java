package com.fiap.feedbackhub.functions;

import com.fiap.feedbackhub.dto.AvaliacaoRequestDTO;
import com.fiap.feedbackhub.dto.AvaliacaoResponseDTO;
import com.fiap.feedbackhub.enums.Urgencia;
import com.microsoft.azure.functions.*;
import com.microsoft.azure.functions.annotation.AuthorizationLevel;
import com.microsoft.azure.functions.annotation.FunctionName;
import com.microsoft.azure.functions.annotation.HttpTrigger;

import java.time.LocalDateTime;
import java.util.Optional;

/**
 * Azure Function para receber avaliações via HTTP
 * Primeira função serverless - Responsabilidade: Receber e processar avaliações
 *
 * NOTA: Esta versão simplificada não usa Spring para compatibilidade com Azure Functions
 */
public class RecepcionarAvaliacaoFunction {


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
                        .body("{\"error\": \"Corpo da requisição está vazio\"}")
                        .build();
            }

            AvaliacaoRequestDTO avaliacaoDTO = requestBody.get();

            // Validar campos obrigatórios
            if (avaliacaoDTO.getDescricao() == null || avaliacaoDTO.getDescricao().trim().isEmpty()) {
                return request.createResponseBuilder(HttpStatus.BAD_REQUEST)
                        .body("{\"error\": \"Campo 'descricao' é obrigatório\"}")
                        .build();
            }

            if (avaliacaoDTO.getNota() == null) {
                return request.createResponseBuilder(HttpStatus.BAD_REQUEST)
                        .body("{\"error\": \"Campo 'nota' é obrigatório\"}")
                        .build();
            }

            if (avaliacaoDTO.getNota() < 0 || avaliacaoDTO.getNota() > 10) {
                return request.createResponseBuilder(HttpStatus.BAD_REQUEST)
                        .body("{\"error\": \"Nota deve estar entre 0 e 10\"}")
                        .build();
            }

            // Classificar urgência baseado na nota
            Urgencia urgencia;
            if (avaliacaoDTO.getNota() <= 3) {
                urgencia = Urgencia.CRITICA;
            } else if (avaliacaoDTO.getNota() <= 6) {
                urgencia = Urgencia.MEDIA;
            } else {
                urgencia = Urgencia.POSITIVA;
            }

            // Criar response
            AvaliacaoResponseDTO response = new AvaliacaoResponseDTO();
            response.setId(System.currentTimeMillis()); // ID temporário
            response.setDescricao(avaliacaoDTO.getDescricao());
            response.setNota(avaliacaoDTO.getNota());
            response.setUrgencia(urgencia);
            response.setDataEnvio(LocalDateTime.now());
            response.setMensagem("Avaliação recebida com sucesso! Urgência: " + urgencia);

            context.getLogger().info("Avaliação processada com sucesso: Nota=" + avaliacaoDTO.getNota() + ", Urgência=" + urgencia);

            return request.createResponseBuilder(HttpStatus.OK)
                    .header("Content-Type", "application/json")
                    .body(response)
                    .build();

        } catch (Exception e) {
            context.getLogger().severe("Erro ao processar avaliação: " + e.getMessage());
            e.printStackTrace();
            return request.createResponseBuilder(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("{\"error\": \"Erro ao processar avaliação: " + e.getMessage() + "\"}")
                    .build();
        }
    }
}

