package com.platepilote.platepilote.recipes.application.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

/**
 * DTO représentant une recette complète en sortie.
 * <p>
 * Inclut les informations de base, les listes d'ingrédients et d'étapes,
 * ainsi que les dates de création et de modification.
 */
@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class RecipeResponse {

    /** Identifiant unique de la recette. */
    private UUID id;
    /** Nom de la recette. */
    private String name;
    /** Description courte. */
    private String description;
    /** Temps de préparation en minutes. */
    private Integer prepTimeMinutes;
    /** Temps de cuisson en minutes. */
    private Integer cookTimeMinutes;
    /** Temps total en minutes. */
    private Integer totalTimeMinutes;
    /** Nombre de portions. */
    private Integer servings;
    /** Niveau de difficulté. */
    private String difficulty;
    /** Type de cuisine. */
    private String cuisineType;
    /** Type de repas. */
    private String mealType;
    /** URL de l'image. */
    private String imageUrl;
    /** Source de la recette. */
    private String source;
    /** Visibilité publique. */
    private Boolean isPublic;
    /** Identifiant du créateur (null pour les recettes système). */
    private UUID userId;
    /** Liste des ingrédients. */
    private List<RecipeIngredientResponse> ingredients;
    /** Liste des étapes. */
    private List<RecipeStepResponse> steps;
    /** Date de création. */
    private Instant createdAt;
    /** Date de dernière modification. */
    private Instant updatedAt;

    @Getter
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class RecipeIngredientResponse {
        /** Identifiant de l'ingrédient. */
        private UUID id;
        /** Nom de l'ingrédient. */
        private String name;
        /** Quantité nécessaire. */
        private java.math.BigDecimal quantity;
        /** Unité de mesure. */
        private String unit;
        /** Note optionnelle. */
        private String notes;
        /** Ordre d'affichage. */
        private Integer sortOrder;
        /** Identifiant de l'ingrédient canonique (optionnel). */
        private UUID ingredientId;
    }

    @Getter
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class RecipeStepResponse {
        /** Identifiant de l'étape. */
        private UUID id;
        /** Numéro de l'étape (1, 2, 3...). */
        private Integer stepNumber;
        /** Instruction de cuisson. */
        private String instruction;
        /** Durée de l'étape en minutes (optionnelle). */
        private Integer durationMinutes;
    }
}
