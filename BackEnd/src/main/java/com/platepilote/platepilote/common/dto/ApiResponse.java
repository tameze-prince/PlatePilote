package com.platepilote.platepilote.common.dto;

/**
 * Réponse API standardisée pour tous les endpoints REST.
 * <p>
 * Format succès :
 * <pre>{@code
 * {
 *   "success": true,
 *   "message": "Opération réussie",
 *   "data": { ... },
 *   "timestamp": "2024-01-15T10:30:00Z"
 * }
 * }</pre>
 * Format erreur :
 * <pre>{@code
 * {
 *   "success": false,
 *   "message": "Ressource introuvable",
 *   "timestamp": "2024-01-15T10:30:00Z"
 * }
 * }</pre>
 * </p>
 *
 * @param <T> type des données de la réponse
 */
import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.Instant;

@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
@JsonInclude(JsonInclude.Include.NON_NULL)
public class ApiResponse<T> {

    /** Indique si l'opération a réussi. */
    private boolean success;
    /** Message lisible pour l'utilisateur. */
    private String message;
    /** Données de la réponse (type générique). */
    private T data;
    /** Horodatage de génération de la réponse. */
    private Instant timestamp;

    /**
     * Crée une réponse de succès avec des données.
     *
     * @param data données à retourner
     * @param <T>  type des données
     * @return réponse de succès
     */
    public static <T> ApiResponse<T> success(T data) {
        return ApiResponse.<T>builder()
                .success(true)
                .data(data)
                .timestamp(Instant.now())
                .build();
    }

    /**
     * Crée une réponse de succès avec un message personnalisé et des données.
     *
     * @param message message de succès
     * @param data    données à retourner
     * @param <T>     type des données
     * @return réponse de succès
     */
    public static <T> ApiResponse<T> success(String message, T data) {
        return ApiResponse.<T>builder()
                .success(true)
                .message(message)
                .data(data)
                .timestamp(Instant.now())
                .build();
    }

    /**
     * Crée une réponse d'erreur avec un message.
     *
     * @param message description de l'erreur
     * @param <T>     type des données (généralement vide)
     * @return réponse d'erreur
     */
    public static <T> ApiResponse<T> error(String message) {
        return ApiResponse.<T>builder()
                .success(false)
                .message(message)
                .timestamp(Instant.now())
                .build();
    }
}
