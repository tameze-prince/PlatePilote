package com.platepilote.platepilote.optimization.application.service;

import com.platepilote.platepilote.ingredients.application.service.IngredientResolutionService;
import com.platepilote.platepilote.pricing.application.service.PricingService;
import com.platepilote.platepilote.recipes.domain.entity.RecipeIngredient;
import com.platepilote.platepilote.recipes.domain.repository.RecipeIngredientRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class BudgetOptimizer {

    private final RecipeIngredientRepository recipeIngredientRepository;
    private final IngredientResolutionService ingredientResolutionService;
    private final PricingService pricingService;

    public BigDecimal estimateRecipeCost(UUID recipeId, String countryCode) {
        List<RecipeIngredient> ingredients = recipeIngredientRepository.findByRecipeIdOrderBySortOrderAsc(recipeId);
        return sumIngredientCost(ingredients, countryCode);
    }

    public Map<UUID, BigDecimal> estimateMultipleRecipeCosts(List<UUID> recipeIds, String countryCode) {
        if (recipeIds.isEmpty()) {
            return Map.of();
        }

        List<RecipeIngredient> allIngredients = recipeIngredientRepository.findByRecipeIdIn(recipeIds);
        Map<UUID, List<RecipeIngredient>> ingredientsByRecipe = allIngredients.stream()
                .collect(Collectors.groupingBy(ri -> ri.getRecipe().getId()));

        Map<UUID, BigDecimal> costs = new HashMap<>();
        for (UUID recipeId : recipeIds) {
            List<RecipeIngredient> ingredients = ingredientsByRecipe.getOrDefault(recipeId, List.of());
            costs.put(recipeId, sumIngredientCost(ingredients, countryCode));
        }
        return costs;
    }

    private BigDecimal sumIngredientCost(List<RecipeIngredient> ingredients, String countryCode) {
        BigDecimal totalCost = BigDecimal.ZERO;
        for (RecipeIngredient ri : ingredients) {
            UUID ingredientId = ri.getIngredientId();
            if (ingredientId == null) {
                ingredientId = ingredientResolutionService.resolveIngredientId(ri.getName()).orElse(null);
            }
            if (ingredientId == null) {
                continue;
            }
            BigDecimal pricePerUnit = pricingService.getLatestPricePerUnit(ingredientId, countryCode)
                    .orElse(BigDecimal.ZERO);
            totalCost = totalCost.add(pricePerUnit.multiply(ri.getQuantity()));
        }
        return totalCost.setScale(2, RoundingMode.HALF_UP);
    }

    public BigDecimal calculateRemainingBudget(BigDecimal weeklyBudget, List<UUID> selectedRecipeIds,
                                                String countryCode) {
        BigDecimal totalUsed = estimateMultipleRecipeCosts(selectedRecipeIds, countryCode).values().stream()
                .reduce(BigDecimal.ZERO, BigDecimal::add);
        return weeklyBudget.subtract(totalUsed);
    }
}
