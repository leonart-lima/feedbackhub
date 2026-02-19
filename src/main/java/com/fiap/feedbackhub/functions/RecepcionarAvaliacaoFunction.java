package com.fiap.feedbackhub.functions;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fiap.feedbackhub.dto.AvaliacaoRequestDTO;
import com.fiap.feedbackhub.dto.AvaliacaoResponseDTO;
import com.fiap.feedbackhub.service.AvaliacaoService;
import com.microsoft.azure.functions.*;
import com.microsoft.azure.functions.annotation.AuthorizationLevel;
import com.microsoft.azure.functions.annotation.FunctionName;
import com.microsoft.azure.functions.annotation.HttpTrigger;

import java.util.Optional;

/**
 * Azure Function para receber avaliações via HTTP
 * Primeira função serverless - Responsabilidade: Receber e processar avaliações
 *
 * FLUXO:
 * 1. Recebe POST /api/avaliacao com {descricao, nota}
 * 2. Valida os dados de entrada
 * 3. Classifica a urgência baseada na nota (0-3: CRITICA, 4-6: MEDIA, 7-10: POSITIVA)
 * 4. Salva no banco de dados
 * 5. Se for CRITICA, envia para fila de notificação
 * 6. Retorna confirmação com dados da avaliação
 */
public class RecepcionarAvaliacaoFunction {

    private AvaliacaoService avaliacaoService;
    private ObjectMapper objectMapper = new ObjectMapper();


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

        context.getLogger().info("=== Azure Function: Recebendo nova avaliação ===");

        try {
            // Inicializar Spring Context se necessário
            if (avaliacaoService == null) {
                context.getLogger().info("Inicializando Spring Context...");
                avaliacaoService = SpringContextLoader.getBean(AvaliacaoService.class);
                context.getLogger().info("Spring Context inicializado com sucesso");
            }

            // Validar body
            Optional<AvaliacaoRequestDTO> requestBody = request.getBody();
            if (requestBody.isEmpty()) {
                context.getLogger().warning("Requisição sem corpo");
                return request.createResponseBuilder(HttpStatus.BAD_REQUEST)
                        .body("{\"error\": \"Corpo da requisição está vazio\"}")
                        .header("Content-Type", "application/json")
                        .build();
            }

            AvaliacaoRequestDTO avaliacaoDTO = requestBody.get();

            // Validar campos obrigatórios
            if (avaliacaoDTO.getDescricao() == null || avaliacaoDTO.getDescricao().trim().isEmpty()) {
                context.getLogger().warning("Campo 'descricao' ausente");
                return request.createResponseBuilder(HttpStatus.BAD_REQUEST)
                        .body("{\"error\": \"Campo 'descricao' é obrigatório\"}")
                        .header("Content-Type", "application/json")
                        .build();
            }

            if (avaliacaoDTO.getNota() == null) {
                context.getLogger().warning("Campo 'nota' ausente");
                return request.createResponseBuilder(HttpStatus.BAD_REQUEST)
                        .body("{\"error\": \"Campo 'nota' é obrigatório\"}")
                        .header("Content-Type", "application/json")
                        .build();
            }

            if (avaliacaoDTO.getNota() < 0 || avaliacaoDTO.getNota() > 10) {
                context.getLogger().warning("Nota fora do intervalo válido: " + avaliacaoDTO.getNota());
                return request.createResponseBuilder(HttpStatus.BAD_REQUEST)
                        .body("{\"error\": \"Nota deve estar entre 0 e 10\"}")
                        .header("Content-Type", "application/json")
                        .build();
            }

            context.getLogger().info("Validação OK - Processando avaliação: nota=" + avaliacaoDTO.getNota());

            // Processar avaliação usando o serviço
            // Este serviço irá:
            // 1. Classificar urgência
            // 2. Salvar no banco de dados
            // 3. Se for crítica, enviar para fila de notificação
            AvaliacaoResponseDTO response = avaliacaoService.processarAvaliacao(avaliacaoDTO);

            context.getLogger().info("✅ Avaliação processada com sucesso!");
            context.getLogger().info("   - ID: " + response.getId());
            context.getLogger().info("   - Nota: " + response.getNota());
            context.getLogger().info("   - Urgência: " + response.getUrgencia());

            if (response.getUrgencia() != null && response.getUrgencia().equals("CRITICA")) {
                context.getLogger().warning("⚠️ AVALIAÇÃO CRÍTICA detectada - enviada para fila de notificação");
            }

            // Serializar resposta manualmente para evitar ClassCastException
            String jsonResponse = objectMapper.writeValueAsString(response);

            return request.createResponseBuilder(HttpStatus.OK)
                    .header("Content-Type", "application/json")
                    .body(jsonResponse)
                    .build();

        } catch (Exception e) {
            context.getLogger().severe("❌ Erro ao processar avaliação: " + e.getMessage());
            e.printStackTrace();

            // Retornar erro como JSON simples
            String errorJson = "{\"error\": \"Erro interno ao processar avaliação: " +
                e.getMessage().replace("\"", "'") + "\"}";

            return request.createResponseBuilder(HttpStatus.INTERNAL_SERVER_ERROR)
                    .header("Content-Type", "application/json")
                    .body(errorJson)
                    .build();
        }
    }
}

