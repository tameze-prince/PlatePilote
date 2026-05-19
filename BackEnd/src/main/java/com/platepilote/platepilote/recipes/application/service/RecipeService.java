package com.platepilote.platepilote.recipes.application.service;

import com.platepilote.platepilote.common.dto.PagedResponse;
import com.platepilote.platepilote.common.kernel.BusinessRuleViolationException;
import com.platepilote.platepilote.common.kernel.ResourceNotFoundException;
import com.platepilote.platepilote.ingredients.application.service.IngredientResolutionService;
import com.platepilote.platepilote.recipes.application.dto.RecipeIngredientRequest;
import com.platepilote.platepilote.recipes.application.dto.RecipeRequest;
import com.platepilote.platepilote.recipes.application.dto.RecipeResponse;
import com.platepilote.platepilote.recipes.application.dto.RecipeStepRequest;
import com.platepilote.platepilote.recipes.domain.entity.Recipe;
import com.platepilote.platepilote.recipes.domain.entity.RecipeIngredient;
import com.platepilote.platepilote.recipes.domain.entity.RecipeStep;
import com.platepilote.platepilote.recipes.domain.repository.RecipeIngredientRepository;
import com.platepilote.platepilote.recipes.domain.repository.RecipeRepository;
import com.platepilote.platepilote.recipes.domain.repository.RecipeStepRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;
import java.util.stream.IntStream;

@Service
@RequiredArgsConstructor
@Transactional
public class RecipeService {

    private final RecipeRepository recipeRepository;
    private final RecipeIngredientRepository ingredientRepository;
    private final RecipeStepRepository stepRepository;
    private final IngredientResolutionService ingredientResolutionService;

    @Transactional(readOnly = true)
    public PagedResponse<RecipeResponse> getPublicRecipes(Pageable pageable) {
        Page<Recipe> page = recipeRepository.findByIsPublicTrueAndDeletedAtIsNull(pageable);
        return toPagedResponse(page, false);
    }

    @Transactional(readOnly = true)
    public PagedResponse<RecipeResponse> getUserRecipes(UUID userId, Pageable pageable) {
        Page<Recipe> page = recipeRepository.findByUserIdAndDeletedAtIsNull(userId, pageable);
        return toPagedResponse(page, true);
    }

    @Transactional(readOnly = true)
    public RecipeResponse getRecipeById(UUID recipeId) {
        Recipe recipe = recipeRepository.findById(recipeId)
                .orElseThrow(() -> new ResourceNotFoundException("Recipe", "id", recipeId.toString()));

        if (recipe.getIsPublic() == false && recipe.getUserId() == null) {
            throw new ResourceNotFoundException("Recipe", "id", recipeId.toString());
        }

        return toFullResponse(recipe);
    }

    @Transactional(readOnly = true)
    public PagedResponse<RecipeResponse> searchRecipes(String query, Pageable pageable) {
        Page<Recipe> page = recipeRepository.searchPublicRecipes(query, pageable);
        return toPagedResponse(page, false);
    }

    @Transactional(readOnly = true)
    public PagedResponse<RecipeResponse> getByCuisineType(String cuisineType, Pageable pageable) {
        Page<Recipe> page = recipeRepository.findByCuisineTypeAndIsPublicTrueAndDeletedAtIsNull(cuisineType, pageable);
        return toPagedResponse(page, false);
    }

    @Transactional(readOnly = true)
    public PagedResponse<RecipeResponse> getByMealType(String mealType, Pageable pageable) {
        Page<Recipe> page = recipeRepository.findByMealTypeAndIsPublicTrueAndDeletedAtIsNull(mealType, pageable);
        return toPagedResponse(page, false);
    }

    public RecipeResponse createRecipe(UUID userId, RecipeRequest request) {
        Recipe recipe = Recipe.builder()
                .name(request.getName())
                .description(request.getDescription())
                .prepTimeMinutes(request.getPrepTimeMinutes())
                .cookTimeMinutes(request.getCookTimeMinutes())
                .totalTimeMinutes(request.getTotalTimeMinutes())
                .servings(request.getServings())
                .difficulty(request.getDifficulty())
                .cuisineType(request.getCuisineType())
                .mealType(request.getMealType())
                .imageUrl(request.getImageUrl())
                .source(request.getSource())
                .isPublic(request.getIsPublic())
                .userId(userId)
                .build();

        Recipe saved = recipeRepository.save(recipe);

        if (request.getIngredients() != null && !request.getIngredients().isEmpty()) {
            List<RecipeIngredient> ingredients = IntStream.range(0, request.getIngredients().size())
                    .mapToObj(i -> {
                        RecipeIngredientRequest req = request.getIngredients().get(i);
                        return RecipeIngredient.builder()
                                .recipe(saved)
                                .name(req.getName())
                                .quantity(req.getQuantity())
                                .unit(req.getUnit())
                                .notes(req.getNotes())
                                .sortOrder(req.getSortOrder() != null ? req.getSortOrder() : i)
                                .ingredientId(ingredientResolutionService.resolveIngredientId(req.getName()).orElse(null))
                                .build();
                    })
                    .collect(Collectors.toList());
            ingredientRepository.saveAll(ingredients);
        }

        if (request.getSteps() != null && !request.getSteps().isEmpty()) {
            List<RecipeStep> steps = request.getSteps().stream()
                    .map(req -> RecipeStep.builder()
                            .recipe(saved)
                            .stepNumber(req.getStepNumber())
                            .instruction(req.getInstruction())
                            .durationMinutes(req.getDurationMinutes())
                            .build())
                    .collect(Collectors.toList());
            stepRepository.saveAll(steps);
        }

        return toFullResponse(saved);
    }

    public RecipeResponse updateRecipe(UUID userId, UUID recipeId, RecipeRequest request) {
        Recipe recipe = recipeRepository.findById(recipeId)
                .orElseThrow(() -> new ResourceNotFoundException("Recipe", "id", recipeId.toString()));

        if (!recipe.getUserId().equals(userId)) {
            throw new BusinessRuleViolationException("You can only update your own recipes");
        }

        recipe.setName(request.getName());
        recipe.setDescription(request.getDescription());
        recipe.setPrepTimeMinutes(request.getPrepTimeMinutes());
        recipe.setCookTimeMinutes(request.getCookTimeMinutes());
        recipe.setTotalTimeMinutes(request.getTotalTimeMinutes());
        recipe.setServings(request.getServings());
        recipe.setDifficulty(request.getDifficulty());
        recipe.setCuisineType(request.getCuisineType());
        recipe.setMealType(request.getMealType());
        recipe.setImageUrl(request.getImageUrl());
        recipe.setSource(request.getSource());
        recipe.setIsPublic(request.getIsPublic());

        Recipe saved = recipeRepository.save(recipe);

        if (request.getIngredients() != null) {
            ingredientRepository.deleteByRecipeId(recipeId);
            List<RecipeIngredient> ingredients = IntStream.range(0, request.getIngredients().size())
                    .mapToObj(i -> {
                        RecipeIngredientRequest req = request.getIngredients().get(i);
                        return RecipeIngredient.builder()
                                .recipe(saved)
                                .name(req.getName())
                                .quantity(req.getQuantity())
                                .unit(req.getUnit())
                                .notes(req.getNotes())
                                .sortOrder(req.getSortOrder() != null ? req.getSortOrder() : i)
                                .ingredientId(ingredientResolutionService.resolveIngredientId(req.getName()).orElse(null))
                                .build();
                    })
                    .collect(Collectors.toList());
            ingredientRepository.saveAll(ingredients);
        }

        if (request.getSteps() != null) {
            stepRepository.deleteByRecipeId(recipeId);
            List<RecipeStep> steps = request.getSteps().stream()
                    .map(req -> RecipeStep.builder()
                            .recipe(saved)
                            .stepNumber(req.getStepNumber())
                            .instruction(req.getInstruction())
                            .durationMinutes(req.getDurationMinutes())
                            .build())
                    .collect(Collectors.toList());
            stepRepository.saveAll(steps);
        }

        return toFullResponse(saved);
    }

    public void deleteRecipe(UUID userId, UUID recipeId) {
        Recipe recipe = recipeRepository.findById(recipeId)
                .orElseThrow(() -> new ResourceNotFoundException("Recipe", "id", recipeId.toString()));

        if (!recipe.getUserId().equals(userId)) {
            throw new BusinessRuleViolationException("You can only delete your own recipes");
        }

        recipe.softDelete();
        recipeRepository.save(recipe);
    }

    private PagedResponse<RecipeResponse> toPagedResponse(Page<Recipe> page, boolean fullDetails) {
        List<RecipeResponse> content = page.getContent()
                .stream()
                .map(fullDetails ? this::toFullResponse : this::toSummaryResponse)
                .collect(Collectors.toList());

        return PagedResponse.of(content, page.getNumber(), page.getSize(), page.getTotalElements());
    }

    private RecipeResponse toSummaryResponse(Recipe recipe) {
        return RecipeResponse.builder()
                .id(recipe.getId())
                .name(recipe.getName())
                .description(recipe.getDescription())
                .prepTimeMinutes(recipe.getPrepTimeMinutes())
                .cookTimeMinutes(recipe.getCookTimeMinutes())
                .totalTimeMinutes(recipe.getTotalTimeMinutes())
                .servings(recipe.getServings())
                .difficulty(recipe.getDifficulty())
                .cuisineType(recipe.getCuisineType())
                .mealType(recipe.getMealType())
                .imageUrl(recipe.getImageUrl())
                .isPublic(recipe.getIsPublic())
                .createdAt(recipe.getCreatedAt())
                .updatedAt(recipe.getUpdatedAt())
                .build();
    }

    private RecipeResponse toFullResponse(Recipe recipe) {
        List<RecipeResponse.RecipeIngredientResponse> ingredients = ingredientRepository
                .findByRecipeIdOrderBySortOrderAsc(recipe.getId())
                .stream()
                .map(i -> RecipeResponse.RecipeIngredientResponse.builder()
                        .id(i.getId())
                        .name(i.getName())
                        .quantity(i.getQuantity())
                        .unit(i.getUnit())
                        .notes(i.getNotes())
                        .sortOrder(i.getSortOrder())
                        .ingredientId(i.getIngredientId())
                        .build())
                .collect(Collectors.toList());

        List<RecipeResponse.RecipeStepResponse> steps = stepRepository
                .findByRecipeIdOrderByStepNumberAsc(recipe.getId())
                .stream()
                .map(s -> RecipeResponse.RecipeStepResponse.builder()
                        .id(s.getId())
                        .stepNumber(s.getStepNumber())
                        .instruction(s.getInstruction())
                        .durationMinutes(s.getDurationMinutes())
                        .build())
                .collect(Collectors.toList());

        return RecipeResponse.builder()
                .id(recipe.getId())
                .name(recipe.getName())
                .description(recipe.getDescription())
                .prepTimeMinutes(recipe.getPrepTimeMinutes())
                .cookTimeMinutes(recipe.getCookTimeMinutes())
                .totalTimeMinutes(recipe.getTotalTimeMinutes())
                .servings(recipe.getServings())
                .difficulty(recipe.getDifficulty())
                .cuisineType(recipe.getCuisineType())
                .mealType(recipe.getMealType())
                .imageUrl(recipe.getImageUrl())
                .source(recipe.getSource())
                .isPublic(recipe.getIsPublic())
                .userId(recipe.getUserId())
                .ingredients(ingredients)
                .steps(steps)
                .createdAt(recipe.getCreatedAt())
                .updatedAt(recipe.getUpdatedAt())
                .build();
    }
}
