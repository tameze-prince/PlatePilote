package com.platepilote.platepilote.mealplanning.application.dto;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.util.UUID;

@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MealPlanEntryRequest {

    @NotNull(message = "Recipe ID is required")
    private UUID recipeId;

    @NotNull(message = "Meal date is required")
    private LocalDate mealDate;

    @NotBlank(message = "Meal type is required")
    private String mealType;

    @Min(value = 1, message = "Servings must be at least 1")
    @Builder.Default
    private Integer servings = 1;

    private String notes;
}
