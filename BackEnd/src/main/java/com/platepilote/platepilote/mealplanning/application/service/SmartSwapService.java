package com.platepilote.platepilote.mealplanning.application.service;

import com.platepilote.platepilote.mealplanning.domain.entity.MealPlanEntry;
import com.platepilote.platepilote.mealplanning.domain.entity.MealPlanMode;
import com.platepilote.platepilote.mealplanning.domain.entity.SwapTracking;
import com.platepilote.platepilote.mealplanning.domain.repository.MealPlanEntryRepository;
import com.platepilote.platepilote.mealplanning.domain.repository.SwapTrackingRepository;
import com.platepilote.platepilote.recipes.domain.entity.Recipe;
import com.platepilote.platepilote.recipes.domain.repository.RecipeRepository;
import com.platepilote.platepilote.recommendation.domain.service.RecommendationEngine;
import com.platepilote.platepilote.subscription.application.service.EntitlementService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.Comparator;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class SmartSwapService {

    private final MealPlanEntryRepository mealPlanEntryRepository;
    private final RecipeRepository recipeRepository;
    private final RecommendationEngine recommendationEngine;
    private final EntitlementService entitlementService;
    private final SwapTrackingRepository swapTrackingRepository;

    private static final int FREE_TIER_SWAP_LIMIT = 3;

    @Transactional(readOnly = true)
    public List<SwapOption> getSwapOptions(UUID userId, UUID entryId, int limit) {
        return getSwapOptions(userId, entryId, limit, MealPlanMode.STANDARD);
    }

    @Transactional(readOnly = true)
    public List<SwapOption> getSwapOptions(UUID userId, UUID entryId, int limit, MealPlanMode mode) {
        MealPlanEntry entry = mealPlanEntryRepository.findById(entryId)
                .orElseThrow(() -> new RuntimeException("Entry not found"));

        boolean premium = entitlementService.hasActiveEntitlement(userId, "PREMIUM");
        if (!premium) {
            java.time.Instant weekAgo = java.time.Instant.now().minus(java.time.Duration.ofDays(7));
            long swapCount = swapTrackingRepository.countByUserIdAndSwappedAtAfter(userId, weekAgo);
            if (swapCount >= FREE_TIER_SWAP_LIMIT) {
                return List.of();
            }
        }

        String mealType = entry.getMealType();
        int maxTime = entry.getNotes() != null && entry.getNotes().contains("quick")
                ? 30 : 60;

        List<Recipe> candidates = recipeRepository
                .findByMealTypeAndIsPublicTrueAndDeletedAtIsNull(mealType,
                        org.springframework.data.domain.PageRequest.of(0, 50))
                .getContent();

        UUID[] alreadyUsed = mealPlanEntryRepository.findByMealPlanId(entry.getMealPlanId())
                .stream().map(MealPlanEntry::getRecipeId).distinct().toArray(UUID[]::new);

        return candidates.stream()
                .filter(r -> !List.of(alreadyUsed).contains(r.getId()))
                .filter(r -> r.getEnabled() != null && r.getEnabled())
                .map(r -> new SwapOption(
                        r.getId(), r.getName(), r.getDescription(),
                        r.getImageUrl(), r.getTotalTimeMinutes(),
                        r.getEstimatedCost(), r.getCaloriesPerServing(),
                        r.getDifficulty(), r.getCuisineType(),
                        computeCompatibility(r, entry),
                        r.getConfidenceScore()
                ))
                .sorted(Comparator.comparingDouble(SwapOption::compatibility).reversed())
                .limit(limit)
                .toList();
    }

    private double computeCompatibility(Recipe recipe, MealPlanEntry entry) {
        double score = 1.0;
        if (entry.getMealType() != null && recipe.getMealType() != null
                && entry.getMealType().equalsIgnoreCase(recipe.getMealType())) {
            score += 0.3;
        }
        if (recipe.getTotalTimeMinutes() != null && recipe.getTotalTimeMinutes() <= 30) {
            score += 0.2;
        }
        if (recipe.getEstimatedCost() != null && recipe.getEstimatedCost()
                .compareTo(BigDecimal.valueOf(15)) <= 0) {
            score += 0.2;
        }
        if (recipe.getImageUrl() != null && !recipe.getImageUrl().isBlank()) {
            score += 0.15;
        }
        if (recipe.getConfidenceScore() != null && recipe.getConfidenceScore() >= 0.7) {
            score += 0.15;
        }
        return Math.min(score, 2.0);
    }

    public record SwapOption(
            UUID recipeId, String name, String description,
            String imageUrl, Integer totalTimeMinutes,
            BigDecimal estimatedCost, Integer caloriesPerServing,
            String difficulty, String cuisineType,
            double compatibility, Double confidenceScore
    ) {}
}
