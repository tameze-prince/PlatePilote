package com.platepilote.platepilote.mealplanning.application.service;

import com.platepilote.platepilote.common.kernel.BusinessRuleViolationException;
import com.platepilote.platepilote.mealplanning.domain.entity.MealPlanEntry;
import com.platepilote.platepilote.mealplanning.domain.repository.MealPlanEntryRepository;
import com.platepilote.platepilote.mealplanning.domain.repository.SwapTrackingRepository;
import com.platepilote.platepilote.authentication.domain.entity.OurUser;
import com.platepilote.platepilote.authentication.domain.repository.UserRepository;
import com.platepilote.platepilote.recipes.domain.entity.Recipe;
import com.platepilote.platepilote.recipes.domain.repository.RecipeRepository;
import org.springframework.data.domain.PageImpl;
import com.platepilote.platepilote.recommendation.domain.service.RecommendationEngine;
import com.platepilote.platepilote.subscription.application.service.EntitlementService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThatCode;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.verifyNoInteractions;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class SmartSwapServiceTest {

    @Mock private MealPlanEntryRepository mealPlanEntryRepository;
    @Mock private RecipeRepository recipeRepository;
    @Mock private RecommendationEngine recommendationEngine;
    @Mock private EntitlementService entitlementService;
    @Mock private UserRepository userRepository;
    @Mock private SwapTrackingRepository swapTrackingRepository;

    private SmartSwapService service;

    @BeforeEach
    void setUp() {
        service = new SmartSwapService(
                mealPlanEntryRepository,
                recipeRepository,
                recommendationEngine,
                entitlementService,
                userRepository,
                swapTrackingRepository);
    }

    @Test
    void quickSwapOptionsExcludeRecipesThatExceedThirtyMinutesAndAlreadyUsedRecipes() {
        UUID userId = UUID.randomUUID();
        UUID entryId = UUID.randomUUID();
        UUID planId = UUID.randomUUID();
        UUID alreadyUsedRecipeId = UUID.randomUUID();
        MealPlanEntry entry = MealPlanEntry.builder()
                .mealPlanId(planId)
                .recipeId(alreadyUsedRecipeId)
                .mealDate(LocalDate.of(2026, 11, 20))
                .mealType("Dinner")
                .servings(2)
                .notes("quick meal")
                .build();
        Recipe quick = recipe(UUID.randomUUID(), "Quick dinner", 25, true);
        Recipe tooSlow = recipe(UUID.randomUUID(), "Slow dinner", 45, true);
        Recipe alreadyUsed = recipe(alreadyUsedRecipeId, "Already planned", 15, true);
        Recipe disabled = recipe(UUID.randomUUID(), "Disabled", 10, false);

        when(mealPlanEntryRepository.findById(entryId)).thenReturn(Optional.of(entry));
        when(entitlementService.hasActiveEntitlement(
                userId, EntitlementService.PREMIUM_ENTITLEMENT)).thenReturn(true);
        when(recipeRepository.findByMealTypeAndIsPublicTrueAndEnabledTrueAndDeletedAtIsNull(
                eq("Dinner"), any(org.springframework.data.domain.Pageable.class)))
                .thenReturn(new PageImpl<>(List.of(quick, tooSlow, alreadyUsed, disabled)));
        when(mealPlanEntryRepository.findByMealPlanId(planId)).thenReturn(List.of(entry));

        var options = service.getSwapOptions(userId, entryId, 10);

        org.assertj.core.api.Assertions.assertThat(options)
                .extracting(SmartSwapService.SwapOption::recipeId)
                .containsExactly(quick.getId());
        org.assertj.core.api.Assertions.assertThat(options.getFirst().compatibility())
                .isCloseTo(2.0, org.assertj.core.api.Assertions.within(1.0e-9));
        verifyNoInteractions(swapTrackingRepository);
    }

    private static Recipe recipe(UUID id, String name, int totalTimeMinutes, boolean enabled) {
        Recipe recipe = Recipe.builder()
                .name(name)
                .description(name)
                .mealType("Dinner")
                .totalTimeMinutes(totalTimeMinutes)
                .estimatedCost(new BigDecimal("10.00"))
                .imageUrl("https://example.test/recipe.jpg")
                .confidenceScore(0.9)
                .enabled(enabled)
                .build();
        recipe.setId(id);
        return recipe;
    }

    @Test
    void freeUserIsRejectedWhenThreeSwapsWereAlreadyUsedInRollingWeek() {
        UUID userId = UUID.randomUUID();
        when(entitlementService.hasActiveEntitlement(
                userId, EntitlementService.PREMIUM_ENTITLEMENT)).thenReturn(false);
        when(userRepository.findByIdForUpdate(userId)).thenReturn(Optional.of(mock(OurUser.class)));
        when(swapTrackingRepository.countByUserIdAndSwappedAtAfter(eq(userId), any(Instant.class)))
                .thenReturn(3L);

        assertThatThrownBy(() -> service.assertSwapAllowed(userId))
                .isInstanceOf(BusinessRuleViolationException.class)
                .hasMessageContaining("3 swaps");

        verify(userRepository).findByIdForUpdate(userId);
        verify(swapTrackingRepository).countByUserIdAndSwappedAtAfter(eq(userId), any(Instant.class));
    }

    @Test
    void freeUserCanSwapWhileBelowWeeklyLimit() {
        UUID userId = UUID.randomUUID();
        when(entitlementService.hasActiveEntitlement(
                userId, EntitlementService.PREMIUM_ENTITLEMENT)).thenReturn(false);
        when(userRepository.findByIdForUpdate(userId)).thenReturn(Optional.of(mock(OurUser.class)));
        when(swapTrackingRepository.countByUserIdAndSwappedAtAfter(eq(userId), any(Instant.class)))
                .thenReturn(2L);

        assertThatCode(() -> service.assertSwapAllowed(userId)).doesNotThrowAnyException();
    }

    @Test
    void premiumUserDoesNotConsumeFreeTierQuota() {
        UUID userId = UUID.randomUUID();
        when(entitlementService.hasActiveEntitlement(
                userId, EntitlementService.PREMIUM_ENTITLEMENT)).thenReturn(true);

        assertThatCode(() -> service.assertSwapAllowed(userId)).doesNotThrowAnyException();

        verifyNoInteractions(userRepository, swapTrackingRepository);
    }
}
