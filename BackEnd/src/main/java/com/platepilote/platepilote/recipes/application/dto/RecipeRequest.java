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

@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class RecipeRequest {

    @NotBlank(message = "Recipe name is required")
    private String name;

    private String description;

    @Min(value = 1, message = "Prep time must be at least 1 minute")
    private Integer prepTimeMinutes;

    @Min(value = 1, message = "Cook time must be at least 1 minute")
    private Integer cookTimeMinutes;

    @Min(value = 1, message = "Total time must be at least 1 minute")
    private Integer totalTimeMinutes;

    @NotNull(message = "Servings is required")
    @Min(value = 1, message = "Servings must be at least 1")
    private Integer servings;

    private String difficulty;

    private String cuisineType;

    private String mealType;

    private String imageUrl;

    private String source;

    @Builder.Default
    private Boolean isPublic = true;

    @Valid
    private List<RecipeIngredientRequest> ingredients;

    @Valid
    private List<RecipeStepRequest> steps;
}
