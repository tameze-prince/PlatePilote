package com.platepilote.platepilote.pantry.application.dto;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDate;

/**
 * Requête de création/mise à jour d'un article dans le garde-manger.
 */
@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PantryItemRequest {

    /** Nom de l'article (obligatoire). */
    @NotBlank(message = "Item name is required")
    private String name;

    /** Catégorie de l'article (ex. fruits, légumes, viande). */
    private String category;

    /** Quantité de l'article (doit être > 0). */
    @DecimalMin(value = "0.01", message = "Quantity must be greater than 0")
    private BigDecimal quantity;

    /** Unité de mesure (g, kg, ml, pièce, etc.) — obligatoire. */
    @NotBlank(message = "Unit is required")
    private String unit;

    /** Date de péremption de l'article. */
    private LocalDate expirationDate;
}
