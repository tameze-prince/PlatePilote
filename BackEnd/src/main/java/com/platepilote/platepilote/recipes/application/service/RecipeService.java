package com.platepilote.platepilote.recipes.application.service;

import com.platepilote.platepilote.common.dto.PagedResponse;
import com.platepilote.platepilote.common.kernel.BusinessRuleViolationException;
import com.platepilote.platepilote.common.kernel.ResourceNotFoundException;
import com.platepilote.platepilote.common.security.SecurityUtils;
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

/**
 * Service métier pour la gestion des recettes.
 * <p>
 * Gère le cycle de vie complet des recettes : création, consultation, mise à jour,
 * suppression logique, recherche et filtrage par type de cuisine ou de repas.
 * Les ingrédients sont automatiquement résolus via {@link IngredientResolutionService}.
 */
@Service
@RequiredArgsConstructor
@Transactional
public class RecipeService {

    private final RecipeRepository recipeRepository;
    private final RecipeIngredientRepository ingredientRepository;
    private final RecipeStepRepository stepRepository;
    private final IngredientResolutionService ingredientResolutionService;
    private final SecurityUtils securityUtils;

    /**
     * Récupère toutes les recettes publiques, de manière paginée.
     *
     * @param pageable les paramètres de pagination et de tri
     * @return une page de résumés de recettes publiques
     */
    @Transactional(readOnly = true)
    public PagedResponse<RecipeResponse> getPublicRecipes(Pageable pageable) {
        Page<Recipe> page = recipeRepository.findByIsPublicTrueAndDeletedAtIsNull(pageable);
        return toPagedResponse(page, false);
    }

    /**
     * Récupère les recettes personnelles d'un utilisateur, de manière paginée.
     *
     * @param userId   l'identifiant de l'utilisateur
     * @param pageable les paramètres de pagination
     * @return une page de recettes de l'utilisateur
     */
    @Transactional(readOnly = true)
    public PagedResponse<RecipeResponse> getUserRecipes(UUID userId, Pageable pageable) {
        Page<Recipe> page = recipeRepository.findByUserIdAndDeletedAtIsNull(userId, pageable);
        return toPagedResponse(page, true);
    }

    /**
     * Récupère une recette par son identifiant avec le détail complet (ingrédients et étapes).
     *
     * @param recipeId l'identifiant de la recette
     * @return la recette complète
     * @throws ResourceNotFoundException si la recette est introuvable ou non publique
     */
    @Transactional(readOnly = true)
    public RecipeResponse getRecipeById(UUID recipeId) {
        Recipe recipe = recipeRepository.findById(recipeId)
                .orElseThrow(() -> new ResourceNotFoundException("Recipe", "id", recipeId.toString()));

        if (recipe.getIsPublic() == false && recipe.getUserId() == null) {
            throw new ResourceNotFoundException("Recipe", "id", recipeId.toString());
        }

        return toFullResponse(recipe);
    }

    /**
     * Recherche les recettes publiques par nom ou description.
     *
     * @param query    le terme de recherche (insensible à la casse)
     * @param pageable les paramètres de pagination
     * @return une page de recettes correspondant à la recherche
     */
    @Transactional(readOnly = true)
    public PagedResponse<RecipeResponse> searchRecipes(String query, Pageable pageable) {
        Page<Recipe> page = recipeRepository.searchPublicRecipes(query, pageable);
        return toPagedResponse(page, false);
    }

    /**
     * Filtre les recettes publiques par type de cuisine.
     *
     * @param cuisineType le type de cuisine (ex: "Italienne", "Japonaise")
     * @param pageable    les paramètres de pagination
     * @return une page de recettes du type de cuisine demandé
     */
    @Transactional(readOnly = true)
    public PagedResponse<RecipeResponse> getByCuisineType(String cuisineType, Pageable pageable) {
        Page<Recipe> page = recipeRepository.findByCuisineTypeAndIsPublicTrueAndDeletedAtIsNull(cuisineType, pageable);
        return toPagedResponse(page, false);
    }

    /**
     * Filtre les recettes publiques par type de repas.
     *
     * @param mealType le type de repas (ex: "Petit-déjeuner", "Dîner")
     * @param pageable les paramètres de pagination
     * @return une page de recettes du type de repas demandé
     */
    @Transactional(readOnly = true)
    public PagedResponse<RecipeResponse> getByMealType(String mealType, Pageable pageable) {
        Page<Recipe> page = recipeRepository.findByMealTypeAndIsPublicTrueAndDeletedAtIsNull(mealType, pageable);
        return toPagedResponse(page, false);
    }

    /**
     * Crée une nouvelle recette avec ses ingrédients et ses étapes.
     * <p>
     * Les ingrédients sont automatiquement liés à un ingrédient canonique via
     * {@link IngredientResolutionService} lorsque possible.
     *
     * @param userId  l'identifiant du créateur
     * @param request les données complètes de la recette
     * @return la recette créée avec le détail complet
     */
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
                .isPublic(request.getIsPublic() == null || request.getIsPublic())
                .userId(userId)
                .enabled(true)
                .verified(false)
                .verificationStatus("UNREVIEWED")
                .confidenceScore(0.5)
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

    /**
     * Met à jour une recette existante.
     * <p>
     * Les ingrédients et étapes existants sont remplacés par les nouvelles données.
     *
     * @param userId   l'identifiant de l'utilisateur (vérification de propriété)
     * @param recipeId l'identifiant de la recette à modifier
     * @param request  les nouvelles données de la recette
     * @return la recette mise à jour avec le détail complet
     */
    public RecipeResponse updateRecipe(UUID userId, UUID recipeId, RecipeRequest request) {
        Recipe recipe = recipeRepository.findById(recipeId)
                .orElseThrow(() -> new ResourceNotFoundException("Recipe", "id", recipeId.toString()));

        securityUtils.verifyOwnership(recipe.getUserId(), userId, "Recipe", recipeId.toString());

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

    /**
     * Supprime logiquement (soft-delete) une recette.
     *
     * @param userId   l'identifiant de l'utilisateur (vérification de propriété)
     * @param recipeId l'identifiant de la recette à supprimer
     */
    public void deleteRecipe(UUID userId, UUID recipeId) {
        Recipe recipe = recipeRepository.findById(recipeId)
                .orElseThrow(() -> new ResourceNotFoundException("Recipe", "id", recipeId.toString()));

        securityUtils.verifyOwnership(recipe.getUserId(), userId, "Recipe", recipeId.toString());

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
