package com.fiap.feedbackhub.functions;

import com.microsoft.azure.functions.ExecutionContext;
import com.microsoft.azure.functions.annotation.FunctionName;
import com.microsoft.azure.functions.annotation.QueueTrigger;

/**
 * Azure Function para enviar notificações de urgência
 * Segunda função serverless - Responsabilidade: Processar fila e enviar notificações de avaliações críticas
 *
 * NOTA: Esta versão simplificada não usa Spring para compatibilidade com Azure Functions
 */
public class NotificacaoUrgenciaFunction {


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
        context.getLogger().info("Mensagem recebida da fila: " + message);

        try {
            // Versão simplificada: apenas loga a mensagem
            // TODO: Integrar com serviço de e-mail quando Spring Context estiver configurado

            context.getLogger().warning("⚠️ AVALIAÇÃO CRÍTICA detectada!");
            context.getLogger().info("Dados: " + message);
            context.getLogger().info("Notificação de urgência processada com sucesso");

        } catch (Exception e) {
            context.getLogger().severe("Erro ao processar notificação de urgência: " + e.getMessage());
            e.printStackTrace();
            // A mensagem será reprocessada automaticamente pela fila
            throw new RuntimeException("Falha ao processar notificação", e);
        }
    }
}

