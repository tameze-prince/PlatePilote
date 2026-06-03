package com.platepilote.platepilote.mealplanning.application.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.Instant;
import java.time.LocalDate;
import java.math.BigDecimal;
import java.util.List;
import java.util.UUID;

/**
 * Réponse complète d'un plan de repas.
 * <p>
 * Inclut les métadonnées du plan, la liste des entrées (repas),
 * ainsi que des agrégats calculés (coût total, calories, etc.).
 * </p>
 */
@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MealPlanResponse {

    /** Identifiant unique du plan de repas. */
    private UUID id;

    /** Nom du plan de repas. */
    private String name;

    /** Date de début du plan. */
    private LocalDate startDate;

    /** Date de fin du plan. */
    private LocalDate endDate;

    /** Statut du plan : DRAFT, ACTIVE, COMPLETED, CANCELLED. */
    private String status;

    /** Mode du plan : STANDARD, WASTELESS, ENDOFMONTH, BUSYWEEK, FAMILY. */
    private String mode;

    /** Liste des entrées (repas) du plan. */
    private List<MealPlanEntryResponse> entries;

    /** Coût total estimé de tous les repas du plan. */
    private BigDecimal totalCost;

    /** Temps total de préparation cumulé (en minutes). */
    private Integer totalTime;

    /** Total de calories estimées pour le plan. */
    private Integer totalCalories;

    /** Nombre total de repas dans le plan. */
    private Integer mealCount;

    /** Coût moyen estimé par repas. */
    private BigDecimal costPerMeal;

    /** Date de création du plan. */
    private Instant createdAt;

    /** Date de dernière modification du plan. */
    private Instant updatedAt;

    /**
     * Représentation simplifiée d'une entrée (repas) dans la réponse.
     * <p>
     * Inclut les informations de base de la recette associée
     * ainsi que des indicateurs nutritionnels et de coût.
     * </p>
     */
    @Getter
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class MealPlanEntryResponse {

        /** Identifiant unique de l'entrée. */
        private UUID id;

        /** Identifiant de la recette associée. */
        private UUID recipeId;

        /** Nom de la recette. */
        private String recipeName;

        /** Date du repas. */
        private LocalDate mealDate;

        /** Type de repas : Breakfast, Lunch, Dinner, Snack. */
        private String mealType;

        /** Nombre de portions. */
        private Integer servings;

        /** Notes optionnelles sur le repas. */
        private String notes;

        /** Temps total de préparation de la recette (minutes). */
        private Integer totalTimeMinutes;

        /** Calories par portion de la recette. */
        private Integer caloriesPerServing;

        /** Coût estimé de la recette. */
        private BigDecimal estimatedCost;

        /** URL de l'image de la recette. */
        private String imageUrl;
    }
}
