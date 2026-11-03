package com.platepilote.platepilote.mealplanning.application.service;

import com.platepilote.platepilote.common.kernel.ResourceNotFoundException;
import com.platepilote.platepilote.common.security.SecurityUtils;
import com.platepilote.platepilote.mealplanning.application.dto.MealPlanEntryRequest;
import com.platepilote.platepilote.mealplanning.domain.entity.MealPlan;
import com.platepilote.platepilote.mealplanning.domain.repository.MealPlanEntryRepository;
import com.platepilote.platepilote.mealplanning.domain.repository.MealPlanRepository;
import com.platepilote.platepilote.mealplanning.domain.repository.SwapTrackingRepository;
import com.platepilote.platepilote.recipes.domain.entity.Recipe;
import com.platepilote.platepilote.recipes.domain.repository.RecipeRepository;
import com.platepilote.platepilote.recommendation.domain.service.RecommendationEngine;
import org.junit.jupiter.api.Test;

import java.time.LocalDate;
import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

class MealPlanRecipeAccessTest {

    @Test
    void cannotAddAnotherUsersPrivateRecipeToOwnMealPlan() {
        UUID userId = UUID.randomUUID();
        UUID planId = UUID.randomUUID();
        UUID recipeId = UUID.randomUUID();
        LocalDate today = LocalDate.now();

        MealPlan plan = MealPlan.builder()
                .userId(userId)
                .name("Test plan")
                .startDate(today)
                .endDate(today.plusDays(6))
                .build();
        Recipe privateRecipe = Recipe.builder()
                .isPublic(false)
                .userId(UUID.randomUUID())
                .build();

        MealPlanRepository plans = mock(MealPlanRepository.class);
        RecipeRepository recipes = mock(RecipeRepository.class);
        when(plans.findById(planId)).thenReturn(Optional.of(plan));
        when(recipes.findById(recipeId)).thenReturn(Optional.of(privateRecipe));

        MealPlanService service = new MealPlanService(
                plans,
                mock(MealPlanEntryRepository.class),
                recipes,
                mock(RecommendationEngine.class),
                mock(SecurityUtils.class),
                mock(SmartSwapService.class),
                mock(SwapTrackingRepository.class));

        MealPlanEntryRequest request = MealPlanEntryRequest.builder()
                .recipeId(recipeId)
                .mealDate(today)
                .mealType("LUNCH")
                .servings(1)
                .build();

        assertThatThrownBy(() -> service.addEntry(userId, planId, request))
                .isInstanceOf(ResourceNotFoundException.class);
    }

    @Test
    void cannotAddDeletedPublicRecipeToMealPlan() {
        UUID userId = UUID.randomUUID();
        UUID planId = UUID.randomUUID();
        UUID recipeId = UUID.randomUUID();
        LocalDate today = LocalDate.now();

        MealPlan plan = MealPlan.builder()
                .userId(userId)
                .name("Test plan")
                .startDate(today)
                .endDate(today.plusDays(6))
                .build();
        Recipe deletedRecipe = Recipe.builder().isPublic(true).build();
        deletedRecipe.softDelete();

        MealPlanRepository plans = mock(MealPlanRepository.class);
        RecipeRepository recipes = mock(RecipeRepository.class);
        when(plans.findById(planId)).thenReturn(Optional.of(plan));
        when(recipes.findById(recipeId)).thenReturn(Optional.of(deletedRecipe));

        MealPlanService service = new MealPlanService(
                plans,
                mock(MealPlanEntryRepository.class),
                recipes,
                mock(RecommendationEngine.class),
                mock(SecurityUtils.class),
                mock(SmartSwapService.class),
                mock(SwapTrackingRepository.class));

        MealPlanEntryRequest request = MealPlanEntryRequest.builder()
                .recipeId(recipeId)
                .mealDate(today)
                .mealType("LUNCH")
                .servings(1)
                .build();

        assertThatThrownBy(() -> service.addEntry(userId, planId, request))
                .isInstanceOf(ResourceNotFoundException.class);
    }
}
