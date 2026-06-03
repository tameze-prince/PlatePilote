package com.platepilote.platepilote.mealplanning.application.service;

import com.platepilote.platepilote.common.dto.PagedResponse;
import com.platepilote.platepilote.common.kernel.BusinessRuleViolationException;
import com.platepilote.platepilote.common.kernel.ResourceNotFoundException;
import com.platepilote.platepilote.common.security.SecurityUtils;
import com.platepilote.platepilote.mealplanning.application.dto.MealPlanEntryRequest;
import com.platepilote.platepilote.mealplanning.application.dto.MealPlanRequest;
import com.platepilote.platepilote.mealplanning.application.dto.MealPlanResponse;
import com.platepilote.platepilote.mealplanning.domain.entity.MealPlan;
import com.platepilote.platepilote.mealplanning.domain.entity.MealPlanEntry;
import com.platepilote.platepilote.mealplanning.domain.entity.MealPlanMode;
import com.platepilote.platepilote.mealplanning.domain.entity.SwapTracking;
import com.platepilote.platepilote.mealplanning.domain.repository.SwapTrackingRepository;
import com.platepilote.platepilote.mealplanning.domain.repository.MealPlanEntryRepository;
import com.platepilote.platepilote.mealplanning.domain.repository.MealPlanRepository;
import com.platepilote.platepilote.recipes.domain.entity.Recipe;
import com.platepilote.platepilote.recipes.domain.repository.RecipeRepository;
import com.platepilote.platepilote.recommendation.domain.service.RecommendationEngine;
import com.platepilote.platepilote.recommendation.domain.service.RecommendationEngine.RecommendationResult;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.function.Function;
import java.util.stream.Collectors;

/**
 * Service métier pour la gestion des plans de repas.
 * <p>
 * Fournit les opérations CRUD sur les plans de repas et leurs entrées,
 * la génération automatique de plans hebdomadaires, et la gestion des
 * échanges (swap) de recettes.
 * </p>
 */
@Service
@RequiredArgsConstructor
@Transactional
public class MealPlanService {

    private final MealPlanRepository mealPlanRepository;
    private final MealPlanEntryRepository mealPlanEntryRepository;
    private final RecipeRepository recipeRepository;
    private final RecommendationEngine recommendationEngine;
    private final SecurityUtils securityUtils;
    private final SmartSwapService smartSwapService;
    private final SwapTrackingRepository swapTrackingRepository;

    /**
     * Récupère la liste paginée des plans de repas d'un utilisateur.
     *
     * @param userId   identifiant de l'utilisateur
     * @param pageable paramètres de pagination et de tri
     * @return réponse paginée contenant les résumés des plans
     */
    @Transactional(readOnly = true)
    public PagedResponse<MealPlanResponse> getUserMealPlans(UUID userId, Pageable pageable) {
        Page<MealPlan> page = mealPlanRepository.findByUserIdAndDeletedAtIsNull(userId, pageable);
        List<MealPlanResponse> content = page.getContent()
                .stream()
                .map(this::toSummaryResponse)
                .collect(Collectors.toList());

        return PagedResponse.of(content, page.getNumber(), page.getSize(), page.getTotalElements());
    }

    /**
     * Récupère un plan de repas complet par son identifiant.
     * <p>
     * Vérifie que l'utilisateur est bien le propriétaire du plan.
     * </p>
     *
     * @param userId     identifiant de l'utilisateur connecté
     * @param mealPlanId identifiant du plan de repas
     * @return réponse complète du plan avec ses entrées
     * @throws ResourceNotFoundException si le plan n'existe pas
     */
    @Transactional(readOnly = true)
    public MealPlanResponse getMealPlanById(UUID userId, UUID mealPlanId) {
        MealPlan mealPlan = mealPlanRepository.findById(mealPlanId)
                .orElseThrow(() -> new ResourceNotFoundException("MealPlan", "id", mealPlanId.toString()));

        securityUtils.verifyOwnership(mealPlan.getUserId(), userId, "MealPlan", mealPlanId.toString());

        return toFullResponse(mealPlan);
    }

    /**
     * Crée un nouveau plan de repas pour l'utilisateur.
     *
     * @param userId  identifiant de l'utilisateur
     * @param request données du plan à créer
     * @return résumé du plan créé
     * @throws BusinessRuleViolationException si la date de fin est antérieure à la date de début
     */
    public MealPlanResponse createMealPlan(UUID userId, MealPlanRequest request) {
        if (request.getEndDate().isBefore(request.getStartDate())) {
            throw new BusinessRuleViolationException("End date must be after start date");
        }

        MealPlan mealPlan = MealPlan.builder()
                .userId(userId)
                .name(request.getName())
                .startDate(request.getStartDate())
                .endDate(request.getEndDate())
                .status("DRAFT")
                .build();

        MealPlan saved = mealPlanRepository.save(mealPlan);
        return toSummaryResponse(saved);
    }

    /**
     * Ajoute une entrée (repas) à un plan de repas existant.
     * <p>
     * Vérifie que la date du repas est bien comprise dans l'intervalle du plan
     * et que la recette référencée existe.
     * </p>
     *
     * @param userId     identifiant de l'utilisateur connecté
     * @param mealPlanId identifiant du plan de repas
     * @param request    données de l'entrée à ajouter
     * @return réponse complète du plan mis à jour
     */
    public MealPlanResponse addEntry(UUID userId, UUID mealPlanId, MealPlanEntryRequest request) {
        MealPlan mealPlan = mealPlanRepository.findById(mealPlanId)
                .orElseThrow(() -> new ResourceNotFoundException("MealPlan", "id", mealPlanId.toString()));

        securityUtils.verifyOwnership(mealPlan.getUserId(), userId, "MealPlan", mealPlanId.toString());

        if (request.getMealDate().isBefore(mealPlan.getStartDate()) ||
            request.getMealDate().isAfter(mealPlan.getEndDate())) {
            throw new BusinessRuleViolationException("Meal date must be within the plan's date range");
        }

        Recipe recipe = recipeRepository.findById(request.getRecipeId())
                .orElseThrow(() -> new ResourceNotFoundException("Recipe", "id", request.getRecipeId().toString()));

        MealPlanEntry entry = MealPlanEntry.builder()
                .mealPlanId(mealPlanId)
                .recipeId(request.getRecipeId())
                .mealDate(request.getMealDate())
                .mealType(request.getMealType())
                .servings(request.getServings())
                .notes(request.getNotes())
                .build();

        mealPlanEntryRepository.save(entry);

        return toFullResponse(mealPlan);
    }

    /**
     * Supprime une entrée (repas) d'un plan de repas.
     *
     * @param userId  identifiant de l'utilisateur connecté
     * @param entryId identifiant de l'entrée à supprimer
     */
    public void removeEntry(UUID userId, UUID entryId) {
        MealPlanEntry entry = mealPlanEntryRepository.findById(entryId)
                .orElseThrow(() -> new ResourceNotFoundException("MealPlanEntry", "id", entryId.toString()));

        MealPlan mealPlan = mealPlanRepository.findById(entry.getMealPlanId())
                .orElseThrow(() -> new ResourceNotFoundException("MealPlan", "id", entry.getMealPlanId().toString()));

        securityUtils.verifyOwnership(mealPlan.getUserId(), userId, "MealPlan", entry.getMealPlanId().toString());

        mealPlanEntryRepository.delete(entry);
    }

    /**
     * Active un plan de repas en lui attribuant le statut ACTIVE.
     *
     * @param userId     identifiant de l'utilisateur connecté
     * @param mealPlanId identifiant du plan à activer
     */
    public void activateMealPlan(UUID userId, UUID mealPlanId) {
        MealPlan mealPlan = mealPlanRepository.findById(mealPlanId)
                .orElseThrow(() -> new ResourceNotFoundException("MealPlan", "id", mealPlanId.toString()));

        securityUtils.verifyOwnership(mealPlan.getUserId(), userId, "MealPlan", mealPlanId.toString());

        mealPlan.setStatus("ACTIVE");
        mealPlanRepository.save(mealPlan);
    }

    /**
     * Génère un plan de repas hebdomadaire automatique en mode STANDARD.
     *
     * @param userId    identifiant de l'utilisateur
     * @param startDate date de début de la semaine
     * @return réponse complète du plan généré
     */
    public MealPlanResponse generateWeeklyPlan(UUID userId, LocalDate startDate) {
        return generateWeeklyPlan(userId, startDate, MealPlanMode.STANDARD);
    }

    /**
     * Génère un plan de repas hebdomadaire automatique selon un mode donné.
     * <p>
     * Utilise le moteur de recommandation pour proposer des recettes adaptées
     * au mode (STANDARD, WASTELESS, ENDOFMONTH, BUSYWEEK, FAMILY).
     * </p>
     *
     * @param userId    identifiant de l'utilisateur
     * @param startDate date de début de la semaine
     * @param mode      mode de génération du plan
     * @return réponse complète du plan généré
     */
    public MealPlanResponse generateWeeklyPlan(UUID userId, LocalDate startDate, MealPlanMode mode) {
        List<List<RecommendationResult>> weeklyPlan = recommendationEngine.generateWeeklyMealPlan(userId, mode);
        LocalDate endDate = startDate.plusDays(6);

        MealPlan mealPlan = MealPlan.builder()
                .userId(userId)
                .name("Auto-Generated Weekly Plan")
                .startDate(startDate)
                .endDate(endDate)
                .status("ACTIVE")
                .mode(mode.name())
                .build();
        MealPlan saved = mealPlanRepository.save(mealPlan);

        String[] mealTypes = {"Breakfast", "Lunch", "Dinner"};
        for (int day = 0; day < weeklyPlan.size(); day++) {
            List<RecommendationResult> dayMeals = weeklyPlan.get(day);
            LocalDate mealDate = startDate.plusDays(day);
            for (int mealIdx = 0; mealIdx < dayMeals.size() && mealIdx < mealTypes.length; mealIdx++) {
                RecommendationResult result = dayMeals.get(mealIdx);
                MealPlanEntry entry = MealPlanEntry.builder()
                        .mealPlanId(saved.getId())
                        .recipeId(result.recipe().getId())
                        .mealDate(mealDate)
                        .mealType(mealTypes[mealIdx])
                        .servings(result.recipe().getServings())
                        .build();
                mealPlanEntryRepository.save(entry);
            }
        }

        return toFullResponse(saved);
    }

    /**
     * Récupère les options d'échange (swap) disponibles pour une entrée donnée.
     *
     * @param userId  identifiant de l'utilisateur connecté
     * @param entryId identifiant de l'entrée à échanger
     * @param limit   nombre maximum d'options à retourner
     * @return liste des options d'échange disponibles
     */
    public List<SmartSwapService.SwapOption> getSwapOptions(UUID userId, UUID entryId, int limit) {
        MealPlanEntry entry = mealPlanEntryRepository.findById(entryId)
                .orElseThrow(() -> new ResourceNotFoundException("MealPlanEntry", "id", entryId.toString()));
        MealPlan mealPlan = mealPlanRepository.findById(entry.getMealPlanId())
                .orElseThrow(() -> new ResourceNotFoundException("MealPlan", "id", entry.getMealPlanId().toString()));
        securityUtils.verifyOwnership(mealPlan.getUserId(), userId, "MealPlan", entry.getMealPlanId().toString());
        return smartSwapService.getSwapOptions(userId, entryId, limit);
    }

    /**
     * Applique un échange (swap) : remplace la recette d'une entrée par une nouvelle recette.
     * <p>
     * Enregistre également l'échange dans l'historique de suivi.
     * </p>
     *
     * @param userId      identifiant de l'utilisateur connecté
     * @param entryId     identifiant de l'entrée à modifier
     * @param newRecipeId identifiant de la nouvelle recette
     * @return réponse complète du plan mis à jour
     */
    public MealPlanResponse applySwap(UUID userId, UUID entryId, UUID newRecipeId) {
        MealPlanEntry entry = mealPlanEntryRepository.findById(entryId)
                .orElseThrow(() -> new ResourceNotFoundException("MealPlanEntry", "id", entryId.toString()));

        MealPlan mealPlan = mealPlanRepository.findById(entry.getMealPlanId())
                .orElseThrow(() -> new ResourceNotFoundException("MealPlan", "id", entry.getMealPlanId().toString()));

        securityUtils.verifyOwnership(mealPlan.getUserId(), userId, "MealPlan", entry.getMealPlanId().toString());

        Recipe newRecipe = recipeRepository.findById(newRecipeId)
                .orElseThrow(() -> new ResourceNotFoundException("Recipe", "id", newRecipeId.toString()));

        entry.setRecipeId(newRecipeId);
        mealPlanEntryRepository.save(entry);

        swapTrackingRepository.save(SwapTracking.builder()
                .userId(userId)
                .swappedAt(java.time.Instant.now())
                .build());

        return toFullResponse(mealPlan);
    }

    /**
     * Définit le mode d'un plan de repas.
     *
     * @param userId     identifiant de l'utilisateur connecté
     * @param mealPlanId identifiant du plan
     * @param mode       nouveau mode à appliquer
     * @return réponse complète du plan mis à jour
     */
    public MealPlanResponse setMode(UUID userId, UUID mealPlanId, MealPlanMode mode) {
        MealPlan mealPlan = mealPlanRepository.findById(mealPlanId)
                .orElseThrow(() -> new ResourceNotFoundException("MealPlan", "id", mealPlanId.toString()));
        securityUtils.verifyOwnership(mealPlan.getUserId(), userId, "MealPlan", mealPlanId.toString());
        mealPlan.setMode(mode.name());
        mealPlanRepository.save(mealPlan);
        return toFullResponse(mealPlan);
    }

    /**
     * Supprime (soft-delete) un plan de repas.
     *
     * @param userId     identifiant de l'utilisateur connecté
     * @param mealPlanId identifiant du plan à supprimer
     */
    public void deleteMealPlan(UUID userId, UUID mealPlanId) {
        MealPlan mealPlan = mealPlanRepository.findById(mealPlanId)
                .orElseThrow(() -> new ResourceNotFoundException("MealPlan", "id", mealPlanId.toString()));

        securityUtils.verifyOwnership(mealPlan.getUserId(), userId, "MealPlan", mealPlanId.toString());

        mealPlan.softDelete();
        mealPlanRepository.save(mealPlan);
    }

    /**
     * Construit une réponse résumée à partir d'une entité MealPlan.
     *
     * @param mealPlan entité source
     * @return réponse résumée sans les entrées ni les agrégats
     */
    private MealPlanResponse toSummaryResponse(MealPlan mealPlan) {
        return MealPlanResponse.builder()
                .id(mealPlan.getId())
                .name(mealPlan.getName())
                .startDate(mealPlan.getStartDate())
                .endDate(mealPlan.getEndDate())
                .status(mealPlan.getStatus())
                .createdAt(mealPlan.getCreatedAt())
                .updatedAt(mealPlan.getUpdatedAt())
                .build();
    }

    /**
     * Construit une réponse complète à partir d'une entité MealPlan.
     * <p>
     * Inclut les entrées du plan, les informations des recettes associées,
     * ainsi que les agrégats calculés (coût total, temps total, calories, etc.).
     * </p>
     *
     * @param mealPlan entité source
     * @return réponse complète avec entrées et agrégats
     */
    private MealPlanResponse toFullResponse(MealPlan mealPlan) {
        List<MealPlanEntry> entries = mealPlanEntryRepository.findByMealPlanId(mealPlan.getId());

        List<UUID> recipeIds = entries.stream()
                .map(MealPlanEntry::getRecipeId)
                .distinct()
                .collect(Collectors.toList());

        Map<UUID, Recipe> recipeMap = recipeRepository.findAllById(recipeIds).stream()
                .collect(Collectors.toMap(Recipe::getId, Function.identity()));

        List<MealPlanResponse.MealPlanEntryResponse> entryResponses = entries.stream()
                .map(entry -> {
                    Recipe recipe = recipeMap.get(entry.getRecipeId());
                    return MealPlanResponse.MealPlanEntryResponse.builder()
                            .id(entry.getId())
                            .recipeId(entry.getRecipeId())
                            .recipeName(recipe != null ? recipe.getName() : "Unknown")
                            .mealDate(entry.getMealDate())
                            .mealType(entry.getMealType())
                            .servings(entry.getServings())
                            .notes(entry.getNotes())
                            .totalTimeMinutes(recipe != null ? recipe.getTotalTimeMinutes() : null)
                            .caloriesPerServing(recipe != null ? recipe.getCaloriesPerServing() : null)
                            .estimatedCost(recipe != null ? recipe.getEstimatedCost() : null)
                            .imageUrl(recipe != null ? recipe.getImageUrl() : null)
                            .build();
                })
                .collect(Collectors.toList());

        BigDecimal totalCost = entryResponses.stream()
                .map(e -> e.getEstimatedCost() != null ? e.getEstimatedCost() : BigDecimal.ZERO)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
        int totalTime = entryResponses.stream()
                .mapToInt(e -> e.getTotalTimeMinutes() != null ? e.getTotalTimeMinutes() : 0)
                .sum();
        int totalCalories = entryResponses.stream()
                .mapToInt(e -> e.getCaloriesPerServing() != null ? e.getCaloriesPerServing() : 0)
                .sum();
        int mealCount = entryResponses.size();
        BigDecimal costPerMeal = mealCount > 0
                ? totalCost.divide(BigDecimal.valueOf(mealCount), 2, java.math.RoundingMode.HALF_UP)
                : BigDecimal.ZERO;

        return MealPlanResponse.builder()
                .id(mealPlan.getId())
                .name(mealPlan.getName())
                .startDate(mealPlan.getStartDate())
                .endDate(mealPlan.getEndDate())
                .status(mealPlan.getStatus())
                .mode(mealPlan.getMode())
                .entries(entryResponses)
                .totalCost(totalCost)
                .totalTime(totalTime)
                .totalCalories(totalCalories)
                .mealCount(mealCount)
                .costPerMeal(costPerMeal)
                .createdAt(mealPlan.getCreatedAt())
                .updatedAt(mealPlan.getUpdatedAt())
                .build();
    }
}
