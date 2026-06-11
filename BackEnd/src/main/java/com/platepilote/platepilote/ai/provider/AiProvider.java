package com.platepilote.platepilote.ai.provider;

import com.platepilote.platepilote.ai.provider.dto.MealPlanRequest;
import com.platepilote.platepilote.ai.provider.dto.MealPlanResponse;
import com.platepilote.platepilote.ai.provider.dto.NutritionLabelRequest;
import com.platepilote.platepilote.ai.provider.dto.NutritionLabelResponse;
import com.platepilote.platepilote.ai.provider.dto.SubstitutionRequest;
import com.platepilote.platepilote.ai.provider.dto.SubstitutionResponse;

import java.util.List;
import java.util.Map;
import java.util.Optional;

/**
 * Interface for AI providers that power PlatePilote's smart features.
 * <p>
 * Implementations handle communication with different AI backends
 * (OpenAI GPT-4o mini, Google Gemini 1.5 flash, etc.) for:
 * <ul>
 *   <li>Meal plan generation based on preferences and constraints</li>
 *   <li>Nutrition label parsing and analysis</li>
 *   <li>Ingredient substitution suggestions</li>
 * </ul>
 */
public interface AiProvider {

    /**
     * Generates a personalized meal plan based on user preferences and constraints.
     *
     * @param request the meal plan request with dietary preferences, budget, allergies, etc.
     * @return the generated meal plan or empty if the provider fails
     */
    Optional<MealPlanResponse> generateMealPlan(MealPlanRequest request);

    /**
     * Parses a nutrition label image or text to extract nutritional information.
     *
     * @param request the nutrition label request with image URL or raw text
     * @return parsed nutrition data or empty if parsing fails
     */
    Optional<NutritionLabelResponse> parseNutritionLabel(NutritionLabelRequest request);

    /**
     * Suggests healthier or more affordable ingredient substitutions.
     *
     * @param request the substitution request with original ingredient and constraints
     * @return list of suggested substitutions ordered by preference
     */
    List<SubstitutionResponse> suggestSubstitutions(SubstitutionRequest request);

    /**
     * Returns the provider name for logging and selection purposes.
     *
     * @return the provider identifier (e.g., "openai", "gemini")
     */
    String getProviderName();

    /**
     * Checks if this provider is available and properly configured.
     *
     * @return true if the provider can handle requests
     */
    boolean isAvailable();
}