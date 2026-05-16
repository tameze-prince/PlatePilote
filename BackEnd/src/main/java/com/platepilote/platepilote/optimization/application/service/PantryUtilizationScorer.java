package com.platepilote.platepilote.optimization.application.service;

import com.platepilote.platepilote.pantry.domain.entity.PantryItem;
import com.platepilote.platepilote.pantry.domain.repository.PantryItemRepository;
import com.platepilote.platepilote.recipes.domain.entity.RecipeIngredient;
import com.platepilote.platepilote.recipes.domain.repository.RecipeIngredientRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class PantryUtilizationScorer {

    private final PantryItemRepository pantryItemRepository;
    private final RecipeIngredientRepository recipeIngredientRepository;

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
        String pantryName = pantryItem.getName().toLowerCase().trim();
        String recipeName = recipeIngredient.getName().toLowerCase().trim();
        return pantryName.contains(recipeName) || recipeName.contains(pantryName);
    }
}
