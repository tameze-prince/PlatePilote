package com.platepilote.platepilote.recipes.application.dto;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

/**
 * Requête pour créer ou mettre à jour une étape d'une recette.
 * <p>
 * Contient le numéro d'étape, l'instruction de cuisson et la durée optionnelle.
 */
@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class RecipeStepRequest {

    /** Numéro de l'étape dans le déroulé de la recette (obligatoire, >= 1). */
    @NotNull(message = "Step number is required")
    @Min(value = 1, message = "Step number must be at least 1")
    private Integer stepNumber;

    /** Instruction de cuisson (obligatoire). */
    @NotBlank(message = "Instruction is required")
    private String instruction;

    /** Durée estimée de cette étape en minutes (optionnelle). */
    private Integer durationMinutes;
}
