package com.platepilote.platepilote.mealplanning.application.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.Instant;
import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MealPlanResponse {

    private UUID id;
    private String name;
    private LocalDate startDate;
    private LocalDate endDate;
    private String status;
    private List<MealPlanEntryResponse> entries;
    private Instant createdAt;
    private Instant updatedAt;

    @Getter
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class MealPlanEntryResponse {
        private UUID id;
        private UUID recipeId;
        private String recipeName;
        private LocalDate mealDate;
        private String mealType;
        private Integer servings;
        private String notes;
    }
}
