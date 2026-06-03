package com.platepilote.platepilote.mealplanning.application.service;

import com.platepilote.platepilote.mealplanning.domain.entity.MealPlanEntry;
import com.platepilote.platepilote.mealplanning.domain.entity.MealPlanMode;
import com.platepilote.platepilote.mealplanning.domain.entity.SwapTracking;
import com.platepilote.platepilote.mealplanning.domain.repository.MealPlanEntryRepository;
import com.platepilote.platepilote.mealplanning.domain.repository.SwapTrackingRepository;
import com.platepilote.platepilote.recipes.domain.entity.Recipe;
import com.platepilote.platepilote.recipes.domain.repository.RecipeRepository;
import com.platepilote.platepilote.recommendation.domain.service.RecommendationEngine;
import com.platepilote.platepilote.subscription.application.service.EntitlementService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.Comparator;
import java.util.List;
import java.util.UUID;

/**
 * Service de suggestions d'échanges intelligents de recettes.
 * <p>
 * Propose des alternatives aux recettes d'un plan de repas en fonction
 * du type de repas, du temps de préparation, du coût et d'autres critères.
 * Les utilisateurs gratuits sont limités à 3 échanges par semaine.
 * </p>
 */
@Service
@RequiredArgsConstructor
public class SmartSwapService {

    private final MealPlanEntryRepository mealPlanEntryRepository;
    private final RecipeRepository recipeRepository;
    private final RecommendationEngine recommendationEngine;
    private final EntitlementService entitlementService;
    private final SwapTrackingRepository swapTrackingRepository;

    /** Limite d'échanges hebdomadaires pour les utilisateurs du palier gratuit. */
    private static final int FREE_TIER_SWAP_LIMIT = 3;

    /**
     * Récupère les options d'échange pour une entrée donnée en mode STANDARD.
     *
     * @param userId  identifiant de l'utilisateur
     * @param entryId identifiant de l'entrée à échanger
     * @param limit   nombre maximum d'options
     * @return liste des options d'échange triées par compatibilité
     */
    @Transactional(readOnly = true)
    public List<SwapOption> getSwapOptions(UUID userId, UUID entryId, int limit) {
        return getSwapOptions(userId, entryId, limit, MealPlanMode.STANDARD);
    }

    /**
     * Récupère les options d'échange pour une entrée donnée selon un mode spécifique.
     * <p>
     * Vérifie d'abord les droits de l'utilisateur : les utilisateurs non premium
     * sont limités à 3 échanges par semaine. Ensuite, recherche des recettes candidates
     * compatibles avec le type de repas et les contraintes de temps.
     * </p>
     *
     * @param userId  identifiant de l'utilisateur
     * @param entryId identifiant de l'entrée à échanger
     * @param limit   nombre maximum d'options
     * @param mode    mode de planification
     * @return liste des options d'échange triées par compatibilité décroissante
     */
    @Transactional(readOnly = true)
    public List<SwapOption> getSwapOptions(UUID userId, UUID entryId, int limit, MealPlanMode mode) {
        MealPlanEntry entry = mealPlanEntryRepository.findById(entryId)
                .orElseThrow(() -> new RuntimeException("Entry not found"));

        boolean premium = entitlementService.hasActiveEntitlement(userId, "PREMIUM");
        if (!premium) {
            java.time.Instant weekAgo = java.time.Instant.now().minus(java.time.Duration.ofDays(7));
            long swapCount = swapTrackingRepository.countByUserIdAndSwappedAtAfter(userId, weekAgo);
            if (swapCount >= FREE_TIER_SWAP_LIMIT) {
                return List.of();
            }
        }

        String mealType = entry.getMealType();
        int maxTime = entry.getNotes() != null && entry.getNotes().contains("quick")
                ? 30 : 60;

        List<Recipe> candidates = recipeRepository
                .findByMealTypeAndIsPublicTrueAndDeletedAtIsNull(mealType,
                        org.springframework.data.domain.PageRequest.of(0, 50))
                .getContent();

        UUID[] alreadyUsed = mealPlanEntryRepository.findByMealPlanId(entry.getMealPlanId())
                .stream().map(MealPlanEntry::getRecipeId).distinct().toArray(UUID[]::new);

        return candidates.stream()
                .filter(r -> !List.of(alreadyUsed).contains(r.getId()))
                .filter(r -> r.getEnabled() != null && r.getEnabled())
                .map(r -> new SwapOption(
                        r.getId(), r.getName(), r.getDescription(),
                        r.getImageUrl(), r.getTotalTimeMinutes(),
                        r.getEstimatedCost(), r.getCaloriesPerServing(),
                        r.getDifficulty(), r.getCuisineType(),
                        computeCompatibility(r, entry),
                        r.getConfidenceScore()
                ))
                .sorted(Comparator.comparingDouble(SwapOption::compatibility).reversed())
                .limit(limit)
                .toList();
    }

    /**
     * Calcule un score de compatibilité entre une recette candidate et l'entrée d'origine.
     * <p>
     * Le score prend en compte le type de repas, le temps de préparation, le coût,
     * la présence d'une image et le score de confiance de la recette.
     * Le score maximal est de 2.0.
     * </p>
     *
     * @param recipe recette candidate
     * @param entry  entrée d'origine
     * @return score de compatibilité entre 0.0 et 2.0
     */
    private double computeCompatibility(Recipe recipe, MealPlanEntry entry) {
        double score = 1.0;
        if (entry.getMealType() != null && recipe.getMealType() != null
                && entry.getMealType().equalsIgnoreCase(recipe.getMealType())) {
            score += 0.3;
        }
        if (recipe.getTotalTimeMinutes() != null && recipe.getTotalTimeMinutes() <= 30) {
            score += 0.2;
        }
        if (recipe.getEstimatedCost() != null && recipe.getEstimatedCost()
                .compareTo(BigDecimal.valueOf(15)) <= 0) {
            score += 0.2;
        }
        if (recipe.getImageUrl() != null && !recipe.getImageUrl().isBlank()) {
            score += 0.15;
        }
        if (recipe.getConfidenceScore() != null && recipe.getConfidenceScore() >= 0.7) {
            score += 0.15;
        }
        return Math.min(score, 2.0);
    }

    /**
     * Enregistrement représentant une option d'échange de recette.
     *
     * @param recipeId          identifiant de la recette candidate
     * @param name              nom de la recette
     * @param description       description de la recette
     * @param imageUrl          URL de l'image
     * @param totalTimeMinutes  temps total de préparation
     * @param estimatedCost     coût estimé
     * @param caloriesPerServing calories par portion
     * @param difficulty        niveau de difficulté
     * @param cuisineType       type de cuisine
     * @param compatibility     score de compatibilité avec l'entrée d'origine
     * @param confidenceScore   score de confiance de la recette
     */
    public record SwapOption(
            UUID recipeId, String name, String description,
            String imageUrl, Integer totalTimeMinutes,
            BigDecimal estimatedCost, Integer caloriesPerServing,
            String difficulty, String cuisineType,
            double compatibility, Double confidenceScore
    ) {}
}
