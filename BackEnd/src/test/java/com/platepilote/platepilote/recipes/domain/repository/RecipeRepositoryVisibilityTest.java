package com.platepilote.platepilote.recipes.domain.repository;

import com.platepilote.platepilote.recipes.domain.entity.Recipe;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import static org.assertj.core.api.Assertions.assertThat;

@DataJpaTest
class RecipeRepositoryVisibilityTest {

    @Autowired
    private RecipeRepository recipeRepository;

    @Test
    void publicSearchCannotLeakPrivateOrDeletedRecipesThroughDescriptionMatch() {
        Recipe publicRecipe = recipe("Public lentil bowl", "needle ingredient", true, false);
        Recipe privateRecipe = recipe("Private meal", "needle ingredient", false, false);
        Recipe deletedRecipe = recipe("Deleted meal", "needle ingredient", true, true);

        recipeRepository.save(publicRecipe);
        recipeRepository.save(privateRecipe);
        deletedRecipe.softDelete();
        recipeRepository.saveAndFlush(deletedRecipe);

        Page<Recipe> results = recipeRepository.searchPublicRecipes("needle", Pageable.unpaged());

        assertThat(results.getContent())
                .extracting(Recipe::getName)
                .containsExactly("Public lentil bowl");
    }

    private Recipe recipe(String name, String description, boolean isPublic, boolean deleted) {
        Recipe recipe = Recipe.builder()
                .name(name)
                .description(description)
                .servings(2)
                .isPublic(isPublic)
                .enabled(true)
                .build();
        if (deleted) {
            recipe.softDelete();
        }
        return recipe;
    }
}
