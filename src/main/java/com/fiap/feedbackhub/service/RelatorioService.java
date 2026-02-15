package com.fiap.feedbackhub.service;

import com.fiap.feedbackhub.dto.RelatorioSemanalDTO;
import com.fiap.feedbackhub.enums.Urgencia;
import com.fiap.feedbackhub.model.Avaliacao;
import com.fiap.feedbackhub.repository.AvaliacaoRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.time.DayOfWeek;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * Service para geração de relatórios
 * Business layer do padrão MVC
 */
@Service
@Slf4j
@RequiredArgsConstructor
public class RelatorioService {

    private final AvaliacaoRepository avaliacaoRepository;
    private final EmailService emailService;

    @Value("${relatorio.semanal.titulo}")
    private String tituloRelatorio;

    /**
     * Gera relatório semanal de avaliações
     */
    public RelatorioSemanalDTO gerarRelatorioSemanal() {
        log.info("Gerando relatório semanal");

        // Calcular período (última semana completa - segunda a domingo)
        LocalDateTime hoje = LocalDateTime.now();
        LocalDateTime fimSemana = hoje.with(DayOfWeek.SUNDAY).withHour(23).withMinute(59).withSecond(59);
        LocalDateTime inicioSemana = fimSemana.minusDays(6).withHour(0).withMinute(0).withSecond(0);

        // Buscar avaliações do período
        List<Avaliacao> avaliacoes = avaliacaoRepository.findByDataEnvioBetween(inicioSemana, fimSemana);

        // Calcular estatísticas
        Long total = (long) avaliacoes.size();
        Double media = avaliacaoRepository.calcularMediaNotas(inicioSemana, fimSemana);

        // Quantidade por dia
        Map<String, Long> quantidadePorDia = avaliacoes.stream()
                .collect(Collectors.groupingBy(
                        a -> a.getDataEnvio().toLocalDate().format(DateTimeFormatter.ISO_LOCAL_DATE),
                        Collectors.counting()
                ));

        // Quantidade por urgência
        Map<String, Long> quantidadePorUrgencia = avaliacoes.stream()
                .collect(Collectors.groupingBy(
                        a -> a.getUrgencia().toString(),
                        Collectors.counting()
                ));

        Long criticas = avaliacaoRepository.contarPorUrgencia(Urgencia.CRITICA, inicioSemana, fimSemana);
        Long medias = avaliacaoRepository.contarPorUrgencia(Urgencia.MEDIA, inicioSemana, fimSemana);
        Long positivas = avaliacaoRepository.contarPorUrgencia(Urgencia.POSITIVA, inicioSemana, fimSemana);

        // Criar DTO
        RelatorioSemanalDTO relatorio = new RelatorioSemanalDTO();
        relatorio.setTitulo(tituloRelatorio);
        relatorio.setDataInicio(inicioSemana);
        relatorio.setDataFim(fimSemana);
        relatorio.setTotalAvaliacoes(total);
        relatorio.setMediaNotas(media != null ? media : 0.0);
        relatorio.setQuantidadePorDia(quantidadePorDia);
        relatorio.setQuantidadePorUrgencia(quantidadePorUrgencia);
        relatorio.setAvaliacoesCriticas(criticas != null ? criticas : 0);
        relatorio.setAvaliacoesMedias(medias != null ? medias : 0);
        relatorio.setAvaliacoesPositivas(positivas != null ? positivas : 0);

        log.info("Relatório semanal gerado: {} avaliações, média {}", total, media);

        return relatorio;
    }

    /**
     * Envia relatório semanal por e-mail
     */
    public void enviarRelatorioSemanal() {
        try {
            RelatorioSemanalDTO relatorio = gerarRelatorioSemanal();
            String html = gerarHtmlRelatorio(relatorio);
            emailService.enviarRelatorioSemanal(relatorio.getTitulo(), html);
            log.info("Relatório semanal enviado por e-mail");
        } catch (Exception e) {
            log.error("Erro ao enviar relatório semanal: {}", e.getMessage(), e);
            throw new RuntimeException("Falha ao enviar relatório semanal", e);
        }
    }

    /**
     * Gera HTML formatado do relatório
     */
    private String gerarHtmlRelatorio(RelatorioSemanalDTO relatorio) {
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");

        StringBuilder html = new StringBuilder();
        html.append("<html><body style='font-family: Arial, sans-serif;'>");
        html.append("<h1 style='color: #2c3e50;'>").append(relatorio.getTitulo()).append("</h1>");
        html.append("<h3 style='color: #34495e;'>Período: ")
            .append(relatorio.getDataInicio().format(formatter))
            .append(" - ")
            .append(relatorio.getDataFim().format(formatter))
            .append("</h3>");

        html.append("<div style='background-color: #ecf0f1; padding: 20px; border-radius: 5px; margin: 20px 0;'>");
        html.append("<h2 style='color: #2c3e50;'>Resumo Geral</h2>");
        html.append("<p><strong>Total de Avaliações:</strong> ").append(relatorio.getTotalAvaliacoes()).append("</p>");
        html.append("<p><strong>Média das Notas:</strong> ").append(String.format("%.2f", relatorio.getMediaNotas())).append("</p>");
        html.append("</div>");

        html.append("<div style='background-color: #fff3cd; padding: 20px; border-radius: 5px; margin: 20px 0;'>");
        html.append("<h2 style='color: #2c3e50;'>Por Urgência</h2>");
        html.append("<p><strong style='color: #e74c3c;'>Críticas (0-3):</strong> ").append(relatorio.getAvaliacoesCriticas()).append("</p>");
        html.append("<p><strong style='color: #f39c12;'>Médias (4-6):</strong> ").append(relatorio.getAvaliacoesMedias()).append("</p>");
        html.append("<p><strong style='color: #27ae60;'>Positivas (7-10):</strong> ").append(relatorio.getAvaliacoesPositivas()).append("</p>");
        html.append("</div>");

        html.append("<div style='background-color: #d1ecf1; padding: 20px; border-radius: 5px; margin: 20px 0;'>");
        html.append("<h2 style='color: #2c3e50;'>Por Dia</h2>");
        html.append("<table style='width: 100%; border-collapse: collapse;'>");
        relatorio.getQuantidadePorDia().forEach((dia, quantidade) -> {
            html.append("<tr style='border-bottom: 1px solid #ccc;'>");
            html.append("<td style='padding: 8px;'>").append(dia).append("</td>");
            html.append("<td style='padding: 8px; text-align: right;'>").append(quantidade).append("</td>");
            html.append("</tr>");
        });
        html.append("</table>");
        html.append("</div>");

        html.append("<hr style='margin: 30px 0;'/>");
        html.append("<p style='color: #7f8c8d; font-size: 12px;'>Relatório gerado automaticamente pelo FeedbackHub</p>");
        html.append("</body></html>");

        return html.toString();
    }
}

