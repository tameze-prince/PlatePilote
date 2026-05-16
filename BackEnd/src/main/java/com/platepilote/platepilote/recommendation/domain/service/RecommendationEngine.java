package com.platepilote.platepilote.recommendation.domain.service;

import com.platepilote.platepilote.pantry.domain.entity.PantryItem;
import com.platepilote.platepilote.pantry.domain.repository.PantryItemRepository;
import com.platepilote.platepilote.preferences.domain.entity.Allergy;
import com.platepilote.platepilote.preferences.domain.entity.DietaryPreference;
import com.platepilote.platepilote.preferences.domain.repository.AllergyRepository;
import com.platepilote.platepilote.preferences.domain.repository.DietaryPreferenceRepository;
import com.platepilote.platepilote.recipes.domain.entity.Recipe;
import com.platepilote.platepilote.recipes.domain.repository.RecipeRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class RecommendationEngine {

    private final RecipeRepository recipeRepository;
    private final DietaryPreferenceRepository dietaryPreferenceRepository;
    private final AllergyRepository allergyRepository;
    private final PantryItemRepository pantryItemRepository;

    @Transactional(readOnly = true)
    public List<RecommendationResult> getRecommendations(UUID userId, int limit) {
        List<DietaryPreference> preferences = dietaryPreferenceRepository.findByUserId(userId);
        List<Allergy> allergies = allergyRepository.findByUserId(userId);
        List<PantryItem> pantryItems = pantryItemRepository
                .findByUserIdAndDeletedAtIsNull(userId, PageRequest.of(0, 100))
                .getContent();

        List<Recipe> allPublicRecipes = recipeRepository
                .findByIsPublicTrueAndDeletedAtIsNull(PageRequest.of(0, 100))
                .getContent();

        List<RecommendationResult> scoredRecipes = new ArrayList<>();

        for (Recipe recipe : allPublicRecipes) {
            boolean hasAllergyConflict = allergies.stream()
                    .anyMatch(allergy -> recipeContains(recipe, allergy.getAllergen()));

            if (hasAllergyConflict) {
                continue;
            }

            int score = calculateScore(recipe, preferences, pantryItems);
            scoredRecipes.add(new RecommendationResult(recipe, score));
        }

        return scoredRecipes.stream()
                .sorted((r1, r2) -> Integer.compare(r2.score(), r1.score()))
                .limit(limit)
                .collect(Collectors.toList());
    }

    private boolean recipeContains(Recipe recipe, String allergen) {
        if (recipe.getDescription() == null) return false;
        return recipe.getDescription().toLowerCase().contains(allergen.toLowerCase());
    }

    private int calculateScore(Recipe recipe, List<DietaryPreference> preferences, List<PantryItem> pantryItems) {
        int score = 0;

        for (DietaryPreference pref : preferences) {
            if (matchesDietaryPreference(recipe, pref.getDietType())) {
                score += 10;
            }
        }

        if (recipe.getCuisineType() != null) score += 2;
        if (recipe.getMealType() != null) score += 2;
        if (recipe.getDifficulty() != null && recipe.getDifficulty().equals("Easy")) {
            score += 3;
        }

        for (PantryItem item : pantryItems) {
            if (recipeContains(recipe, item.getName())) {
                score += 5;
            }

            if (item.getExpirationDate() != null &&
                item.getExpirationDate().isBefore(LocalDate.now().plusDays(3))) {
                if (recipeContains(recipe, item.getName())) {
                    score += 10;
                }
            }
        }

        return score;
    }

    private boolean matchesDietaryPreference(Recipe recipe, String dietType) {
        if (recipe.getDescription() == null) return false;
        String desc = recipe.getDescription().toLowerCase();
        return switch (dietType.toLowerCase()) {
            case "vegetarian" -> desc.contains("vegetarian") || desc.contains("meat-free");
            case "vegan" -> desc.contains("vegan") || desc.contains("plant-based");
            case "gluten-free" -> desc.contains("gluten-free");
            case "dairy-free" -> desc.contains("dairy-free");
            default -> false;
        };
    }

    public record RecommendationResult(Recipe recipe, int score) {}
}
