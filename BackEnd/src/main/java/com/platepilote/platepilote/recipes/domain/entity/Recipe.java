package com.platepilote.platepilote.recipes.domain.entity;

/**
 * Entité représentant une recette de cuisine.
 * <p>
 * Une recette contient des informations de base (nom, description, temps,
 * portions), des métadonnées nutritionnelles et diététiques, des indicateurs
 * d'allergènes, et des informations de vérification.
 * <p>
 * Relations :
 * <ul>
 *   <li>Une recette a plusieurs {@link RecipeIngredient}</li>
 *   <li>Une recette a plusieurs {@link RecipeStep}</li>
 * </ul>
 */

import com.platepilote.platepilote.common.kernel.BaseEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.UUID;

@Entity
@Table(name = "recipes")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Recipe extends BaseEntity {

    @Column(nullable = false)
    private String name;

    @Column(columnDefinition = "TEXT")
    private String description;

    @Column(name = "prep_time_minutes")
    private Integer prepTimeMinutes;

    @Column(name = "cook_time_minutes")
    private Integer cookTimeMinutes;

    @Column(name = "total_time_minutes")
    private Integer totalTimeMinutes;

    @Column(nullable = false)
    private Integer servings;

    private String difficulty;  // "Easy", "Medium", "Hard"

    @Column(name = "cuisine_type")
    private String cuisineType;  // "Italian", "Mexican", "Japanese", etc.

    @Column(name = "meal_type")
    private String mealType;  // "Breakfast", "Lunch", "Dinner", "Snack"

    @Column(name = "image_url")
    private String imageUrl;

    private String source;  // Where the recipe came from

    @Column(name = "is_public")
    @Builder.Default
    private Boolean isPublic = true;  // true = visible to all users

    @Column(name = "user_id")
    private UUID userId;  // Who created this recipe (null = system recipe)

    // Nutritional metadata per serving
    @Column(name = "calories_per_serving")
    private Integer caloriesPerServing;

    @Column(name = "protein_per_serving")
    private Double proteinPerServing;

    @Column(name = "carbs_per_serving")
    private Double carbsPerServing;

    @Column(name = "fat_per_serving")
    private Double fatPerServing;

    @Column(name = "fiber_per_serving")
    private Double fiberPerServing;

    // Allergen flags
    @Column(name = "contains_gluten")
    private Boolean containsGluten;

    @Column(name = "contains_lactose")
    private Boolean containsLactose;

    @Column(name = "contains_nuts")
    private Boolean containsNuts;

    @Column(name = "contains_soy")
    private Boolean containsSoy;

    @Column(name = "contains_eggs")
    private Boolean containsEggs;

    @Column(name = "contains_fish")
    private Boolean containsFish;

    @Column(name = "contains_shellfish")
    private Boolean containsShellfish;

    // Dietary flags
    private Boolean vegan;
    private Boolean vegetarian;

    @Column(name = "halal_friendly")
    private Boolean halalFriendly;

    @Column(name = "kosher_friendly")
    private Boolean kosherFriendly;

    @Column(name = "low_carb")
    private Boolean lowCarb;

    @Column(name = "keto_friendly")
    private Boolean ketoFriendly;

    // Pricing
    @Column(name = "estimated_cost", precision = 10, scale = 2)
    private java.math.BigDecimal estimatedCost;

    @Column(name = "source_url")
    private String sourceUrl;

    @Column(name = "enabled")
    @Builder.Default
    private Boolean enabled = true;

    @Column(name = "verified")
    @Builder.Default
    private Boolean verified = false;

    @Column(name = "verification_status")
    @Builder.Default
    private String verificationStatus = "UNREVIEWED";

    @Column(name = "nutrition_source")
    private String nutritionSource;

    @Column(name = "allergen_source")
    private String allergenSource;

    @Column(name = "confidence_score")
    @Builder.Default
    private Double confidenceScore = 0.5;
}
