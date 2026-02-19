package com.fiap.feedbackhub.service;

import com.azure.communication.email.EmailClient;
import com.azure.communication.email.EmailClientBuilder;
import com.azure.communication.email.models.EmailAddress;
import com.azure.communication.email.models.EmailMessage;
import com.azure.communication.email.models.EmailSendResult;
import com.azure.communication.email.models.EmailSendStatus;
import com.azure.core.util.polling.PollResponse;
import com.azure.core.util.polling.SyncPoller;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.time.Duration;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

/**
 * Service para envio de e-mails usando Azure Communication Services
 * Business layer do padrão MVC
 */
@Service
public class EmailService {

    private static final Logger log = LoggerFactory.getLogger(EmailService.class);

    private final EmailClient emailClient;
    private final String fromEmail;

    @Value("${azure.email.admin-recipients}")
    private String adminEmails;

    @Value("${azure.email.report-recipients}")
    private String reportEmails;

    public EmailService(
            @Value("${azure.communication.connection-string}") String connectionString,
            @Value("${azure.communication.from-email}") String fromEmailAddress) {

        this.emailClient = new EmailClientBuilder()
                .connectionString(connectionString)
                .buildClient();

        this.fromEmail = fromEmailAddress;

        log.info("EmailService inicializado com Azure Communication Services");
        log.info("E-mail remetente: {}", fromEmailAddress);
    }

    /**
     * Envia e-mail de notificação de urgência para administradores
     */
    public void enviarNotificacaoUrgencia(String assunto, String conteudoHtml) {
        String[] destinatarios = adminEmails.split(",");
        for (String destinatario : destinatarios) {
            enviarEmail(destinatario.trim(), assunto, conteudoHtml);
        }
    }

    /**
     * Envia relatório semanal por e-mail
     */
    public void enviarRelatorioSemanal(String assunto, String conteudoHtml) {
        String[] destinatarios = reportEmails.split(",");
        for (String destinatario : destinatarios) {
            enviarEmail(destinatario.trim(), assunto, conteudoHtml);
        }
    }

    /**
     * Envia e-mail genérico usando Azure Communication Services
     * Com retry logic para SSL handshake failures
     */
    private void enviarEmail(String destinatario, String assunto, String conteudoHtml) {
        int maxRetries = 3;
        int retryDelay = 2000; // 2 segundos

        for (int tentativa = 1; tentativa <= maxRetries; tentativa++) {
            try {
                log.info("📧 Preparando envio de e-mail para: {} (Tentativa {}/{})",
                        destinatario, tentativa, maxRetries);
                log.info("   De: {}", fromEmail);
                log.info("   Assunto: {}", assunto);

                // Criar lista de destinatários
                List<EmailAddress> toRecipients = Arrays.asList(
                    new EmailAddress(destinatario)
                );

                // Criar mensagem de e-mail
                EmailMessage message = new EmailMessage()
                    .setSenderAddress(fromEmail)
                    .setToRecipients(toRecipients)
                    .setSubject(assunto)
                    .setBodyHtml(conteudoHtml);

                log.info("📤 Iniciando envio via Azure Communication Services...");

                // Enviar e-mail de forma assíncrona com timeout
                SyncPoller<EmailSendResult, EmailSendResult> poller = emailClient.beginSend(message);

                log.info("⏳ Aguardando resposta do Azure (timeout: 20 segundos)...");

                // Aguardar conclusão com timeout reduzido
                PollResponse<EmailSendResult> response = poller.waitForCompletion(Duration.ofSeconds(20));

                log.info("📬 Resposta recebida do Azure");

                if (response != null && response.getValue() != null) {
                    EmailSendResult result = response.getValue();

                    log.info("   Status: {}", result.getStatus());
                    log.info("   Message ID: {}", result.getId());

                    if (result.getStatus() == EmailSendStatus.SUCCEEDED) {
                        log.info("✅ E-mail enviado com SUCESSO para: {} (ID: {})",
                                destinatario, result.getId());
                        return; // Sucesso, sair do loop
                    } else if (result.getStatus() == EmailSendStatus.FAILED) {
                        log.error("❌ FALHA ao enviar e-mail para {}: Status FAILED", destinatario);
                        if (result.getError() != null) {
                            log.error("   Erro: {}", result.getError().getMessage());
                        }
                    } else {
                        log.warn("⚠️ Status inesperado ao enviar e-mail para {}: {}",
                                destinatario, result.getStatus());
                    }
                } else {
                    log.warn("⚠️ Resposta vazia ao enviar e-mail para: {}", destinatario);
                }

                // Se chegou aqui, houve erro mas não exceção
                if (tentativa < maxRetries) {
                    log.info("⏳ Aguardando {} segundos antes da próxima tentativa...", retryDelay / 1000);
                    Thread.sleep(retryDelay);
                }

            } catch (Exception e) {
                boolean isSSLError = e.getMessage() != null &&
                                    (e.getMessage().contains("SSL") ||
                                     e.getMessage().contains("ssl") ||
                                     e.getMessage().contains("handshake") ||
                                     e.getClass().getName().contains("SSL"));

                if (isSSLError) {
                    log.error("❌ SSL/TLS Handshake Error na tentativa {}/{}", tentativa, maxRetries);
                    log.error("   Mensagem: {}", e.getMessage());
                    log.error("   Tipo: {}", e.getClass().getSimpleName());
                    log.error("💡 CAUSA: Problema de conectividade SSL com Azure Communication Services");
                } else {
                    log.error("❌ EXCEÇÃO ao enviar e-mail para {} (Tentativa {}/{}): {}",
                            destinatario, tentativa, maxRetries, e.getMessage());
                    log.error("   Tipo da exceção: {}", e.getClass().getName());
                }

                if (tentativa == maxRetries) {
                    log.error("   Stack trace completo:", e);
                    log.error("❌ Todas as {} tentativas falharam", maxRetries);
                    log.error("💡 SUGESTÕES:");
                    log.error("   1. Verifique AZURE_COMMUNICATION_CONNECTION_STRING no local.settings.json");
                    log.error("   2. Verifique se o domínio está verificado no Azure Portal");
                    log.error("   3. Verifique conectividade de rede");
                    log.error("   4. O Azure Communication Services pode estar com problemas");
                } else {
                    log.info("🔄 Tentando novamente em {} segundos...", retryDelay / 1000);
                    try {
                        Thread.sleep(retryDelay);
                        retryDelay *= 2; // Exponential backoff
                    } catch (InterruptedException ie) {
                        Thread.currentThread().interrupt();
                        log.error("❌ Retry interrompido");
                        break;
                    }
                }
            }
        }

        log.error("❌ FALHA FINAL: Não foi possível enviar e-mail para {} após {} tentativas",
                destinatario, maxRetries);
        log.warn("⚠️ O sistema continuará funcionando, mas o e-mail não foi enviado");
    }
}

