package com.platepilote.platepilote.optimization.application.service;

import com.platepilote.platepilote.ingredients.application.service.IngredientResolutionService;
import com.platepilote.platepilote.pantry.domain.entity.PantryItem;
import com.platepilote.platepilote.pantry.domain.repository.PantryItemRepository;
import com.platepilote.platepilote.recipes.domain.entity.RecipeIngredient;
import com.platepilote.platepilote.recipes.domain.repository.RecipeIngredientRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class PantryUtilizationScorer {

    private final PantryItemRepository pantryItemRepository;
    private final RecipeIngredientRepository recipeIngredientRepository;
    private final IngredientResolutionService ingredientResolutionService;

    public double calculatePantryScore(UUID userId, UUID recipeId) {
        List<PantryItem> pantryItems = pantryItemRepository
                .findByUserIdAndDeletedAtIsNull(userId,
                        org.springframework.data.domain.PageRequest.of(0, 500))
                .getContent();

        List<RecipeIngredient> recipeIngredients = recipeIngredientRepository
                .findByRecipeIdOrderBySortOrderAsc(recipeId);

        if (recipeIngredients.isEmpty()) return 0.0;

        long matchedIngredients = recipeIngredients.stream()
                .filter(ri -> pantryItems.stream()
                        .anyMatch(pi -> ingredientMatches(pi, ri)))
                .count();

        return (double) matchedIngredients / recipeIngredients.size();
    }

    public Map<UUID, Double> calculatePantryScoresForRecipes(UUID userId, List<UUID> recipeIds) {
        if (recipeIds.isEmpty()) {
            return Map.of();
        }

        List<PantryItem> pantryItems = pantryItemRepository
                .findByUserIdAndDeletedAtIsNull(userId,
                        org.springframework.data.domain.PageRequest.of(0, 500))
                .getContent();

        List<RecipeIngredient> allIngredients = recipeIngredientRepository.findByRecipeIdIn(recipeIds);
        Map<UUID, List<RecipeIngredient>> ingredientsByRecipe = allIngredients.stream()
                .collect(Collectors.groupingBy(ri -> ri.getRecipe().getId()));

        Map<UUID, Double> scores = new HashMap<>();
        for (UUID recipeId : recipeIds) {
            List<RecipeIngredient> recipeIngredients = ingredientsByRecipe.getOrDefault(recipeId, List.of());
            if (recipeIngredients.isEmpty()) {
                scores.put(recipeId, 0.0);
                continue;
            }

            long matched = recipeIngredients.stream()
                    .filter(ri -> pantryItems.stream().anyMatch(pi -> ingredientMatches(pi, ri)))
                    .count();
            scores.put(recipeId, (double) matched / recipeIngredients.size());
        }
        return scores;
    }

    public Map<UUID, Boolean> findRecipesUsingExpiringPantry(UUID userId, Set<UUID> expiringIngredientIds, List<UUID> recipeIds) {
        if (expiringIngredientIds.isEmpty() || recipeIds.isEmpty()) {
            return recipeIds.stream().collect(Collectors.toMap(id -> id, id -> false));
        }

        List<RecipeIngredient> allIngredients = recipeIngredientRepository.findByRecipeIdIn(recipeIds);
        Map<UUID, List<RecipeIngredient>> ingredientsByRecipe = allIngredients.stream()
                .collect(Collectors.groupingBy(ri -> ri.getRecipe().getId()));

        Map<UUID, Boolean> result = new HashMap<>();
        for (UUID recipeId : recipeIds) {
            List<RecipeIngredient> recipeIngredients = ingredientsByRecipe.getOrDefault(recipeId, List.of());
            boolean usesExpiring = recipeIngredients.stream()
                    .map(RecipeIngredient::getIngredientId)
                    .anyMatch(expiringIngredientIds::contains);
            result.put(recipeId, usesExpiring);
        }
        return result;
    }

    private boolean ingredientMatches(PantryItem pantryItem, RecipeIngredient recipeIngredient) {
        if (pantryItem.getIngredientId() != null && recipeIngredient.getIngredientId() != null) {
            return pantryItem.getIngredientId().equals(recipeIngredient.getIngredientId());
        }

        String pantryName = ingredientResolutionService.normalize(pantryItem.getName());
        String recipeName = ingredientResolutionService.normalize(recipeIngredient.getName());
        return !pantryName.isBlank()
                && !recipeName.isBlank()
                && (pantryName.contains(recipeName) || recipeName.contains(pantryName));
    }
}
