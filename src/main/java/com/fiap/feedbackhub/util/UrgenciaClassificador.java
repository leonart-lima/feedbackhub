package com.fiap.feedbackhub.util;

import com.fiap.feedbackhub.enums.Urgencia;
import org.springframework.stereotype.Component;

/**
 * Utilitário para classificar urgência baseado na nota
 *
 * Regras de classificação:
 * - Nota 0-3: CRÍTICA (requer atenção imediata)
 * - Nota 4-6: MÉDIA (requer atenção)
 * - Nota 7-10: POSITIVA (feedback positivo)
 */
@Component
public class UrgenciaClassificador {

    // Constantes de classificação
    private static final int NOTA_MAXIMA_CRITICA = 3;
    private static final int NOTA_MAXIMA_MEDIA = 6;

    /**
     * Classifica a urgência baseado na nota da avaliação
     *
     * @param nota Nota da avaliação (0-10)
     * @return Urgencia classificada
     */
    public Urgencia classificar(Integer nota) {
        if (nota == null) {
            throw new IllegalArgumentException("Nota não pode ser nula");
        }

        if (nota <= NOTA_MAXIMA_CRITICA) {
            return Urgencia.CRITICA;
        } else if (nota <= NOTA_MAXIMA_MEDIA) {
            return Urgencia.MEDIA;
        } else {
            return Urgencia.POSITIVA;
        }
    }

    /**
     * Verifica se a avaliação é crítica
     */
    public boolean isCritica(Integer nota) {
        if (nota == null) {
            return false;
        }
        return nota <= NOTA_MAXIMA_CRITICA;
    }
}

