package com.platepilote.platepilote.me.application.dto;

import com.fasterxml.jackson.annotation.JsonInclude;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

/**
 * DTOs pour les endpoints DSR (Data Subject Rights) RGPD.
 * Art. 15 (droit d'accès — export) et Art. 17 (droit à l'effacement — suppression).
 */
@JsonInclude(JsonInclude.Include.NON_NULL)
public final class MeDtos {

    private MeDtos() {}

    /** Réponse de l'endpoint GET /me/data-export — Art. 15 RGPD. */
    public record DataExportResponse(
            ProfileDto profile,
            List<PantryItemDto> pantry,
            List<RecipeDto> recipes,
            List<CookingHistoryDto> cookingHistory,
            List<AiInteractionDto> aiInteractions
    ) {}

    public record ProfileDto(
            String id,
            String email,
            String displayName,
            String locale,
            LocalDateTime createdAt
    ) {}

    public record PantryItemDto(
            String id,
            String name,
            String quantity,
            String unit,
            LocalDate expiresAt,
            LocalDateTime addedAt
    ) {}

    public record RecipeDto(
            String id,
            String title,
            String description,
            List<String> ingredients,
            String instructions,
            LocalDateTime createdAt
    ) {}

    public record CookingHistoryDto(
            String id,
            String recipeId,
            String recipeTitle,
            LocalDateTime cookedAt,
            Integer rating
    ) {}

    public record AiInteractionDto(
            String id,
            String prompt,
            String response,
            String model,
            LocalDateTime createdAt
    ) {}

    /** Réponse de l'endpoint DELETE /me/account — Art. 17 RGPD. */
    public record DeleteAccountResponse(
            String message,
            String scheduledDeletionDate
    ) {}
}
