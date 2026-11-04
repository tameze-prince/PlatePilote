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
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDate;
import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class MealPlanServicePrivacyTest {

    @Mock private MealPlanRepository mealPlanRepository;
    @Mock private MealPlanEntryRepository mealPlanEntryRepository;
    @Mock private RecipeRepository recipeRepository;
    @Mock private RecommendationEngine recommendationEngine;
    @Mock private SecurityUtils securityUtils;
    @Mock private SmartSwapService smartSwapService;
    @Mock private SwapTrackingRepository swapTrackingRepository;

    private MealPlanService mealPlanService;

    @BeforeEach
    void setUp() {
        mealPlanService = new MealPlanService(
                mealPlanRepository,
                mealPlanEntryRepository,
                recipeRepository,
                recommendationEngine,
                securityUtils,
                smartSwapService,
                swapTrackingRepository
        );
    }

    @Test
    void cannotAddAnotherUsersPrivateRecipeToOwnMealPlan() {
        UUID currentUserId = UUID.randomUUID();
        UUID otherUserId = UUID.randomUUID();
        UUID mealPlanId = UUID.randomUUID();
        UUID recipeId = UUID.randomUUID();
        LocalDate today = LocalDate.now();

        MealPlan plan = MealPlan.builder()
                .userId(currentUserId)
                .name("My plan")
                .startDate(today)
                .endDate(today.plusDays(6))
                .status("DRAFT")
                .build();
        plan.setId(mealPlanId);

        Recipe privateRecipe = Recipe.builder()
                .name("Private recipe")
                .servings(2)
                .isPublic(false)
                .userId(otherUserId)
                .enabled(true)
                .build();
        privateRecipe.setId(recipeId);

        when(mealPlanRepository.findById(mealPlanId)).thenReturn(Optional.of(plan));
        when(recipeRepository.findById(recipeId)).thenReturn(Optional.of(privateRecipe));

        MealPlanEntryRequest request = MealPlanEntryRequest.builder()
                .recipeId(recipeId)
                .mealDate(today)
                .mealType("DINNER")
                .servings(2)
                .build();

        assertThatThrownBy(() -> mealPlanService.addEntry(currentUserId, mealPlanId, request))
                .isInstanceOf(ResourceNotFoundException.class);

        verify(mealPlanEntryRepository, never()).save(org.mockito.ArgumentMatchers.any());
    }
}
