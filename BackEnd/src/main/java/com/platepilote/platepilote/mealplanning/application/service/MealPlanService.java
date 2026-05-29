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

import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.function.Function;
import java.util.stream.Collectors;

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

    @Transactional(readOnly = true)
    public PagedResponse<MealPlanResponse> getUserMealPlans(UUID userId, Pageable pageable) {
        Page<MealPlan> page = mealPlanRepository.findByUserIdAndDeletedAtIsNull(userId, pageable);
        List<MealPlanResponse> content = page.getContent()
                .stream()
                .map(this::toSummaryResponse)
                .collect(Collectors.toList());

        return PagedResponse.of(content, page.getNumber(), page.getSize(), page.getTotalElements());
    }

    @Transactional(readOnly = true)
    public MealPlanResponse getMealPlanById(UUID userId, UUID mealPlanId) {
        MealPlan mealPlan = mealPlanRepository.findById(mealPlanId)
                .orElseThrow(() -> new ResourceNotFoundException("MealPlan", "id", mealPlanId.toString()));

        securityUtils.verifyOwnership(mealPlan.getUserId(), userId, "MealPlan", mealPlanId.toString());

        return toFullResponse(mealPlan);
    }

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

    public void removeEntry(UUID userId, UUID entryId) {
        MealPlanEntry entry = mealPlanEntryRepository.findById(entryId)
                .orElseThrow(() -> new ResourceNotFoundException("MealPlanEntry", "id", entryId.toString()));

        MealPlan mealPlan = mealPlanRepository.findById(entry.getMealPlanId())
                .orElseThrow(() -> new ResourceNotFoundException("MealPlan", "id", entry.getMealPlanId().toString()));

        securityUtils.verifyOwnership(mealPlan.getUserId(), userId, "MealPlan", entry.getMealPlanId().toString());

        mealPlanEntryRepository.delete(entry);
    }

    public void activateMealPlan(UUID userId, UUID mealPlanId) {
        MealPlan mealPlan = mealPlanRepository.findById(mealPlanId)
                .orElseThrow(() -> new ResourceNotFoundException("MealPlan", "id", mealPlanId.toString()));

        securityUtils.verifyOwnership(mealPlan.getUserId(), userId, "MealPlan", mealPlanId.toString());

        mealPlan.setStatus("ACTIVE");
        mealPlanRepository.save(mealPlan);
    }

    public MealPlanResponse generateWeeklyPlan(UUID userId, LocalDate startDate) {
        List<List<RecommendationResult>> weeklyPlan = recommendationEngine.generateWeeklyMealPlan(userId);
        LocalDate endDate = startDate.plusDays(6);

        MealPlan mealPlan = MealPlan.builder()
                .userId(userId)
                .name("Auto-Generated Weekly Plan")
                .startDate(startDate)
                .endDate(endDate)
                .status("ACTIVE")
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

    public List<SmartSwapService.SwapOption> getSwapOptions(UUID userId, UUID entryId, int limit) {
        MealPlanEntry entry = mealPlanEntryRepository.findById(entryId)
                .orElseThrow(() -> new ResourceNotFoundException("MealPlanEntry", "id", entryId.toString()));
        MealPlan mealPlan = mealPlanRepository.findById(entry.getMealPlanId())
                .orElseThrow(() -> new ResourceNotFoundException("MealPlan", "id", entry.getMealPlanId().toString()));
        securityUtils.verifyOwnership(mealPlan.getUserId(), userId, "MealPlan", entry.getMealPlanId().toString());
        return smartSwapService.getSwapOptions(userId, entryId, limit);
    }

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

        return toFullResponse(mealPlan);
    }

    public void deleteMealPlan(UUID userId, UUID mealPlanId) {
        MealPlan mealPlan = mealPlanRepository.findById(mealPlanId)
                .orElseThrow(() -> new ResourceNotFoundException("MealPlan", "id", mealPlanId.toString()));

        securityUtils.verifyOwnership(mealPlan.getUserId(), userId, "MealPlan", mealPlanId.toString());

        mealPlan.softDelete();
        mealPlanRepository.save(mealPlan);
    }

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

        return MealPlanResponse.builder()
                .id(mealPlan.getId())
                .name(mealPlan.getName())
                .startDate(mealPlan.getStartDate())
                .endDate(mealPlan.getEndDate())
                .status(mealPlan.getStatus())
                .entries(entryResponses)
                .createdAt(mealPlan.getCreatedAt())
                .updatedAt(mealPlan.getUpdatedAt())
                .build();
    }
}
