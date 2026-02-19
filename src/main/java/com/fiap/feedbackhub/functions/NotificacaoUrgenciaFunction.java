package com.fiap.feedbackhub.functions;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fiap.feedbackhub.service.AvaliacaoService;
import com.fiap.feedbackhub.service.EmailService;
import com.microsoft.azure.functions.ExecutionContext;
import com.microsoft.azure.functions.annotation.FunctionName;
import com.microsoft.azure.functions.annotation.QueueTrigger;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Base64;
import java.util.Map;

/**
 * Azure Function para enviar notificações de urgência
 * Segunda função serverless - Responsabilidade: Processar fila e enviar notificações de avaliações críticas
 *
 * FLUXO:
 * 1. Recebe mensagem da fila Azure Storage Queue (avaliações críticas com nota 0-3)
 * 2. Decodifica a mensagem Base64
 * 3. Extrai dados da avaliação (ID, descrição, nota, urgência, data)
 * 4. Gera HTML formatado para o e-mail
 * 5. Envia e-mail de notificação para administradores via Azure Communication Services
 * 6. Marca avaliação como notificada no banco de dados
 */
public class NotificacaoUrgenciaFunction {

    private EmailService emailService;
    private AvaliacaoService avaliacaoService;
    private final ObjectMapper objectMapper = new ObjectMapper();

    /**
     * Função com trigger de fila para processar avaliações críticas
     * Trigger: Azure Storage Queue
     * Input: Mensagem da fila com dados da avaliação crítica
     * Output: E-mail de notificação para administradores
     */
    @FunctionName("notificarUrgencia")
    public void notificarUrgencia(
            @QueueTrigger(
                name = "message",
                queueName = "feedback-urgencia-queue",
                connection = "AZURE_STORAGE_CONNECTION_STRING"
            ) String message,
            final ExecutionContext context) {

        context.getLogger().info("=== Azure Function: Processando notificação de urgência ===");
        context.getLogger().info("Mensagem recebida da fila (length: " + message.length() + ")");

        try {
            // Inicializar Spring Context se necessário
            if (emailService == null || avaliacaoService == null) {
                context.getLogger().info("Inicializando Spring Context...");
                emailService = SpringContextLoader.getBean(EmailService.class);
                avaliacaoService = SpringContextLoader.getBean(AvaliacaoService.class);
                context.getLogger().info("Spring Context inicializado com sucesso");
            }

            // Decodificar mensagem Base64
            String decodedMessage;
            try {
                byte[] decodedBytes = Base64.getDecoder().decode(message);
                decodedMessage = new String(decodedBytes);
                context.getLogger().info("Mensagem decodificada: " + decodedMessage);
            } catch (Exception e) {
                // Se não estiver em Base64, usar a mensagem original
                decodedMessage = message;
                context.getLogger().info("Mensagem não está em Base64, usando original");
            }

            // Parsear JSON da mensagem
            @SuppressWarnings("unchecked")
            Map<String, Object> avaliacaoData = objectMapper.readValue(decodedMessage, Map.class);

            // Extrair dados
            Object avaliacaoIdObj = avaliacaoData.get("avaliacaoId");
            Long avaliacaoId = avaliacaoIdObj instanceof Integer ?
                ((Integer) avaliacaoIdObj).longValue() : (Long) avaliacaoIdObj;
            String descricao = (String) avaliacaoData.get("descricao");
            Object notaObj = avaliacaoData.get("nota");
            Integer nota = notaObj instanceof Integer ? (Integer) notaObj :
                ((Number) notaObj).intValue();
            String urgencia = (String) avaliacaoData.get("urgencia");
            String dataEnvio = (String) avaliacaoData.get("dataEnvio");

            context.getLogger().warning("⚠️ AVALIAÇÃO CRÍTICA DETECTADA!");
            context.getLogger().info("   - ID: " + avaliacaoId);
            context.getLogger().info("   - Nota: " + nota);
            context.getLogger().info("   - Urgência: " + urgencia);
            context.getLogger().info("   - Descrição: " + descricao);

            // Gerar HTML para o e-mail
            String htmlContent = gerarHtmlNotificacao(avaliacaoId, descricao, nota, urgencia, dataEnvio);

            // Enviar e-mail de notificação
            context.getLogger().info("Enviando e-mail de notificação para administradores...");
            String assunto = "⚠️ URGENTE: Avaliação Crítica Recebida - Nota " + nota;
            emailService.enviarNotificacaoUrgencia(assunto, htmlContent);

            context.getLogger().info("E-mail enviado com sucesso!");

            // Marcar avaliação como notificada
            avaliacaoService.marcarComoNotificada(avaliacaoId);
            context.getLogger().info("Avaliação marcada como notificada");

            context.getLogger().info("✅ Notificação de urgência processada com sucesso!");

        } catch (Exception e) {
            context.getLogger().severe("❌ Erro ao processar notificação de urgência: " + e.getMessage());
            e.printStackTrace();
            // A mensagem será reprocessada automaticamente pela fila
            throw new RuntimeException("Falha ao processar notificação", e);
        }
    }

    /**
     * Gera HTML formatado para o e-mail de notificação
     */
    private String gerarHtmlNotificacao(Long id, String descricao, Integer nota,
                                        String urgencia, String dataEnvio) {

        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm:ss");
        String dataFormatada = dataEnvio;

        try {
            LocalDateTime data = LocalDateTime.parse(dataEnvio);
            dataFormatada = data.format(formatter);
        } catch (Exception e) {
            // Mantém a data original se houver erro no parse
        }

        StringBuilder html = new StringBuilder();
        html.append("<!DOCTYPE html>");
        html.append("<html><head><meta charset='UTF-8'></head>");
        html.append("<body style='font-family: Arial, sans-serif; background-color: #f4f4f4; padding: 20px;'>");
        html.append("<div style='max-width: 600px; margin: 0 auto; background-color: white; border-radius: 10px; box-shadow: 0 0 10px rgba(0,0,0,0.1);'>");

        // Header
        html.append("<div style='background-color: #e74c3c; color: white; padding: 20px; border-radius: 10px 10px 0 0;'>");
        html.append("<h1 style='margin: 0; font-size: 24px;'>⚠️ AVALIAÇÃO CRÍTICA DETECTADA</h1>");
        html.append("</div>");

        // Body
        html.append("<div style='padding: 30px;'>");
        html.append("<p style='font-size: 16px; color: #333;'>Uma avaliação com nota crítica foi recebida e requer atenção imediata.</p>");

        // Detalhes em destaque
        html.append("<div style='background-color: #fff3cd; border-left: 4px solid #e74c3c; padding: 15px; margin: 20px 0;'>");
        html.append("<h2 style='color: #e74c3c; margin-top: 0;'>Detalhes da Avaliação</h2>");
        html.append("<p style='margin: 5px 0;'><strong>ID:</strong> ").append(id).append("</p>");
        html.append("<p style='margin: 5px 0;'><strong>Nota:</strong> <span style='color: #e74c3c; font-size: 24px; font-weight: bold;'>").append(nota).append("/10</span></p>");
        html.append("<p style='margin: 5px 0;'><strong>Urgência:</strong> <span style='color: #e74c3c; font-weight: bold;'>").append(urgencia).append("</span></p>");
        html.append("<p style='margin: 5px 0;'><strong>Data de Envio:</strong> ").append(dataFormatada).append("</p>");
        html.append("</div>");

        // Descrição
        html.append("<div style='background-color: #f8f9fa; padding: 15px; border-radius: 5px; margin: 20px 0;'>");
        html.append("<h3 style='color: #333; margin-top: 0;'>Descrição do Feedback:</h3>");
        html.append("<p style='color: #555; line-height: 1.6; white-space: pre-wrap;'>").append(descricao).append("</p>");
        html.append("</div>");

        // Call to action
        html.append("<div style='background-color: #e8f5e9; padding: 15px; border-radius: 5px; margin: 20px 0;'>");
        html.append("<h3 style='color: #2e7d32; margin-top: 0;'>⚡ Ação Requerida</h3>");
        html.append("<p style='color: #555;'>Por favor, analise esta avaliação e tome as ações necessárias o mais rápido possível.</p>");
        html.append("</div>");

        html.append("</div>");

        // Footer
        html.append("<div style='background-color: #f8f9fa; padding: 15px; border-radius: 0 0 10px 10px; text-align: center; color: #7f8c8d; font-size: 12px;'>");
        html.append("<p style='margin: 0;'>Notificação automática do FeedbackHub</p>");
        html.append("<p style='margin: 5px 0 0 0;'>Plataforma de Feedback - Tech Challenge Fase 4</p>");
        html.append("</div>");

        html.append("</div>");
        html.append("</body></html>");

        return html.toString();
    }
}

