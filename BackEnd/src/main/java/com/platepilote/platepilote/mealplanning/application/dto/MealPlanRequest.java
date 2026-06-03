package com.platepilote.platepilote.mealplanning.application.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.util.UUID;

/**
 * Requête de création d'un plan de repas.
 * <p>
 * Contient les informations de base nécessaires pour définir un nouveau plan :
 * un nom, une date de début et une date de fin.
 * </p>
 */
@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MealPlanRequest {

    /** Nom du plan de repas (ex : "Semaine 3 Janvier"). */
    @NotBlank(message = "Plan name is required")
    private String name;

    /** Date de début du plan de repas. */
    @NotNull(message = "Start date is required")
    private LocalDate startDate;

    /** Date de fin du plan de repas. */
    @NotNull(message = "End date is required")
    private LocalDate endDate;
}
