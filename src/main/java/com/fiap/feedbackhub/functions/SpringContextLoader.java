package com.fiap.feedbackhub.functions;

import com.fiap.feedbackhub.FeedbackHubApplication;
import org.springframework.boot.SpringApplication;
import org.springframework.context.ConfigurableApplicationContext;

/**
 * Classe utilitária para carregar o contexto Spring nas Azure Functions
 * Singleton pattern para garantir única instância do contexto
 */
public class SpringContextLoader {

    private static ConfigurableApplicationContext context;
    private static final Object lock = new Object();

    /**
     * Obtém ou cria o contexto Spring
     * Thread-safe com lazy initialization
     */
    public static ConfigurableApplicationContext getContext() {
        if (context == null) {
            synchronized (lock) {
                if (context == null) {
                    try {
                        // Configurar Spring Boot para Azure Functions
                        SpringApplication app = new SpringApplication(FeedbackHubApplication.class);

                        // Desabilitar banner para reduzir ruído nos logs
                        app.setBannerMode(org.springframework.boot.Banner.Mode.OFF);

                        // Configurar propriedades padrão se não existirem
                        java.util.Properties props = new java.util.Properties();

                        // Configurações de logging
                        props.setProperty("logging.level.root", "INFO");
                        props.setProperty("logging.level.com.fiap.feedbackhub", "DEBUG");

                        // Evitar inicialização de servidor web
                        props.setProperty("spring.main.web-application-type", "none");

                        app.setDefaultProperties(props);

                        context = app.run();

                        System.out.println("✅ Spring Context inicializado com sucesso para Azure Functions");
                    } catch (Exception e) {
                        System.err.println("❌ Erro ao inicializar Spring Context: " + e.getMessage());
                        e.printStackTrace();
                        throw new RuntimeException("Falha ao inicializar Spring Context", e);
                    }
                }
            }
        }
        return context;
    }

    /**
     * Obtém um bean do contexto Spring
     */
    public static <T> T getBean(Class<T> beanClass) {
        try {
            return getContext().getBean(beanClass);
        } catch (Exception e) {
            System.err.println("❌ Erro ao obter bean: " + beanClass.getSimpleName());
            e.printStackTrace();
            throw new RuntimeException("Falha ao obter bean: " + beanClass.getSimpleName(), e);
        }
    }

    /**
     * Verifica se o contexto está inicializado
     */
    public static boolean isInitialized() {
        return context != null && context.isActive();
    }
}

