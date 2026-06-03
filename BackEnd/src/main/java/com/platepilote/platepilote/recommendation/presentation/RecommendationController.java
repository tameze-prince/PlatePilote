package com.platepilote.platepilote.recommendation.presentation;

import com.platepilote.platepilote.common.dto.ApiResponse;
import com.platepilote.platepilote.common.security.SecurityUtils;
import com.platepilote.platepilote.recommendation.domain.entity.UserInteraction;
import com.platepilote.platepilote.recommendation.domain.repository.UserInteractionRepository;
import com.platepilote.platepilote.recommendation.domain.service.RecommendationEngine;
import com.platepilote.platepilote.recommendation.domain.service.RecommendationEngine.RecommendationResult;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.math.BigDecimal;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

/**
 * Contrôleur REST exposant les endpoints de recommandation de recettes.
 * <p>
 * Permet d'obtenir des recommandations personnalisées, des repas rapides,
 * des plans de repas hebdomadaires et de soumettre du feedback utilisateur.
 */
@RestController
@RequestMapping("/api/v1/recommendations")
@RequiredArgsConstructor
public class RecommendationController {

    /** Moteur de recommandation injecté. */
    private final RecommendationEngine recommendationEngine;

    /** Repository des interactions utilisateur. */
    private final UserInteractionRepository userInteractionRepository;

    /** Utilitaires de sécurité pour extraire l'utilisateur courant. */
    private final SecurityUtils securityUtils;

    /**
     * Récupère une liste de recommandations de recettes personnalisées.
     *
     * @param userDetails détails de l'utilisateur authentifié
     * @param limit       nombre maximum de résultats (défaut: 10)
     * @return liste des recommandations avec scores détaillés
     */
    @GetMapping
    public ResponseEntity<ApiResponse<List<RecipeRecommendation>>> getRecommendations(
            @AuthenticationPrincipal UserDetails userDetails,
            @RequestParam(defaultValue = "10") int limit) {
        UUID userId = securityUtils.getCurrentUserId(userDetails);
        List<RecommendationResult> results = recommendationEngine.getRecommendations(userId, limit);
        return ResponseEntity.ok(ApiResponse.success(toDto(results)));
    }

    /**
     * Récupère des recommandations de repas rapides (temps de préparation limité).
     *
     * @param userDetails détails de l'utilisateur authentifié
     * @param maxTime     temps maximum de préparation en minutes (défaut: 30)
     * @param limit       nombre maximum de résultats (défaut: 3)
     * @return liste des recommandations de repas rapides
     */
    @PostMapping("/quick-meal")
    public ResponseEntity<ApiResponse<List<RecipeRecommendation>>> getQuickMeal(
            @AuthenticationPrincipal UserDetails userDetails,
            @RequestParam(defaultValue = "30") int maxTime,
            @RequestParam(defaultValue = "3") int limit) {
        UUID userId = securityUtils.getCurrentUserId(userDetails);
        List<RecommendationResult> results = recommendationEngine.getQuickMeals(userId, maxTime, limit);
        return ResponseEntity.ok(ApiResponse.success(toDto(results)));
    }

    /**
     * Génère un plan de repas hebdomadaire complet (7 jours, 3 repas par jour).
     *
     * @param userDetails détails de l'utilisateur authentifié
     * @return plan hebdomadaire structuré par jour et par repas
     */
    @PostMapping("/weekly-plan")
    public ResponseEntity<ApiResponse<List<List<RecipeRecommendation>>>> generateWeeklyPlan(
            @AuthenticationPrincipal UserDetails userDetails) {
        UUID userId = securityUtils.getCurrentUserId(userDetails);
        List<List<RecommendationResult>> weeklyPlan = recommendationEngine.generateWeeklyMealPlan(userId);
        List<List<RecipeRecommendation>> dtoPlan = weeklyPlan.stream()
                .map(this::toDto)
                .collect(Collectors.toList());
        return ResponseEntity.ok(ApiResponse.success(dtoPlan));
    }

    /**
     * Soumet un feedback utilisateur sur une recette recommandée.
     * <p>
     * Les types d'interaction possibles : saved, cooked, rated, viewed, skipped, disliked.
     *
     * @param userDetails détails de l'utilisateur authentifié
     * @param request     corps de la requête contenant recipeId, interactionType et weight
     * @return confirmation de l'enregistrement du feedback
     */
    @PostMapping("/feedback")
    public ResponseEntity<ApiResponse<Void>> submitFeedback(
            @AuthenticationPrincipal UserDetails userDetails,
            @RequestBody FeedbackRequest request) {
        UUID userId = securityUtils.getCurrentUserId(userDetails);

        UserInteraction interaction = UserInteraction.builder()
                .userId(userId)
                .recipeId(request.recipeId())
                .interactionType(request.interactionType())
                .weight(request.weight() != null ? request.weight() : BigDecimal.ONE)
                .build();
        userInteractionRepository.save(interaction);

        return ResponseEntity.ok(ApiResponse.success("Feedback recorded", null));
    }

    /**
     * Requête de feedback utilisateur.
     *
     * @param recipeId        identifiant de la recette concernée
     * @param interactionType type d'interaction (saved, cooked, rated, viewed, skipped, disliked)
     * @param weight          poids optionnel de l'interaction
     */
    public record FeedbackRequest(
            UUID recipeId,
            String interactionType,
            BigDecimal weight
    ) {}

    /**
     * Convertit une liste de résultats du moteur en DTO de réponse.
     *
     * @param results résultats du moteur de recommandation
     * @return liste de DTO RecipeRecommendation
     */
    private List<RecipeRecommendation> toDto(List<RecommendationResult> results) {
        return results.stream()
                .map(r -> new RecipeRecommendation(
                        r.recipe().getId(),
                        r.recipe().getName(),
                        r.recipe().getDescription(),
                        r.recipe().getCuisineType(),
                        r.recipe().getMealType(),
                        r.recipe().getDifficulty(),
                        r.recipe().getTotalTimeMinutes(),
                        r.recipe().getServings(),
                        r.recipe().getImageUrl(),
                        r.finalScore(),
                        r.budgetScore(),
                        r.pantryScore(),
                        r.timeScore(),
                        r.preferenceScore(),
                        r.nutritionScore(),
                        r.varietyScore(),
                        r.locationScore(),
                        r.estimatedCost(),
                        r.currencyCode(),
                        r.countryCode(),
                        r.reasons(),
                        r.warnings()
                ))
                .collect(Collectors.toList());
    }

    /**
     * DTO représentant une recommandation de recette exposée via l'API REST.
     *
     * @param id               identifiant de la recette
     * @param name             nom de la recette
     * @param description      description textuelle
     * @param cuisineType      type de cuisine (ex: italienne, asiatique)
     * @param mealType         type de repas (ex: dîner, déjeuner)
     * @param difficulty       niveau de difficulté
     * @param totalTimeMinutes temps total de préparation en minutes
     * @param servings         nombre de portions
     * @param imageUrl         URL de l'image de la recette
     * @param score            score global de la recommandation
     * @param budgetScore      score budgétaire
     * @param pantryScore      score d'utilisation du placard
     * @param timeScore        score de temps de préparation
     * @param preferenceScore  score de correspondance aux préférences
     * @param nutritionScore   score nutritionnel
     * @param varietyScore     score de variété
     * @param locationScore    score de pertinence géographique
     * @param estimatedCost    coût estimé de la recette
     * @param currencyCode     code de la devise
     * @param countryCode      code du pays
     * @param reasons          raisons justifiant la recommandation
     * @param warnings         avertissements (allergènes, etc.)
     */
    public record RecipeRecommendation(
            UUID id,
            String name,
            String description,
            String cuisineType,
            String mealType,
            String difficulty,
            Integer totalTimeMinutes,
            Integer servings,
            String imageUrl,
            double score,
            double budgetScore,
            double pantryScore,
            double timeScore,
            double preferenceScore,
            double nutritionScore,
            double varietyScore,
            double locationScore,
            java.math.BigDecimal estimatedCost,
            String currencyCode,
            String countryCode,
            List<String> reasons,
            List<String> warnings
    ) {}
}
