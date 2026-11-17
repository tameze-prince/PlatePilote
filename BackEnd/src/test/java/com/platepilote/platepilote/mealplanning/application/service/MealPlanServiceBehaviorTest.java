package com.platepilote.platepilote.mealplanning.application.service;

import com.platepilote.platepilote.common.kernel.BusinessRuleViolationException;
import com.platepilote.platepilote.common.security.SecurityUtils;
import com.platepilote.platepilote.mealplanning.application.dto.MealPlanEntryRequest;
import com.platepilote.platepilote.mealplanning.application.dto.MealPlanRequest;
import com.platepilote.platepilote.mealplanning.domain.entity.MealPlan;
import com.platepilote.platepilote.mealplanning.domain.entity.MealPlanEntry;
import com.platepilote.platepilote.mealplanning.domain.entity.MealPlanMode;
import com.platepilote.platepilote.mealplanning.domain.repository.MealPlanEntryRepository;
import com.platepilote.platepilote.mealplanning.domain.repository.MealPlanRepository;
import com.platepilote.platepilote.mealplanning.domain.repository.SwapTrackingRepository;
import com.platepilote.platepilote.recipes.domain.repository.RecipeRepository;
import com.platepilote.platepilote.recommendation.domain.service.RecommendationEngine;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class MealPlanServiceBehaviorTest {

    @Mock private MealPlanRepository plans;
    @Mock private MealPlanEntryRepository entries;
    @Mock private RecipeRepository recipes;
    @Mock private RecommendationEngine recommendations;
    @Mock private SecurityUtils securityUtils;
    @Mock private SmartSwapService swaps;
    @Mock private SwapTrackingRepository swapTracking;

    private MealPlanService service;

    @BeforeEach
    void setUp() {
        service = new MealPlanService(
                plans, entries, recipes, recommendations, securityUtils, swaps, swapTracking);
    }

    @Test
    void createMealPlanRejectsEndDateBeforeStartDate() {
        LocalDate start = LocalDate.of(2026, 11, 17);
        MealPlanRequest request = MealPlanRequest.builder()
                .name("Invalid")
                .startDate(start)
                .endDate(start.minusDays(1))
                .build();

        assertThatThrownBy(() -> service.createMealPlan(UUID.randomUUID(), request))
                .isInstanceOf(BusinessRuleViolationException.class)
                .hasMessageContaining("End date");
    }

    @Test
    void addEntryRejectsDateOutsideThePlanRange() {
        UUID userId = UUID.randomUUID();
        UUID planId = UUID.randomUUID();
        MealPlan plan = plan(planId, userId);
        when(plans.findById(planId)).thenReturn(Optional.of(plan));

        MealPlanEntryRequest request = MealPlanEntryRequest.builder()
                .recipeId(UUID.randomUUID())
                .mealDate(plan.getStartDate().minusDays(1))
                .mealType("Dinner")
                .servings(2)
                .build();

        assertThatThrownBy(() -> service.addEntry(userId, planId, request))
                .isInstanceOf(BusinessRuleViolationException.class)
                .hasMessageContaining("within the plan");
    }

    @Test
    void activateMealPlanSetsActiveStatusAndSaves() {
        UUID userId = UUID.randomUUID();
        UUID planId = UUID.randomUUID();
        MealPlan plan = plan(planId, userId);
        when(plans.findById(planId)).thenReturn(Optional.of(plan));

        service.activateMealPlan(userId, planId);

        assertThat(plan.getStatus()).isEqualTo("ACTIVE");
        verify(plans).save(plan);
    }

    @Test
    void deleteMealPlanSoftDeletesAndSaves() {
        UUID userId = UUID.randomUUID();
        UUID planId = UUID.randomUUID();
        MealPlan plan = plan(planId, userId);
        when(plans.findById(planId)).thenReturn(Optional.of(plan));

        service.deleteMealPlan(userId, planId);

        assertThat(plan.isDeleted()).isTrue();
        verify(plans).save(plan);
    }

    @Test
    void removeEntryLoadsItsPlanThenDeletesTheEntry() {
        UUID userId = UUID.randomUUID();
        UUID planId = UUID.randomUUID();
        UUID entryId = UUID.randomUUID();
        MealPlanEntry entry = entry(entryId, planId);
        when(entries.findById(entryId)).thenReturn(Optional.of(entry));
        when(plans.findById(planId)).thenReturn(Optional.of(plan(planId, userId)));

        service.removeEntry(userId, entryId);

        verify(entries).delete(entry);
    }

    @Test
    void getSwapOptionsChecksThePlanThenDelegates() {
        UUID userId = UUID.randomUUID();
        UUID planId = UUID.randomUUID();
        UUID entryId = UUID.randomUUID();
        when(entries.findById(entryId)).thenReturn(Optional.of(entry(entryId, planId)));
        when(plans.findById(planId)).thenReturn(Optional.of(plan(planId, userId)));
        when(swaps.getSwapOptions(userId, entryId, 4)).thenReturn(List.of());

        assertThat(service.getSwapOptions(userId, entryId, 4)).isEmpty();

        verify(swaps).getSwapOptions(userId, entryId, 4);
    }

    @Test
    void setModeUpdatesAndPersistsThePlan() {
        UUID userId = UUID.randomUUID();
        UUID planId = UUID.randomUUID();
        MealPlan plan = plan(planId, userId);
        when(plans.findById(planId)).thenReturn(Optional.of(plan));
        when(entries.findByMealPlanId(planId)).thenReturn(List.of());
        when(recipes.findAllById(List.of())).thenReturn(List.of());

        var response = service.setMode(userId, planId, MealPlanMode.FAMILY);

        assertThat(plan.getMode()).isEqualTo("FAMILY");
        assertThat(response.getMode()).isEqualTo("FAMILY");
        verify(plans).save(plan);
    }

    private static MealPlan plan(UUID id, UUID userId) {
        MealPlan plan = MealPlan.builder()
                .userId(userId)
                .name("Test plan")
                .startDate(LocalDate.of(2026, 11, 16))
                .endDate(LocalDate.of(2026, 11, 22))
                .status("DRAFT")
                .build();
        plan.setId(id);
        return plan;
    }

    private static MealPlanEntry entry(UUID id, UUID planId) {
        MealPlanEntry entry = MealPlanEntry.builder()
                .mealPlanId(planId)
                .recipeId(UUID.randomUUID())
                .mealDate(LocalDate.of(2026, 11, 17))
                .mealType("Dinner")
                .servings(2)
                .build();
        entry.setId(id);
        return entry;
    }
}
