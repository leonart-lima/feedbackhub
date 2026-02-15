package com.fiap.feedbackhub.functions;

import com.fiap.feedbackhub.service.AvaliacaoService;
import com.fiap.feedbackhub.service.EmailService;
import com.microsoft.azure.functions.ExecutionContext;
import com.microsoft.azure.functions.annotation.FunctionName;
import com.microsoft.azure.functions.annotation.QueueTrigger;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Map;

/**
 * Azure Function para enviar notificações de urgência
 * Segunda função serverless - Responsabilidade: Processar fila e enviar notificações de avaliações críticas
 */
@Component
@Slf4j
public class NotificacaoUrgenciaFunction {

    @Autowired
    private EmailService emailService;

    @Autowired
    private AvaliacaoService avaliacaoService;

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

        context.getLogger().info("Azure Function: Processando notificação de urgência");
        context.getLogger().info("Mensagem recebida: " + message);

        try {
            // Parse da mensagem (JSON decodificado)
            Map<String, Object> dados = parseMensagem(message);

            Long avaliacaoId = Long.valueOf(dados.get("avaliacaoId").toString());
            String descricao = dados.get("descricao").toString();
            Integer nota = Integer.valueOf(dados.get("nota").toString());
            String urgencia = dados.get("urgencia").toString();
            String dataEnvio = dados.get("dataEnvio").toString();

            // Gerar HTML do e-mail
            String htmlEmail = gerarHtmlNotificacao(descricao, nota, urgencia, dataEnvio);

            // Enviar e-mail
            String assunto = "⚠️ URGENTE: Avaliação Crítica Recebida - Nota " + nota;
            emailService.enviarNotificacaoUrgencia(assunto, htmlEmail);

            // Marcar avaliação como notificada
            avaliacaoService.marcarComoNotificada(avaliacaoId);

            context.getLogger().info("Notificação de urgência enviada com sucesso para avaliação ID: " + avaliacaoId);

        } catch (Exception e) {
            context.getLogger().severe("Erro ao processar notificação de urgência: " + e.getMessage());
            // A mensagem será reprocessada automaticamente pela fila
            throw new RuntimeException("Falha ao processar notificação", e);
        }
    }

    /**
     * Parse simples da mensagem JSON
     */
    private Map<String, Object> parseMensagem(String message) {
        try {
            com.fasterxml.jackson.databind.ObjectMapper mapper = new com.fasterxml.jackson.databind.ObjectMapper();
            return mapper.readValue(message, Map.class);
        } catch (Exception e) {
            throw new RuntimeException("Erro ao fazer parse da mensagem", e);
        }
    }

    /**
     * Gera HTML formatado para notificação de urgência
     */
    private String gerarHtmlNotificacao(String descricao, Integer nota, String urgencia, String dataEnvio) {
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm:ss");
        LocalDateTime data = LocalDateTime.parse(dataEnvio);

        StringBuilder html = new StringBuilder();
        html.append("<html><body style='font-family: Arial, sans-serif;'>");
        html.append("<div style='background-color: #f8d7da; border: 2px solid #f5c6cb; padding: 20px; border-radius: 5px;'>");
        html.append("<h1 style='color: #721c24;'>⚠️ AVALIAÇÃO CRÍTICA RECEBIDA</h1>");
        html.append("<p style='font-size: 16px;'>Uma avaliação com nota crítica foi registrada no sistema e requer atenção imediata.</p>");
        html.append("</div>");

        html.append("<div style='background-color: #ffffff; border: 1px solid #dee2e6; padding: 20px; border-radius: 5px; margin-top: 20px;'>");
        html.append("<h2 style='color: #2c3e50;'>Detalhes da Avaliação</h2>");
        html.append("<table style='width: 100%; border-collapse: collapse;'>");

        html.append("<tr style='border-bottom: 1px solid #ccc;'>");
        html.append("<td style='padding: 10px; font-weight: bold; width: 30%;'>Descrição:</td>");
        html.append("<td style='padding: 10px;'>").append(descricao).append("</td>");
        html.append("</tr>");

        html.append("<tr style='border-bottom: 1px solid #ccc; background-color: #fff3cd;'>");
        html.append("<td style='padding: 10px; font-weight: bold;'>Nota:</td>");
        html.append("<td style='padding: 10px; color: #721c24; font-size: 20px; font-weight: bold;'>").append(nota).append(" / 10</td>");
        html.append("</tr>");

        html.append("<tr style='border-bottom: 1px solid #ccc;'>");
        html.append("<td style='padding: 10px; font-weight: bold;'>Urgência:</td>");
        html.append("<td style='padding: 10px; color: #e74c3c; font-weight: bold;'>").append(urgencia).append("</td>");
        html.append("</tr>");

        html.append("<tr>");
        html.append("<td style='padding: 10px; font-weight: bold;'>Data de Envio:</td>");
        html.append("<td style='padding: 10px;'>").append(data.format(formatter)).append("</td>");
        html.append("</tr>");

        html.append("</table>");
        html.append("</div>");

        html.append("<div style='margin-top: 20px; padding: 15px; background-color: #d1ecf1; border-radius: 5px;'>");
        html.append("<p style='margin: 0; color: #0c5460;'><strong>Ação Requerida:</strong> Por favor, analise esta avaliação e tome as medidas necessárias para resolver o problema reportado.</p>");
        html.append("</div>");

        html.append("<hr style='margin: 30px 0;'/>");
        html.append("<p style='color: #7f8c8d; font-size: 12px;'>Este é um e-mail automático gerado pelo FeedbackHub. Não responda a este e-mail.</p>");
        html.append("</body></html>");

        return html.toString();
    }
}

