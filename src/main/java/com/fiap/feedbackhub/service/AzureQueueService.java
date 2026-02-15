package com.fiap.feedbackhub.service;

import com.azure.storage.queue.QueueClient;
import com.azure.storage.queue.QueueClientBuilder;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.util.Base64;

/**
 * Service para gerenciar filas do Azure Storage Queue
 * Business layer do padrão MVC
 */
@Service
public class AzureQueueService {

    private static final Logger log = LoggerFactory.getLogger(AzureQueueService.class);

    private final QueueClient queueClient;
    private final ObjectMapper objectMapper;

    public AzureQueueService(
            @Value("${azure.storage.connection-string}") String connectionString,
            @Value("${azure.storage.queue.urgencia-name}") String queueName,
            ObjectMapper objectMapper) {

        this.objectMapper = objectMapper;

        try {
            this.queueClient = new QueueClientBuilder()
                    .connectionString(connectionString)
                    .queueName(queueName)
                    .buildClient();

            // Cria a fila se não existir
            try {
                queueClient.createIfNotExists();
                log.info("Fila '{}' verificada/criada com sucesso", queueName);
            } catch (Exception ex) {
                log.warn("Fila '{}' já existe ou erro ao criar: {}", queueName, ex.getMessage());
            }
        } catch (Exception e) {
            log.error("Erro ao inicializar Azure Queue: {}", e.getMessage());
            throw new RuntimeException("Falha ao conectar com Azure Storage Queue", e);
        }
    }

    /**
     * Envia uma mensagem para a fila
     */
    public void enviarMensagem(Object mensagem) {
        try {
            String json = objectMapper.writeValueAsString(mensagem);
            String encodedMessage = Base64.getEncoder().encodeToString(json.getBytes());
            queueClient.sendMessage(encodedMessage);
            log.info("Mensagem enviada para a fila com sucesso");
        } catch (Exception e) {
            log.error("Erro ao enviar mensagem para a fila: {}", e.getMessage(), e);
            throw new RuntimeException("Falha ao enviar mensagem para a fila", e);
        }
    }
}

