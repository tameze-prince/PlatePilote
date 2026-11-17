package com.platepilote.platepilote.mealplanning.application.service;

import com.platepilote.platepilote.common.kernel.BusinessRuleViolationException;
import com.platepilote.platepilote.mealplanning.domain.repository.MealPlanEntryRepository;
import com.platepilote.platepilote.mealplanning.domain.repository.SwapTrackingRepository;
import com.platepilote.platepilote.recipes.domain.repository.RecipeRepository;
import com.platepilote.platepilote.recommendation.domain.service.RecommendationEngine;
import com.platepilote.platepilote.subscription.application.service.EntitlementService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.Instant;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThatCode;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.verifyNoInteractions;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class SmartSwapServiceTest {

    @Mock private MealPlanEntryRepository mealPlanEntryRepository;
    @Mock private RecipeRepository recipeRepository;
    @Mock private RecommendationEngine recommendationEngine;
    @Mock private EntitlementService entitlementService;
    @Mock private SwapTrackingRepository swapTrackingRepository;

    private SmartSwapService service;

    @BeforeEach
    void setUp() {
        service = new SmartSwapService(
                mealPlanEntryRepository,
                recipeRepository,
                recommendationEngine,
                entitlementService,
                swapTrackingRepository);
    }

    @Test
    void freeUserIsRejectedWhenThreeSwapsWereAlreadyUsedInRollingWeek() {
        UUID userId = UUID.randomUUID();
        when(entitlementService.hasActiveEntitlement(
                userId, EntitlementService.PREMIUM_ENTITLEMENT)).thenReturn(false);
        when(swapTrackingRepository.countByUserIdAndSwappedAtAfter(eq(userId), any(Instant.class)))
                .thenReturn(3L);

        assertThatThrownBy(() -> service.assertSwapAllowed(userId))
                .isInstanceOf(BusinessRuleViolationException.class)
                .hasMessageContaining("3 swaps");

        verify(swapTrackingRepository).countByUserIdAndSwappedAtAfter(eq(userId), any(Instant.class));
    }

    @Test
    void freeUserCanSwapWhileBelowWeeklyLimit() {
        UUID userId = UUID.randomUUID();
        when(entitlementService.hasActiveEntitlement(
                userId, EntitlementService.PREMIUM_ENTITLEMENT)).thenReturn(false);
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

        verifyNoInteractions(swapTrackingRepository);
    }
}
