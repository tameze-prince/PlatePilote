package com.platepilote.platepilote.recipes.domain.repository;

/**
 * RECIPE STEP REPOSITORY - DATABASE ACCESS FOR RECIPE STEPS
 * ===========================================================
 * 
 * METHODS:
 * 
 * 1. findByRecipeIdOrderByStepNumberAsc(recipeId)
 *    -> Get all steps for a recipe, ordered by step number
 *    SQL: SELECT * FROM recipe_steps WHERE recipe_id = ? ORDER BY step_number ASC
 * 
 * 2. deleteByRecipeId(recipeId)
 *    -> Delete all steps for a recipe (used when deleting a recipe)
 */

import com.platepilote.platepilote.recipes.domain.entity.RecipeStep;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface RecipeStepRepository extends JpaRepository<RecipeStep, UUID> {

    /**
     * Get all steps for a recipe, sorted by step number (1, 2, 3, ...).
     */
    List<RecipeStep> findByRecipeIdOrderByStepNumberAsc(UUID recipeId);

    /**
     * Delete all steps for a recipe.
     * Called when a recipe is deleted to clean up orphaned steps.
     */
    void deleteByRecipeId(UUID recipeId);
}
