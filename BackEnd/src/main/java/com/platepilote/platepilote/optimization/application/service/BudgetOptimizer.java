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
import java.util.Objects;
import java.util.UUID;
import java.util.stream.Collectors;

/**
 * Optimiseur de budget pour l'estimation des coûts des recettes.
 * <p>
 * Calcule le coût estimé d'une ou plusieurs recettes en fonction des prix
 * des ingrédients dans un pays donné. Utilise le PricingService pour obtenir
 * les derniers prix unitaires et l'IngredientResolutionService pour résoudre
 * les identifiants d'ingrédients à partir des noms.
 */
@Service
@RequiredArgsConstructor
public class BudgetOptimizer {

    /** Repository des ingrédients de recettes. */
    private final RecipeIngredientRepository recipeIngredientRepository;

    /** Service de résolution d'ingrédients par nom. */
    private final IngredientResolutionService ingredientResolutionService;

    /** Service de tarification. */
    private final PricingService pricingService;

    /**
     * Estime le coût d'une seule recette dans un pays donné.
     *
     * @param recipeId    identifiant de la recette
     * @param countryCode code pays ISO 3166-1 alpha-2
     * @return coût total estimé arrondi à 2 décimales
     */
    public BigDecimal estimateRecipeCost(UUID recipeId, String countryCode) {
        List<RecipeIngredient> ingredients = recipeIngredientRepository.findByRecipeIdOrderBySortOrderAsc(recipeId);
        return sumIngredientCost(ingredients, countryCode);
    }

    /**
     * Estime le coût de plusieurs recettes en une seule passe optimisée.
     * <p>
     * Charge tous les ingrédients et prix en une fois, puis effectue le calcul
     * en mémoire pour minimiser les appels base de données.
     *
     * @param recipeIds   liste des identifiants de recettes
     * @param countryCode code pays ISO 3166-1 alpha-2
     * @return map associant chaque identifiant de recette à son coût estimé
     */
    public Map<UUID, BigDecimal> estimateMultipleRecipeCosts(List<UUID> recipeIds, String countryCode) {
        if (recipeIds.isEmpty()) {
            return Map.of();
        }

        List<RecipeIngredient> allIngredients = recipeIngredientRepository.findByRecipeIdIn(recipeIds);
        Map<UUID, BigDecimal> prices = pricingService.getLatestPricesPerUnit(
                allIngredients.stream()
                        .map(RecipeIngredient::getIngredientId)
                        .filter(Objects::nonNull)
                        .distinct()
                        .toList(),
                countryCode
        );
        Map<UUID, List<RecipeIngredient>> ingredientsByRecipe = allIngredients.stream()
                .collect(Collectors.groupingBy(ri -> ri.getRecipe().getId()));

        Map<UUID, BigDecimal> costs = new HashMap<>();
        for (UUID recipeId : recipeIds) {
            List<RecipeIngredient> ingredients = ingredientsByRecipe.getOrDefault(recipeId, List.of());
            costs.put(recipeId, sumIngredientCost(ingredients, countryCode, prices));
        }
        return costs;
    }

    private BigDecimal sumIngredientCost(List<RecipeIngredient> ingredients, String countryCode) {
        return sumIngredientCost(ingredients, countryCode, Map.of());
    }

    private BigDecimal sumIngredientCost(
            List<RecipeIngredient> ingredients,
            String countryCode,
            Map<UUID, BigDecimal> prices
    ) {
        BigDecimal totalCost = BigDecimal.ZERO;
        for (RecipeIngredient ri : ingredients) {
            UUID ingredientId = ri.getIngredientId();
            if (ingredientId == null) {
                ingredientId = ingredientResolutionService.resolveIngredientId(ri.getName()).orElse(null);
            }
            if (ingredientId == null) {
                continue;
            }
            BigDecimal pricePerUnit = prices.isEmpty()
                    ? pricingService.getLatestPricePerUnit(ingredientId, countryCode).orElse(BigDecimal.ZERO)
                    : prices.getOrDefault(ingredientId, BigDecimal.ZERO);
            totalCost = totalCost.add(pricePerUnit.multiply(ri.getQuantity()));
        }
        return totalCost.setScale(2, RoundingMode.HALF_UP);
    }

    /**
     * Calcule le budget restant après sélection d'un ensemble de recettes.
     *
     * @param weeklyBudget     budget hebdomadaire total
     * @param selectedRecipeIds identifiants des recettes sélectionnées
     * @param countryCode       code pays ISO 3166-1 alpha-2
     * @return budget restant (budget total - coût total des recettes)
     */
    public BigDecimal calculateRemainingBudget(BigDecimal weeklyBudget, List<UUID> selectedRecipeIds,
                                                String countryCode) {
        BigDecimal totalUsed = estimateMultipleRecipeCosts(selectedRecipeIds, countryCode).values().stream()
                .reduce(BigDecimal.ZERO, BigDecimal::add);
        return weeklyBudget.subtract(totalUsed);
    }
}
