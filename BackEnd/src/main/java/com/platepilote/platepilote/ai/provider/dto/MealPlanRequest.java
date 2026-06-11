package com.platepilote.platepilote.ai.provider.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;
import java.util.UUID;

/**
 * Request DTO for AI-powered meal plan generation.
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MealPlanRequest {

    private UUID userId;

    private int days;  // Number of days to plan (default: 7)

    private int mealsPerDay;  // Default: 3 (breakfast, lunch, dinner)

    private List<String> dietaryRestrictions;  // "vegetarian", "gluten-free", etc.

    private List<String> allergies;  // "nuts", "dairy", "shellfish", etc.

    private BigDecimal budgetMax;

    private String cuisinePreference;  // "Italian", "Mexican", etc.

    private List<String> excludedIngredients;  // Ingredients to avoid

    private int calorieTargetMin;  // Daily calorie target range

    private int calorieTargetMax;

    private Map<String, Object> nutritionGoals;  // Protein targets, carbs limits, etc.

    private List<UUID> existingRecipes;  // Recipes to incorporate

    private boolean respectPantryItems;  // Suggest meals based on what's in pantry
}