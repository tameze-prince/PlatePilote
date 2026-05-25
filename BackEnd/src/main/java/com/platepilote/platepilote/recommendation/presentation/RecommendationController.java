package com.platepilote.platepilote.recommendation.presentation;

import com.platepilote.platepilote.common.dto.ApiResponse;
import com.platepilote.platepilote.common.security.SecurityUtils;
import com.platepilote.platepilote.recommendation.domain.entity.UserInteraction;
import com.platepilote.platepilote.recommendation.domain.repository.UserInteractionRepository;
import com.platepilote.platepilote.recommendation.domain.service.RecommendationEngine;
import com.platepilote.platepilote.recommendation.domain.service.RecommendationEngine.RecommendationResult;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.math.BigDecimal;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/v1/recommendations")
@RequiredArgsConstructor
public class RecommendationController {

    private final RecommendationEngine recommendationEngine;
    private final UserInteractionRepository userInteractionRepository;
    private final SecurityUtils securityUtils;

    @GetMapping
    public ResponseEntity<ApiResponse<List<RecipeRecommendation>>> getRecommendations(
            @AuthenticationPrincipal UserDetails userDetails,
            @RequestParam(defaultValue = "10") int limit) {
        UUID userId = securityUtils.getCurrentUserId(userDetails);
        List<RecommendationResult> results = recommendationEngine.getRecommendations(userId, limit);
        return ResponseEntity.ok(ApiResponse.success(toDto(results)));
    }

    @PostMapping("/quick-meal")
    public ResponseEntity<ApiResponse<List<RecipeRecommendation>>> getQuickMeal(
            @AuthenticationPrincipal UserDetails userDetails,
            @RequestParam(defaultValue = "30") int maxTime,
            @RequestParam(defaultValue = "3") int limit) {
        UUID userId = securityUtils.getCurrentUserId(userDetails);
        List<RecommendationResult> results = recommendationEngine.getQuickMeals(userId, maxTime, limit);
        return ResponseEntity.ok(ApiResponse.success(toDto(results)));
    }

    @PostMapping("/weekly-plan")
    public ResponseEntity<ApiResponse<List<List<RecipeRecommendation>>>> generateWeeklyPlan(
            @AuthenticationPrincipal UserDetails userDetails) {
        UUID userId = securityUtils.getCurrentUserId(userDetails);
        List<List<RecommendationResult>> weeklyPlan = recommendationEngine.generateWeeklyMealPlan(userId);
        List<List<RecipeRecommendation>> dtoPlan = weeklyPlan.stream()
                .map(this::toDto)
                .collect(Collectors.toList());
        return ResponseEntity.ok(ApiResponse.success(dtoPlan));
    }

    @PostMapping("/feedback")
    public ResponseEntity<ApiResponse<Void>> submitFeedback(
            @AuthenticationPrincipal UserDetails userDetails,
            @RequestBody FeedbackRequest request) {
        UUID userId = securityUtils.getCurrentUserId(userDetails);

        UserInteraction interaction = UserInteraction.builder()
                .userId(userId)
                .recipeId(request.recipeId())
                .interactionType(request.interactionType())
                .weight(request.weight() != null ? request.weight() : BigDecimal.ONE)
                .build();
        userInteractionRepository.save(interaction);

        return ResponseEntity.ok(ApiResponse.success("Feedback recorded", null));
    }

    public record FeedbackRequest(
            UUID recipeId,
            String interactionType,
            BigDecimal weight
    ) {}

    private List<RecipeRecommendation> toDto(List<RecommendationResult> results) {
        return results.stream()
                .map(r -> new RecipeRecommendation(
                        r.recipe().getId(),
                        r.recipe().getName(),
                        r.recipe().getDescription(),
                        r.recipe().getCuisineType(),
                        r.recipe().getMealType(),
                        r.recipe().getDifficulty(),
                        r.recipe().getTotalTimeMinutes(),
                        r.recipe().getServings(),
                        r.recipe().getImageUrl(),
                        r.finalScore(),
                        r.budgetScore(),
                        r.pantryScore(),
                        r.timeScore(),
                        r.preferenceScore(),
                        r.nutritionScore(),
                        r.varietyScore(),
                        r.locationScore(),
                        r.estimatedCost(),
                        r.currencyCode(),
                        r.countryCode(),
                        r.reasons(),
                        r.warnings()
                ))
                .collect(Collectors.toList());
    }

    public record RecipeRecommendation(
            UUID id,
            String name,
            String description,
            String cuisineType,
            String mealType,
            String difficulty,
            Integer totalTimeMinutes,
            Integer servings,
            String imageUrl,
            double score,
            double budgetScore,
            double pantryScore,
            double timeScore,
            double preferenceScore,
            double nutritionScore,
            double varietyScore,
            double locationScore,
            java.math.BigDecimal estimatedCost,
            String currencyCode,
            String countryCode,
            List<String> reasons,
            List<String> warnings
    ) {}
}
