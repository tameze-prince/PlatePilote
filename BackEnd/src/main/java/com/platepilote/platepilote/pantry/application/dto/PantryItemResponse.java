package com.platepilote.platepilote.pantry.application.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDate;
import java.util.UUID;

/**
 * Réponse contenant les détails d'un article du garde-manger.
 */
@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PantryItemResponse {

    /** Identifiant unique de l'article. */
    private UUID id;
    /** Nom de l'article. */
    private String name;
    /** Catégorie de l'article. */
    private String category;
    /** Quantité restante. */
    private BigDecimal quantity;
    /** Unité de mesure. */
    private String unit;
    /** Date de péremption. */
    private LocalDate expirationDate;
    /** Identifiant de l'ingrédient associé (résolu automatiquement). */
    private UUID ingredientId;
    /** Indique si l'article est périmé. */
    private boolean isExpired;
    /** Date de création. */
    private Instant createdAt;
    /** Date de dernière modification. */
    private Instant updatedAt;
}
