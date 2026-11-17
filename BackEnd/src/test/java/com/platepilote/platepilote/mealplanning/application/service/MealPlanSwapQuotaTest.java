package com.platepilote.platepilote.mealplanning.application.service;

import com.platepilote.platepilote.common.kernel.BusinessRuleViolationException;
import com.platepilote.platepilote.common.kernel.ResourceNotFoundException;
import com.platepilote.platepilote.common.security.SecurityUtils;
import com.platepilote.platepilote.mealplanning.domain.entity.MealPlan;
import com.platepilote.platepilote.mealplanning.domain.entity.MealPlanEntry;
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
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

class MealPlanSwapQuotaTest {

    @Test
    void applySwapChecksQuotaBeforePersistingTheReplacement() {
        UUID userId = UUID.randomUUID();
        UUID planId = UUID.randomUUID();
        UUID entryId = UUID.randomUUID();
        UUID newRecipeId = UUID.randomUUID();
        LocalDate today = LocalDate.now();

        MealPlan plan = MealPlan.builder()
                .userId(userId)
                .name("Test plan")
                .startDate(today)
                .endDate(today.plusDays(6))
                .build();
        plan.setId(planId);

        MealPlanEntry entry = MealPlanEntry.builder()
                .mealPlanId(planId)
                .recipeId(UUID.randomUUID())
                .mealDate(today)
                .mealType("DINNER")
                .servings(1)
                .build();
        entry.setId(entryId);

        MealPlanRepository plans = mock(MealPlanRepository.class);
        MealPlanEntryRepository entries = mock(MealPlanEntryRepository.class);
        RecipeRepository recipes = mock(RecipeRepository.class);
        SmartSwapService swaps = mock(SmartSwapService.class);
        when(entries.findById(entryId)).thenReturn(Optional.of(entry));
        when(plans.findById(planId)).thenReturn(Optional.of(plan));
        when(recipes.findById(newRecipeId)).thenReturn(Optional.of(
                Recipe.builder().isPublic(true).enabled(true).build()));
        doThrow(new BusinessRuleViolationException("Free plan swap limit reached"))
                .when(swaps).assertSwapAllowed(userId);

        MealPlanService service = new MealPlanService(
                plans,
                entries,
                recipes,
                mock(RecommendationEngine.class),
                mock(SecurityUtils.class),
                swaps,
                mock(SwapTrackingRepository.class));

        assertThatThrownBy(() -> service.applySwap(userId, entryId, newRecipeId))
                .isInstanceOf(BusinessRuleViolationException.class);

        verify(swaps).assertSwapAllowed(userId);
        verify(entries, never()).save(any(MealPlanEntry.class));
    }

    @Test
    void deletedMealPlanCannotBeReadById() {
        UUID userId = UUID.randomUUID();
        UUID planId = UUID.randomUUID();
        MealPlan plan = MealPlan.builder()
                .userId(userId)
                .name("Deleted plan")
                .startDate(LocalDate.now())
                .endDate(LocalDate.now().plusDays(6))
                .build();
        plan.setId(planId);
        plan.softDelete();

        MealPlanRepository plans = mock(MealPlanRepository.class);
        when(plans.findById(planId)).thenReturn(Optional.of(plan));

        MealPlanService service = new MealPlanService(
                plans,
                mock(MealPlanEntryRepository.class),
                mock(RecipeRepository.class),
                mock(RecommendationEngine.class),
                mock(SecurityUtils.class),
                mock(SmartSwapService.class),
                mock(SwapTrackingRepository.class));

        assertThatThrownBy(() -> service.getMealPlanById(userId, planId))
                .isInstanceOf(ResourceNotFoundException.class);
    }
}
