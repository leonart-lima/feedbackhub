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
     */
    private void enviarEmail(String destinatario, String assunto, String conteudoHtml) {
        try {
            log.info("Preparando envio de e-mail para: {}", destinatario);

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

            // Enviar e-mail de forma assíncrona
            SyncPoller<EmailSendResult, EmailSendResult> poller = emailClient.beginSend(message);

            // Aguardar conclusão (timeout de 60 segundos)
            PollResponse<EmailSendResult> response = poller.waitForCompletion(Duration.ofSeconds(60));

            if (response != null && response.getValue() != null) {
                EmailSendResult result = response.getValue();

                if (result.getStatus() == EmailSendStatus.SUCCEEDED) {
                    log.info("✅ E-mail enviado com sucesso para: {} (ID: {})",
                            destinatario, result.getId());
                } else {
                    log.warn("⚠️ Status inesperado ao enviar e-mail para {}: {}",
                            destinatario, result.getStatus());
                }
            } else {
                log.warn("⚠️ Resposta vazia ao enviar e-mail para: {}", destinatario);
            }

        } catch (Exception e) {
            log.error("❌ Erro ao enviar e-mail para {}: {}", destinatario, e.getMessage(), e);
            throw new RuntimeException("Falha ao enviar e-mail via Azure Communication Services", e);
        }
    }
}

