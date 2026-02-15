package com.fiap.feedbackhub;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/**
 * Classe principal da aplicação FeedbackHub
 * Plataforma de Feedback Serverless com Azure Functions
 */
@SpringBootApplication
public class FeedbackHubApplication {

    public static void main(String[] args) {
        SpringApplication.run(FeedbackHubApplication.class, args);
    }
}

