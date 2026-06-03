package com.platepilote.platepilote.mealplanning.application.dto;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.util.UUID;

/**
 * Requête de création ou modification d'une entrée dans un plan de repas.
 * <p>
 * Chaque entrée représente un repas individuel (ex : "Dîner du lundi : Poulet stir-fry").
 * Elle référence une recette, une date, un type de repas et un nombre de portions.
 * </p>
 */
@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MealPlanEntryRequest {

    /** Identifiant de la recette utilisée pour ce repas. */
    @NotNull(message = "Recipe ID is required")
    private UUID recipeId;

    /** Date à laquelle ce repas est planifié. */
    @NotNull(message = "Meal date is required")
    private LocalDate mealDate;

    /** Type de repas : Breakfast, Lunch, Dinner, Snack. */
    @NotBlank(message = "Meal type is required")
    private String mealType;

    /** Nombre de portions à préparer (minimum 1, valeur par défaut 1). */
    @Min(value = 1, message = "Servings must be at least 1")
    @Builder.Default
    private Integer servings = 1;

    /** Notes optionnelles (ex : "Doubler la recette pour les restes"). */
    private String notes;
}
