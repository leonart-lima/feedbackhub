package com.fiap.feedbackhub.functions;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.SerializationFeature;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import com.fiap.feedbackhub.dto.RelatorioSemanalDTO;
import com.fiap.feedbackhub.service.RelatorioService;
import com.microsoft.azure.functions.ExecutionContext;
import com.microsoft.azure.functions.HttpRequestMessage;
import com.microsoft.azure.functions.HttpMethod;
import com.microsoft.azure.functions.HttpResponseMessage;
import com.microsoft.azure.functions.HttpStatus;
import com.microsoft.azure.functions.annotation.AuthorizationLevel;
import com.microsoft.azure.functions.annotation.FunctionName;
import com.microsoft.azure.functions.annotation.HttpTrigger;
import com.microsoft.azure.functions.annotation.TimerTrigger;

/**
 * Azure Function para gerar e enviar relatório semanal
 * Terceira função serverless - Responsabilidade: Gerar e enviar relatórios semanais automaticamente
 *
 * FLUXO AUTOMÁTICO (Timer):
 * 1. Executa toda segunda-feira às 9h00 UTC (6h Brasília)
 * 2. Busca avaliações da última semana no banco de dados
 * 3. Calcula estatísticas: total, média, quantidade por dia, quantidade por urgência
 * 4. Gera HTML formatado com gráficos e tabelas
 * 5. Envia relatório por e-mail para gestores via Azure Communication Services
 *
 * FLUXO MANUAL (HTTP):
 * 1. Recebe requisição GET/POST /api/relatorio/manual
 * 2. Gera relatório sob demanda
 * 3. Retorna JSON com os dados do relatório
 */
public class RelatorioSemanalFunction {

    private RelatorioService relatorioService;
    private ObjectMapper objectMapper;

    public RelatorioSemanalFunction() {
        // Configurar ObjectMapper para lidar com LocalDateTime
        this.objectMapper = new ObjectMapper();
        this.objectMapper.registerModule(new JavaTimeModule());
        this.objectMapper.disable(SerializationFeature.WRITE_DATES_AS_TIMESTAMPS);
    }

    /**
     * Função com timer trigger para gerar relatório semanal
     * Trigger: Timer (CRON expression)
     * Schedule: Toda segunda-feira às 9h00 (horário UTC)
     * CRON: "0 0 9 * * MON" -> segundos minutos horas dia mês dia-da-semana
     * Output: Relatório semanal enviado por e-mail
     */
    @FunctionName("gerarRelatorioSemanal")
    public void gerarRelatorioSemanal(
            @TimerTrigger(
                name = "timerInfo",
                schedule = "0 0 9 * * MON"  // Toda segunda às 9h UTC (6h Brasília)
            ) String timerInfo,
            final ExecutionContext context) {

        context.getLogger().info("=== Azure Function: Gerando relatório semanal automático ===");
        context.getLogger().info("Timer trigger executado: " + timerInfo);

        try {
            // Inicializar Spring Context se necessário
            if (relatorioService == null) {
                context.getLogger().info("Inicializando Spring Context...");
                relatorioService = SpringContextLoader.getBean(RelatorioService.class);
                context.getLogger().info("Spring Context inicializado com sucesso");
            }

            context.getLogger().info("📊 Gerando relatório semanal...");

            // Gerar e enviar relatório
            // Este serviço irá:
            // 1. Buscar avaliações da última semana
            // 2. Calcular estatísticas (média, total, por urgência, por dia)
            // 3. Gerar HTML formatado
            // 4. Enviar por e-mail para gestores
            relatorioService.enviarRelatorioSemanal();

            context.getLogger().info("✅ Relatório semanal gerado e enviado com sucesso!");
            context.getLogger().info("   - Destinatários notificados por e-mail");
            context.getLogger().info("   - Próxima execução: Segunda-feira às 9h UTC");

        } catch (Exception e) {
            context.getLogger().severe("❌ Erro ao gerar relatório semanal: " + e.getMessage());
            e.printStackTrace();
            throw new RuntimeException("Falha ao gerar relatório semanal", e);
        }
    }

    /**
     * Função HTTP manual para gerar relatório
     * Permite gerar relatório sob demanda via chamada HTTP
     * Útil para testes e relatórios fora do agendamento
     */
    @FunctionName("gerarRelatorioManual")
    public HttpResponseMessage gerarRelatorioManual(
            @HttpTrigger(
                name = "req",
                methods = {HttpMethod.POST, HttpMethod.GET},
                authLevel = AuthorizationLevel.FUNCTION,
                route = "relatorio/manual"
            ) HttpRequestMessage<String> request,
            final ExecutionContext context) {

        context.getLogger().info("=== Azure Function: Gerando relatório manual ===");

        try {
            // Inicializar Spring Context se necessário
            if (relatorioService == null) {
                context.getLogger().info("Inicializando Spring Context...");
                relatorioService = SpringContextLoader.getBean(RelatorioService.class);
                context.getLogger().info("Spring Context inicializado com sucesso");
            }

            context.getLogger().info("📊 Gerando relatório semanal sob demanda...");

            // Gerar relatório (sem enviar por e-mail, apenas retornar dados)
            RelatorioSemanalDTO relatorio = relatorioService.gerarRelatorioSemanal();

            context.getLogger().info("✅ Relatório gerado com sucesso!");
            context.getLogger().info("   - Total de avaliações: " + relatorio.getTotalAvaliacoes());
            context.getLogger().info("   - Média de notas: " + String.format("%.2f", relatorio.getMediaNotas()));
            context.getLogger().info("   - Avaliações críticas: " + relatorio.getAvaliacoesCriticas());
            context.getLogger().info("   - Avaliações médias: " + relatorio.getAvaliacoesMedias());
            context.getLogger().info("   - Avaliações positivas: " + relatorio.getAvaliacoesPositivas());

            // Serializar relatório manualmente para evitar problemas com LocalDateTime
            String jsonResponse = objectMapper.writeValueAsString(relatorio);

            // Retornar relatório como JSON
            return request.createResponseBuilder(HttpStatus.OK)
                    .header("Content-Type", "application/json")
                    .body(jsonResponse)
                    .build();

        } catch (Exception e) {
            context.getLogger().severe("❌ Erro ao gerar relatório manual: " + e.getMessage());
            e.printStackTrace();

            String errorJson = "{\"error\": \"Erro ao gerar relatório: " +
                e.getMessage().replace("\"", "'") + "\"}";

            return request.createResponseBuilder(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(errorJson)
                    .header("Content-Type", "application/json")
                    .build();
        }
    }
}

