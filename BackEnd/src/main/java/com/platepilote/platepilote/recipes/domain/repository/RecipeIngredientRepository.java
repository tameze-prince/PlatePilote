package com.platepilote.platepilote.recipes.domain.repository;

/**
 * RECIPE INGREDIENT REPOSITORY - DATABASE ACCESS FOR RECIPE INGREDIENTS
 * =======================================================================
 * 
 * METHODS:
 * 
 * 1. findByRecipeIdOrderBySortOrderAsc(recipeId)
 *    -> Get all ingredients for a recipe, ordered by display order
 *    SQL: SELECT * FROM recipe_ingredients WHERE recipe_id = ? ORDER BY sort_order ASC
 * 
 * 2. deleteByRecipeId(recipeId)
 *    -> Delete all ingredients for a recipe (used when deleting a recipe)
 *    SQL: DELETE FROM recipe_ingredients WHERE recipe_id = ?
 */

import com.platepilote.platepilote.recipes.domain.entity.RecipeIngredient;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface RecipeIngredientRepository extends JpaRepository<RecipeIngredient, UUID> {

    /**
     * Get all ingredients for a recipe, sorted by display order.
     */
    List<RecipeIngredient> findByRecipeIdOrderBySortOrderAsc(UUID recipeId);

    /**
     * Delete all ingredients for a recipe.
     * Called when a recipe is deleted to clean up orphaned ingredients.
     */
    void deleteByRecipeId(UUID recipeId);
}
