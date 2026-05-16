package com.platepilote.platepilote.recipes.application.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class RecipeResponse {

    private UUID id;
    private String name;
    private String description;
    private Integer prepTimeMinutes;
    private Integer cookTimeMinutes;
    private Integer totalTimeMinutes;
    private Integer servings;
    private String difficulty;
    private String cuisineType;
    private String mealType;
    private String imageUrl;
    private String source;
    private Boolean isPublic;
    private UUID userId;
    private List<RecipeIngredientResponse> ingredients;
    private List<RecipeStepResponse> steps;
    private Instant createdAt;
    private Instant updatedAt;

    @Getter
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class RecipeIngredientResponse {
        private UUID id;
        private String name;
        private java.math.BigDecimal quantity;
        private String unit;
        private String notes;
        private Integer sortOrder;
    }

    @Getter
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class RecipeStepResponse {
        private UUID id;
        private Integer stepNumber;
        private String instruction;
        private Integer durationMinutes;
    }
}
