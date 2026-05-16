package com.platepilote.platepilote.mealplanning.presentation;

import com.platepilote.platepilote.common.dto.ApiResponse;
import com.platepilote.platepilote.common.dto.PagedResponse;
import com.platepilote.platepilote.mealplanning.application.dto.MealPlanEntryRequest;
import com.platepilote.platepilote.mealplanning.application.dto.MealPlanRequest;
import com.platepilote.platepilote.mealplanning.application.dto.MealPlanResponse;
import com.platepilote.platepilote.mealplanning.application.service.MealPlanService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.UUID;

@RestController
@RequestMapping("/api/v1/meal-plans")
@RequiredArgsConstructor
public class MealPlanController {

    private final MealPlanService mealPlanService;

    @GetMapping
    public ResponseEntity<ApiResponse<PagedResponse<MealPlanResponse>>> getMyMealPlans(
            @AuthenticationPrincipal UserDetails userDetails,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        UUID userId = UUID.fromString(userDetails.getUsername());
        Pageable pageable = PageRequest.of(page, size, Sort.by("startDate").descending());
        PagedResponse<MealPlanResponse> plans = mealPlanService.getUserMealPlans(userId, pageable);
        return ResponseEntity.ok(ApiResponse.success(plans));
    }

    @GetMapping("/{mealPlanId}")
    public ResponseEntity<ApiResponse<MealPlanResponse>> getMealPlan(
            @AuthenticationPrincipal UserDetails userDetails,
            @PathVariable UUID mealPlanId) {
        UUID userId = UUID.fromString(userDetails.getUsername());
        MealPlanResponse plan = mealPlanService.getMealPlanById(userId, mealPlanId);
        return ResponseEntity.ok(ApiResponse.success(plan));
    }

    @PostMapping
    public ResponseEntity<ApiResponse<MealPlanResponse>> createMealPlan(
            @AuthenticationPrincipal UserDetails userDetails,
            @Valid @RequestBody MealPlanRequest request) {
        UUID userId = UUID.fromString(userDetails.getUsername());
        MealPlanResponse plan = mealPlanService.createMealPlan(userId, request);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success("Meal plan created", plan));
    }

    @PostMapping("/{mealPlanId}/entries")
    public ResponseEntity<ApiResponse<MealPlanResponse>> addEntry(
            @AuthenticationPrincipal UserDetails userDetails,
            @PathVariable UUID mealPlanId,
            @Valid @RequestBody MealPlanEntryRequest request) {
        UUID userId = UUID.fromString(userDetails.getUsername());
        MealPlanResponse plan = mealPlanService.addEntry(userId, mealPlanId, request);
        return ResponseEntity.ok(ApiResponse.success("Entry added", plan));
    }

    @DeleteMapping("/entries/{entryId}")
    public ResponseEntity<ApiResponse<Void>> removeEntry(
            @AuthenticationPrincipal UserDetails userDetails,
            @PathVariable UUID entryId) {
        UUID userId = UUID.fromString(userDetails.getUsername());
        mealPlanService.removeEntry(userId, entryId);
        return ResponseEntity.ok(ApiResponse.success("Entry removed", null));
    }

    @PostMapping("/{mealPlanId}/activate")
    public ResponseEntity<ApiResponse<Void>> activateMealPlan(
            @AuthenticationPrincipal UserDetails userDetails,
            @PathVariable UUID mealPlanId) {
        UUID userId = UUID.fromString(userDetails.getUsername());
        mealPlanService.activateMealPlan(userId, mealPlanId);
        return ResponseEntity.ok(ApiResponse.success("Meal plan activated", null));
    }

    @DeleteMapping("/{mealPlanId}")
    public ResponseEntity<ApiResponse<Void>> deleteMealPlan(
            @AuthenticationPrincipal UserDetails userDetails,
            @PathVariable UUID mealPlanId) {
        UUID userId = UUID.fromString(userDetails.getUsername());
        mealPlanService.deleteMealPlan(userId, mealPlanId);
        return ResponseEntity.ok(ApiResponse.success("Meal plan deleted", null));
    }
}
