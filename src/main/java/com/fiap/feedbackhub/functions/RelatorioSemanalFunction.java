package com.fiap.feedbackhub.functions;

import com.fiap.feedbackhub.service.RelatorioService;
import com.microsoft.azure.functions.ExecutionContext;
import com.microsoft.azure.functions.annotation.FunctionName;
import com.microsoft.azure.functions.annotation.TimerTrigger;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

/**
 * Azure Function para gerar e enviar relatório semanal
 * Terceira função serverless - Responsabilidade: Gerar e enviar relatórios semanais automaticamente
 */
@Component
public class RelatorioSemanalFunction {

    private static final Logger log = LoggerFactory.getLogger(RelatorioSemanalFunction.class);

    @Autowired
    private RelatorioService relatorioService;

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

        context.getLogger().info("Azure Function: Gerando relatório semanal");
        context.getLogger().info("Timer trigger: " + timerInfo);

        try {
            // Gerar e enviar relatório
            relatorioService.enviarRelatorioSemanal();

            context.getLogger().info("Relatório semanal gerado e enviado com sucesso!");

        } catch (Exception e) {
            context.getLogger().severe("Erro ao gerar relatório semanal: " + e.getMessage());
            throw new RuntimeException("Falha ao gerar relatório semanal", e);
        }
    }

    /**
     * Função adicional para gerar relatório sob demanda (para testes)
     * Pode ser chamada manualmente via portal Azure
     */
    @FunctionName("gerarRelatorioManual")
    public void gerarRelatorioManual(
            @TimerTrigger(
                name = "timerInfo",
                schedule = "0 */30 * * * *"  // A cada 30 minutos (desabilitado por padrão)
            ) String timerInfo,
            final ExecutionContext context) {

        context.getLogger().info("Azure Function: Gerando relatório manual");

        try {
            relatorioService.enviarRelatorioSemanal();
            context.getLogger().info("Relatório manual gerado e enviado!");

        } catch (Exception e) {
            context.getLogger().severe("Erro ao gerar relatório manual: " + e.getMessage());
        }
    }
}

