package com.fiap.feedbackhub.service;

import com.sendgrid.Method;
import com.sendgrid.Request;
import com.sendgrid.Response;
import com.sendgrid.SendGrid;
import com.sendgrid.helpers.mail.Mail;
import com.sendgrid.helpers.mail.objects.Content;
import com.sendgrid.helpers.mail.objects.Email;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.io.IOException;

/**
 * Service para envio de e-mails usando SendGrid
 * Business layer do padrão MVC
 */
@Service
@Slf4j
public class EmailService {

    private final SendGrid sendGrid;
    private final Email fromEmail;

    @Value("${azure.email.admin-recipients}")
    private String adminEmails;

    @Value("${azure.email.report-recipients}")
    private String reportEmails;

    public EmailService(
            @Value("${azure.sendgrid.api-key}") String apiKey,
            @Value("${azure.sendgrid.from-email}") String fromEmailAddress,
            @Value("${azure.sendgrid.from-name}") String fromName) {

        this.sendGrid = new SendGrid(apiKey);
        this.fromEmail = new Email(fromEmailAddress, fromName);
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
     * Envia e-mail genérico
     */
    private void enviarEmail(String destinatario, String assunto, String conteudoHtml) {
        try {
            Email toEmail = new Email(destinatario);
            Content content = new Content("text/html", conteudoHtml);
            Mail mail = new Mail(fromEmail, assunto, toEmail, content);

            Request request = new Request();
            request.setMethod(Method.POST);
            request.setEndpoint("mail/send");
            request.setBody(mail.build());

            Response response = sendGrid.api(request);

            if (response.getStatusCode() >= 200 && response.getStatusCode() < 300) {
                log.info("E-mail enviado com sucesso para: {}", destinatario);
            } else {
                log.warn("Resposta inesperada ao enviar e-mail: {}", response.getStatusCode());
            }

        } catch (IOException e) {
            log.error("Erro ao enviar e-mail para {}: {}", destinatario, e.getMessage(), e);
            throw new RuntimeException("Falha ao enviar e-mail", e);
        }
    }
}

