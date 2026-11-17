package com.platepilote.platepilote.mealplanning.presentation;

import com.platepilote.platepilote.common.security.SecurityUtils;
import com.platepilote.platepilote.mealplanning.application.dto.MealPlanEntryRequest;
import com.platepilote.platepilote.mealplanning.application.dto.MealPlanRequest;
import com.platepilote.platepilote.mealplanning.application.service.MealPlanService;
import com.platepilote.platepilote.mealplanning.domain.entity.MealPlanMode;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.userdetails.UserDetails;

import java.time.LocalDate;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class MealPlanControllerTest {

    @Mock private MealPlanService mealPlanService;
    @Mock private SecurityUtils securityUtils;
    @Mock private UserDetails userDetails;

    @Test
    void delegatesAllAuthenticatedMealPlanEndpointsToTheService() {
        UUID userId = UUID.randomUUID();
        UUID planId = UUID.randomUUID();
        UUID entryId = UUID.randomUUID();
        UUID recipeId = UUID.randomUUID();
        LocalDate startDate = LocalDate.of(2026, 11, 16);
        when(securityUtils.getCurrentUserId(userDetails)).thenReturn(userId);

        MealPlanController controller = new MealPlanController(mealPlanService, securityUtils);

        assertThat(controller.getMyMealPlans(userDetails, 0, 20).getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(controller.getMealPlan(userDetails, planId).getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(controller.generateWeeklyPlan(userDetails, startDate, "STANDARD").getStatusCode())
                .isEqualTo(HttpStatus.OK);
        assertThat(controller.createMealPlan(userDetails, MealPlanRequest.builder()
                .name("Week 47").startDate(startDate).endDate(startDate.plusDays(6)).build())
                .getStatusCode()).isEqualTo(HttpStatus.CREATED);
        assertThat(controller.addEntry(userDetails, planId, MealPlanEntryRequest.builder()
                .recipeId(recipeId).mealDate(startDate).mealType("Dinner").servings(2).build())
                .getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(controller.removeEntry(userDetails, entryId).getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(controller.activateMealPlan(userDetails, planId).getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(controller.getSwapOptions(userDetails, entryId, 5).getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(controller.applySwap(userDetails, entryId, recipeId).getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(controller.setMode(userDetails, planId, "STANDARD").getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(controller.deleteMealPlan(userDetails, planId).getStatusCode()).isEqualTo(HttpStatus.OK);

        verify(mealPlanService).getUserMealPlans(eq(userId), any(Pageable.class));
        verify(mealPlanService).getMealPlanById(userId, planId);
        verify(mealPlanService).generateWeeklyPlan(userId, startDate, MealPlanMode.STANDARD);
        verify(mealPlanService).createMealPlan(eq(userId), any(MealPlanRequest.class));
        verify(mealPlanService).addEntry(eq(userId), eq(planId), any(MealPlanEntryRequest.class));
        verify(mealPlanService).removeEntry(userId, entryId);
        verify(mealPlanService).activateMealPlan(userId, planId);
        verify(mealPlanService).getSwapOptions(userId, entryId, 5);
        verify(mealPlanService).applySwap(userId, entryId, recipeId);
        verify(mealPlanService).setMode(userId, planId, MealPlanMode.STANDARD);
        verify(mealPlanService).deleteMealPlan(userId, planId);
    }
}
