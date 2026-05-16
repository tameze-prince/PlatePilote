package com.platepilote.platepilote.optimization.application.service;

import com.platepilote.platepilote.ingredients.domain.repository.IngredientRepository;
import com.platepilote.platepilote.pricing.application.service.PricingService;
import com.platepilote.platepilote.recipes.domain.entity.RecipeIngredient;
import com.platepilote.platepilote.recipes.domain.repository.RecipeIngredientRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class BudgetOptimizer {

    private final RecipeIngredientRepository recipeIngredientRepository;
    private final IngredientRepository ingredientRepository;
    private final PricingService pricingService;

    public BigDecimal estimateRecipeCost(UUID recipeId, String countryCode) {
        List<RecipeIngredient> ingredients = recipeIngredientRepository.findByRecipeIdOrderBySortOrderAsc(recipeId);
        BigDecimal totalCost = BigDecimal.ZERO;

        for (RecipeIngredient ri : ingredients) {
            BigDecimal ingredientCost = estimateIngredientCost(ri, countryCode);
            if (ingredientCost != null) {
                totalCost = totalCost.add(ingredientCost);
            }
        }
        return totalCost.setScale(2, RoundingMode.HALF_UP);
    }

    private BigDecimal estimateIngredientCost(RecipeIngredient ri, String countryCode) {
        return pricingService.getLatestPricePerUnit(ri.getRecipe().getId(), countryCode)
                .orElse(BigDecimal.ZERO)
                .multiply(ri.getQuantity());
    }

    public Map<UUID, BigDecimal> estimateMultipleRecipeCosts(List<UUID> recipeIds, String countryCode) {
        return recipeIds.stream()
                .collect(Collectors.toMap(
                        id -> id,
                        id -> estimateRecipeCost(id, countryCode)
                ));
    }

    public BigDecimal calculateRemainingBudget(BigDecimal weeklyBudget, List<UUID> selectedRecipeIds,
                                                String countryCode) {
        BigDecimal totalUsed = BigDecimal.ZERO;
        for (UUID recipeId : selectedRecipeIds) {
            totalUsed = totalUsed.add(estimateRecipeCost(recipeId, countryCode));
        }
        return weeklyBudget.subtract(totalUsed);
    }
}
