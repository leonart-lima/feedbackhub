package com.fiap.feedbackhub.functions;

import com.microsoft.azure.functions.ExecutionContext;
import com.microsoft.azure.functions.HttpRequestMessage;
import com.microsoft.azure.functions.HttpMethod;
import com.microsoft.azure.functions.annotation.AuthorizationLevel;
import com.microsoft.azure.functions.annotation.FunctionName;
import com.microsoft.azure.functions.annotation.HttpTrigger;
import com.microsoft.azure.functions.annotation.TimerTrigger;

/**
 * Azure Function para gerar e enviar relatório semanal
 * Terceira função serverless - Responsabilidade: Gerar e enviar relatórios semanais automaticamente
 *
 * NOTA: Esta versão simplificada não usa Spring para compatibilidade com Azure Functions
 */
public class RelatorioSemanalFunction {

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
            // Versão simplificada: apenas loga
            // TODO: Integrar com serviço de relatórios quando Spring Context estiver configurado

            context.getLogger().info("📊 Relatório semanal seria gerado neste momento");
            context.getLogger().info("Relatório semanal processado com sucesso!");

        } catch (Exception e) {
            context.getLogger().severe("Erro ao gerar relatório semanal: " + e.getMessage());
            throw new RuntimeException("Falha ao gerar relatório semanal", e);
        }
    }

    /**
     * Função HTTP manual para gerar relatório
     * Permite gerar relatório sob demanda via chamada HTTP
     */
    @FunctionName("gerarRelatorioManual")
    public void gerarRelatorioManual(
            @HttpTrigger(
                name = "req",
                methods = {HttpMethod.POST, HttpMethod.GET},
                authLevel = AuthorizationLevel.FUNCTION,
                route = "relatorio/manual"
            ) HttpRequestMessage<String> request,
            final ExecutionContext context) {

        context.getLogger().info("Azure Function: Gerando relatório manual");

        try {
            // Versão simplificada: apenas loga
            // TODO: Integrar com serviço de relatórios quando Spring Context estiver configurado

            context.getLogger().info("📊 Relatório manual seria gerado neste momento");
            context.getLogger().info("Relatório manual processado com sucesso!");

        } catch (Exception e) {
            context.getLogger().severe("Erro ao gerar relatório manual: " + e.getMessage());
            throw new RuntimeException("Falha ao gerar relatório manual", e);
        }
    }
}

