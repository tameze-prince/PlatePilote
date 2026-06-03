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

/**
 * Scoreur d'utilisation du placard pour les recommandations de recettes.
 * <p>
 * Évalue dans quelle mesure les ingrédients d'une recette sont déjà présents
 * dans le placard de l'utilisateur. Un score élevé indique que l'utilisateur
 * peut préparer la recette sans achats supplémentaires.
 */
@Service
@RequiredArgsConstructor
public class PantryUtilizationScorer {

    /** Repository des articles du placard. */
    private final PantryItemRepository pantryItemRepository;

    /** Repository des ingrédients de recettes. */
    private final RecipeIngredientRepository recipeIngredientRepository;

    /** Service de résolution d'ingrédients par nom. */
    private final IngredientResolutionService ingredientResolutionService;

    /**
     * Calcule le score d'utilisation du placard pour une recette unique.
     *
     * @param userId   identifiant de l'utilisateur
     * @param recipeId identifiant de la recette
     * @return proportion des ingrédients de la recette présents dans le placard (0.0 - 1.0)
     */
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

    /**
     * Calcule les scores d'utilisation du placard pour plusieurs recettes en une passe.
     *
     * @param userId    identifiant de l'utilisateur
     * @param recipeIds liste des identifiants de recettes
     * @return map associant chaque identifiant de recette à son score (0.0 - 1.0)
     */
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

    /**
     * Identifie les recettes qui utilisent des ingrédients du placard proches de l'expiration.
     *
     * @param userId               identifiant de l'utilisateur
     * @param expiringIngredientIds ensemble des identifiants d'ingrédients expirant bientôt
     * @param recipeIds            liste des identifiants de recettes candidates
     * @return map associant chaque recette à un booléen indiquant si elle utilise un ingrédient expirant
     */
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
