package com.platepilote.platepilote.recipes.domain.entity;

/**
 * RECIPE ENTITY - DATABASE TABLE: recipes
 * ==========================================
 * 
 * WHAT IT IS:
 * Represents a cooking recipe with its basic information.
 * 
 * RELATIONSHIPS:
 * - One Recipe has MANY RecipeIngredients (one-to-many)
 * - One Recipe has MANY RecipeSteps (one-to-many)
 * - One Recipe can have MANY RecipeRatings (one-to-many)
 * - One Recipe can be in MANY MealPlanEntries (one-to-many)
 * 
 * FIELDS:
 * - name: Recipe title (e.g., "Chicken Stir Fry")
 * - description: Brief description of the recipe
 * - prepTimeMinutes: Time to prepare ingredients
 * - cookTimeMinutes: Time to cook
 * - totalTimeMinutes: prep + cook time
 * - servings: How many people this recipe serves
 * - difficulty: "Easy", "Medium", "Hard"
 * - cuisineType: "Italian", "Mexican", "Japanese", etc.
 * - mealType: "Breakfast", "Lunch", "Dinner", "Snack"
 * - imageUrl: URL to recipe photo (stored in Cloudinary/R2)
 * - source: Where the recipe came from (e.g., "Grandma", "AllRecipes")
 * - isPublic: Whether other users can see this recipe
 * - userId: Who created this recipe (null for system recipes)
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
    private Boolean isPublic = true;  // true = visible to all users

    @Column(name = "user_id")
    private UUID userId;  // Who created this recipe (null = system recipe)
}
