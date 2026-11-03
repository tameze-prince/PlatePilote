package com.platepilote.platepilote.recipes.application.service;

import com.platepilote.platepilote.authentication.domain.repository.UserRepository;
import com.platepilote.platepilote.common.kernel.ResourceNotFoundException;
import com.platepilote.platepilote.common.security.SecurityUtils;
import com.platepilote.platepilote.ingredients.application.service.IngredientResolutionService;
import com.platepilote.platepilote.recipes.domain.entity.Recipe;
import com.platepilote.platepilote.recipes.domain.repository.RecipeIngredientRepository;
import com.platepilote.platepilote.recipes.domain.repository.RecipeRepository;
import com.platepilote.platepilote.recipes.domain.repository.RecipeStepRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

class RecipeVisibilityTest {

    private RecipeRepository recipeRepository;
    private RecipeService recipeService;

    @BeforeEach
    void setUp() {
        recipeRepository = mock(RecipeRepository.class);
        recipeService = new RecipeService(
                recipeRepository,
                mock(RecipeIngredientRepository.class),
                mock(RecipeStepRepository.class),
                mock(IngredientResolutionService.class),
                new SecurityUtils(mock(UserRepository.class)));
    }

    @Test
    void publicEndpointDoesNotReturnPrivateRecipeOwnedByAnotherUser() {
        UUID recipeId = UUID.randomUUID();
        Recipe recipe = Recipe.builder()
                .isPublic(false)
                .userId(UUID.randomUUID())
                .build();
        when(recipeRepository.findById(recipeId)).thenReturn(Optional.of(recipe));

        assertThatThrownBy(() -> recipeService.getPublicRecipeById(recipeId))
                .isInstanceOf(ResourceNotFoundException.class);
    }

    @Test
    void publicEndpointDoesNotReturnSoftDeletedRecipe() {
        UUID recipeId = UUID.randomUUID();
        Recipe recipe = Recipe.builder().isPublic(true).build();
        recipe.softDelete();
        when(recipeRepository.findById(recipeId)).thenReturn(Optional.of(recipe));

        assertThatThrownBy(() -> recipeService.getPublicRecipeById(recipeId))
                .isInstanceOf(ResourceNotFoundException.class);
    }

    @Test
    void personalEndpointDoesNotReturnAnotherUsersPrivateRecipe() {
        UUID recipeId = UUID.randomUUID();
        Recipe recipe = Recipe.builder()
                .isPublic(false)
                .userId(UUID.randomUUID())
                .build();
        when(recipeRepository.findById(recipeId)).thenReturn(Optional.of(recipe));

        assertThatThrownBy(() -> recipeService.getUserRecipeById(UUID.randomUUID(), recipeId))
                .isInstanceOf(ResourceNotFoundException.class);
    }

    @Test
    void personalEndpointDoesNotReturnOwnerlessSystemRecipe() {
        UUID recipeId = UUID.randomUUID();
        Recipe recipe = Recipe.builder().isPublic(true).build();
        when(recipeRepository.findById(recipeId)).thenReturn(Optional.of(recipe));

        assertThatThrownBy(() -> recipeService.getUserRecipeById(UUID.randomUUID(), recipeId))
                .isInstanceOf(ResourceNotFoundException.class);
    }
}
