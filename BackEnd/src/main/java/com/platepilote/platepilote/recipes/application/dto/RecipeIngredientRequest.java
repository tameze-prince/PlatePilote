package com.platepilote.platepilote.recipes.application.dto;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

/**
 * Requête pour créer ou mettre à jour un ingrédient d'une recette.
 * <p>
 * Contient le nom, la quantité, l'unité, une note optionnelle et l'ordre d'affichage.
 */
@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class RecipeIngredientRequest {

    /** Nom de l'ingrédient (obligatoire). */
    @NotBlank(message = "Ingredient name is required")
    private String name;

    /** Quantité nécessaire (obligatoire, doit être > 0). */
    @NotNull(message = "Quantity is required")
    @DecimalMin(value = "0.01", message = "Quantity must be greater than 0")
    private BigDecimal quantity;

    /** Unité de mesure (obligatoire, ex: "g", "ml", "tbsp"). */
    @NotBlank(message = "Unit is required")
    private String unit;

    /** Note optionnelle (ex: "découpé en dés", "à température ambiante"). */
    private String notes;

    /** Ordre d'affichage dans la liste des ingrédients. */
    @Builder.Default
    private Integer sortOrder = 0;
}
