package com.fiap.feedbackhub.util;

import com.fiap.feedbackhub.enums.Urgencia;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

/**
 * Utilitário para classificar urgência baseado na nota
 */
@Component
public class UrgenciaClassificador {

    @Value("${feedback.urgencia.critica.nota-maxima}")
    private Integer notaMaximaCritica;

    @Value("${feedback.urgencia.media.nota-maxima}")
    private Integer notaMaximaMedia;

    /**
     * Classifica a urgência baseado na nota da avaliação
     *
     * @param nota Nota da avaliação (0-10)
     * @return Urgencia classificada
     */
    public Urgencia classificar(Integer nota) {
        if (nota <= notaMaximaCritica) {
            return Urgencia.CRITICA;
        } else if (nota <= notaMaximaMedia) {
            return Urgencia.MEDIA;
        } else {
            return Urgencia.POSITIVA;
        }
    }

    /**
     * Verifica se a avaliação é crítica
     */
    public boolean isCritica(Integer nota) {
        return nota <= notaMaximaCritica;
    }
}

