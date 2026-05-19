package com.platepilote.platepilote.optimization.application.service;

import com.platepilote.platepilote.pantry.domain.entity.PantryItem;
import com.platepilote.platepilote.pantry.domain.repository.PantryItemRepository;
import com.platepilote.platepilote.recipes.domain.entity.RecipeIngredient;
import com.platepilote.platepilote.recipes.domain.repository.RecipeIngredientRepository;
import com.platepilote.platepilote.ingredients.application.service.IngredientResolutionService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.UUID;

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

    private boolean ingredientMatches(PantryItem pantryItem, RecipeIngredient recipeIngredient) {
        if (pantryItem.getIngredientId() != null && recipeIngredient.getIngredientId() != null) {
            return pantryItem.getIngredientId().equals(recipeIngredient.getIngredientId());
        }

        String pantryName = ingredientResolutionService.normalize(pantryItem.getName());
        String recipeName = ingredientResolutionService.normalize(recipeIngredient.getName());
        return pantryName.contains(recipeName) || recipeName.contains(pantryName);
    }
}
