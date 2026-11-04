package com.platepilote.platepilote.recipes.application.service;

import com.platepilote.platepilote.common.kernel.ResourceNotFoundException;
import com.platepilote.platepilote.common.security.SecurityUtils;
import com.platepilote.platepilote.ingredients.application.service.IngredientResolutionService;
import com.platepilote.platepilote.recipes.domain.entity.Recipe;
import com.platepilote.platepilote.recipes.domain.repository.RecipeIngredientRepository;
import com.platepilote.platepilote.recipes.domain.repository.RecipeRepository;
import com.platepilote.platepilote.recipes.domain.repository.RecipeStepRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class RecipeServicePrivacyTest {

    @Mock private RecipeRepository recipeRepository;
    @Mock private RecipeIngredientRepository ingredientRepository;
    @Mock private RecipeStepRepository stepRepository;
    @Mock private IngredientResolutionService ingredientResolutionService;
    @Mock private SecurityUtils securityUtils;

    private RecipeService recipeService;

    @BeforeEach
    void setUp() {
        recipeService = new RecipeService(
                recipeRepository,
                ingredientRepository,
                stepRepository,
                ingredientResolutionService,
                securityUtils
        );
    }

    @Test
    void publicDetailEndpointRejectsPrivateRecipeEvenWhenItHasAnOwner() {
        UUID ownerId = UUID.randomUUID();
        UUID recipeId = UUID.randomUUID();
        Recipe recipe = privateRecipe(recipeId, ownerId);
        when(recipeRepository.findById(recipeId)).thenReturn(Optional.of(recipe));

        assertThatThrownBy(() -> recipeService.getRecipeById(recipeId))
                .isInstanceOf(ResourceNotFoundException.class);
    }

    @Test
    void personalDetailEndpointRejectsAnotherUsersPrivateRecipe() {
        UUID ownerId = UUID.randomUUID();
        UUID requestingUserId = UUID.randomUUID();
        UUID recipeId = UUID.randomUUID();
        Recipe recipe = privateRecipe(recipeId, ownerId);
        when(recipeRepository.findById(recipeId)).thenReturn(Optional.of(recipe));

        assertThatThrownBy(() -> recipeService.getUserRecipeById(requestingUserId, recipeId))
                .isInstanceOf(ResourceNotFoundException.class);
    }

    private static Recipe privateRecipe(UUID id, UUID ownerId) {
        Recipe recipe = Recipe.builder()
                .name("Private recipe")
                .servings(2)
                .isPublic(false)
                .userId(ownerId)
                .enabled(true)
                .build();
        recipe.setId(id);
        return recipe;
    }
}
