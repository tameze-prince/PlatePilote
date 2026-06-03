package com.platepilote.platepilote.common.dto;

/**
 * Réponse paginée pour les listes d'éléments.
 * <p>
 * Permet de retourner des résultats par page avec les métadonnées de pagination
 * (page courante, taille, nombre total d'éléments, nombre total de pages).
 * </p>
 *
 * <p>Exemple de réponse :</p>
 * <pre>{@code
 * {
 *   "content": [...],
 *   "page": 0,
 *   "size": 20,
 *   "totalElements": 150,
 *   "totalPages": 8,
 *   "last": false
 * }
 * }</pre>
 *
 * @param <T> type des éléments de la page
 */
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.io.Serializable;
import java.util.List;

@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PagedResponse<T> implements Serializable {

    private static final long serialVersionUID = 1L;

    /** Éléments de la page courante. */
    private List<T> content;
    /** Numéro de la page courante (commence à 0). */
    private int page;
    /** Nombre d'éléments par page. */
    private int size;
    /** Nombre total d'éléments toutes pages confondues. */
    private long totalElements;
    /** Nombre total de pages. */
    private int totalPages;
    /** {@code true} si c'est la dernière page. */
    private boolean last;

    /**
     * Crée une réponse paginée à partir des résultats.
     *
     * @param content       éléments de la page
     * @param page          numéro de page
     * @param size          taille de la page
     * @param totalElements nombre total d'éléments
     * @param <T>           type des éléments
     * @return réponse paginée
     */
    public static <T> PagedResponse<T> of(List<T> content, int page, int size, long totalElements) {
        int totalPages = (int) Math.ceil((double) totalElements / size);
        return PagedResponse.<T>builder()
                .content(content)
                .page(page)
                .size(size)
                .totalElements(totalElements)
                .totalPages(totalPages)
                .last(page >= totalPages - 1)
                .build();
    }
}
