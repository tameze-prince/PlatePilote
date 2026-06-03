package com.platepilote.platepilote.recipes.application.dto;

import jakarta.validation.Valid;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.util.List;

/**
 * Requête pour créer ou mettre à jour une recette.
 * <p>
 * Contient toutes les informations d'une recette : nom, description, temps,
 * portions, métadonnées (cuisine, repas, difficulté), ainsi que les listes
 * d'ingrédients et d'étapes.
 */
@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class RecipeRequest {

    /** Nom de la recette (obligatoire). */
    @NotBlank(message = "Recipe name is required")
    private String name;

    /** Description courte de la recette. */
    private String description;

    /** Temps de préparation en minutes (minimum 1). */
    @Min(value = 1, message = "Prep time must be at least 1 minute")
    private Integer prepTimeMinutes;

    /** Temps de cuisson en minutes (minimum 1). */
    @Min(value = 1, message = "Cook time must be at least 1 minute")
    private Integer cookTimeMinutes;

    /** Temps total en minutes (minimum 1). */
    @Min(value = 1, message = "Total time must be at least 1 minute")
    private Integer totalTimeMinutes;

    /** Nombre de portions (obligatoire, minimum 1). */
    @NotNull(message = "Servings is required")
    @Min(value = 1, message = "Servings must be at least 1")
    private Integer servings;

    /** Niveau de difficulté ("Facile", "Moyen", "Difficile"). */
    private String difficulty;

    /** Type de cuisine (ex: "Italienne", "Mexicaine", "Japonaise"). */
    private String cuisineType;

    /** Type de repas (ex: "Petit-déjeuner", "Dîner"). */
    private String mealType;

    /** URL de l'image de la recette. */
    private String imageUrl;

    /** Source de la recette (ex: "Grand-mère", "AllRecipes"). */
    private String source;

    /** Indique si la recette est visible par tous les utilisateurs. */
    @Builder.Default
    private Boolean isPublic = true;

    /** Liste des ingrédients de la recette. */
    @Valid
    private List<RecipeIngredientRequest> ingredients;

    /** Liste des étapes de la recette. */
    @Valid
    private List<RecipeStepRequest> steps;
}
