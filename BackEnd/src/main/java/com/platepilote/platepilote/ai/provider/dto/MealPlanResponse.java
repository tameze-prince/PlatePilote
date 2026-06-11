package com.platepilote.platepilote.ai.provider.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import java.util.UUID;

/**
 * Response DTO from AI-powered meal plan generation.
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MealPlanResponse {

    private UUID mealPlanId;

    private LocalDate startDate;

    private LocalDate endDate;

    private List<DayMeals> dailyMeals;

    private Map<String, Object> nutritionalSummary;  // Daily averages

    private BigDecimal estimatedTotalCost;

    private String providerUsed;  // "openai" or "gemini"

    private double confidenceScore;  // AI confidence in the plan

    private List<String> warnings;  // Unmet constraints or issues

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class DayMeals {
        private LocalDate date;
        private Meal breakfast;
        private Meal lunch;
        private Meal dinner;
        private List<Meal> snacks;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class Meal {
        private UUID recipeId;
        private String recipeName;
        private String imageUrl;
        private int servings;
        private int prepTimeMinutes;
        private Map<String, Object> nutrition;  // Per serving nutrition
        private BigDecimal estimatedCost;
        private List<String> usedPantryItems;  // Items from pantry used in this meal
    }
}