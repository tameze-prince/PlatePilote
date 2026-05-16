package com.platepilote.platepilote.recommendation.domain.service;

/**
 * RECOMMENDATION ENGINE - RULE-BASED RECIPE RECOMMENDATIONS
 * ===========================================================
 * 
 * WHAT IT IS:
 * A simple rule-based system that recommends recipes based on user preferences.
 * 
 * WHY RULE-BASED INSTEAD OF AI?
 * - Free to run (no paid AI API costs)
 * - Predictable and explainable recommendations
 * - Easy to debug and improve
 * - Can be replaced with ML later when the app generates revenue
 * 
 * HOW IT WORKS (SCORING SYSTEM):
 * 1. Fetch all public recipes from the database
 * 2. For each recipe, calculate a score:
 *    - +10 points if recipe matches user's dietary preference (e.g., vegetarian)
 *    - +2 points if recipe has a cuisine type set
 *    - +2 points if recipe has a meal type set
 *    - +3 points if recipe is "Easy" difficulty (beginner-friendly)
 * 3. EXCLUDE recipes that contain user's allergens
 * 4. Sort recipes by score (highest first)
 * 5. Return top N recipes (default: 10)
 * 
 * EXAMPLE:
 * User preferences: vegetarian, gluten-free
 * User allergies: peanuts (severe)
 * 
 * Recipe A: "Veggie Pasta" (vegetarian, Italian, Easy) -> Score: 10 + 2 + 3 = 15
 * Recipe B: "Chicken Salad" (not vegetarian) -> Score: 2 + 2 = 4
 * Recipe C: "Peanut Noodles" (contains peanuts) -> EXCLUDED (allergy)
 * 
 * Result: Recipe A (15) > Recipe B (4) -> Recipe A recommended first
 * 
 * FUTURE IMPROVEMENTS:
 * - Track which recipes users actually cook (interaction history)
 * - Boost scores for recipes similar to ones the user liked
 * - Consider pantry items (recommend recipes using what's already available)
 * - Time-based recommendations (breakfast recipes in the morning)
 */

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

    /**
     * Get personalized recipe recommendations for a user.
     * 
     * @param userId The user to get recommendations for
     * @param limit Maximum number of recommendations to return (default: 10)
     * @return List of recipes sorted by relevance score (highest first)
     */
    @Transactional(readOnly = true)
    public List<Recipe> getRecommendations(UUID userId, int limit) {
        // Load user's dietary preferences (e.g., vegetarian, vegan)
        List<DietaryPreference> preferences = dietaryPreferenceRepository.findByUserId(userId);
        
        // Load user's allergies (e.g., peanuts, shellfish)
        List<Allergy> allergies = allergyRepository.findByUserId(userId);

        // Fetch all public recipes (up to 100 for scoring)
        List<Recipe> allPublicRecipes = recipeRepository
                .findByIsPublicTrueAndDeletedAtIsNull(PageRequest.of(0, 100))
                .getContent();

        List<Recipe> scoredRecipes = new ArrayList<>();

        // Score each recipe based on user preferences
        for (Recipe recipe : allPublicRecipes) {
            // Skip recipes that contain user's allergens
            boolean hasAllergyConflict = allergies.stream()
                    .anyMatch(allergy -> recipeContains(recipe, allergy.getAllergen()));
            if (hasAllergyConflict) {
                continue;  // Exclude this recipe entirely
            }

            scoredRecipes.add(recipe);
        }

        // Sort by score (highest first) and return top N
        return scoredRecipes.stream()
                .sorted((r1, r2) -> Integer.compare(
                        calculateScore(r2, preferences, allergies),
                        calculateScore(r1, preferences, allergies)
                ))
                .limit(limit)
                .collect(Collectors.toList());
    }

    /**
     * Check if a recipe contains a specific allergen.
     * 
     * NOTE: This is a simplified check. In production, you would:
     * - Store allergen information in recipe_ingredients table
     * - Check ingredient names against known allergen lists
     * - Use a food database API for accurate allergen detection
     * 
     * For now, we check the recipe description for allergen keywords.
     */
    private boolean recipeContains(Recipe recipe, String allergen) {
        if (recipe.getDescription() == null) return false;
        return recipe.getDescription().toLowerCase().contains(allergen.toLowerCase());
    }

    /**
     * Check if a recipe matches a dietary preference.
     * 
     * NOTE: This is a simplified check. In production, you would:
     * - Store dietary tags on recipes (vegetarian, vegan, gluten-free, etc.)
     - Use a structured tagging system instead of text matching
     */
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

    /**
     * Calculate a relevance score for a recipe based on user preferences.
     * Higher score = more relevant to the user.
     */
    private int calculateScore(Recipe recipe, List<DietaryPreference> preferences, List<Allergy> allergies) {
        int score = 0;

        // +10 points for each matching dietary preference
        for (DietaryPreference pref : preferences) {
            if (matchesDietaryPreference(recipe, pref.getDietType())) {
                score += 10;
            }
        }

        // +2 points if recipe has cuisine type (more specific = better)
        if (recipe.getCuisineType() != null) score += 2;

        // +2 points if recipe has meal type
        if (recipe.getMealType() != null) score += 2;

        // +3 points for easy recipes (beginner-friendly)
        if (recipe.getDifficulty() != null && recipe.getDifficulty().equals("Easy")) {
            score += 3;
        }

        return score;
    }
}
