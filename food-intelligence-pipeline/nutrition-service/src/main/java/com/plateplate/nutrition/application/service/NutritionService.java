package com.plateplate.nutrition.application.service;

import com.plateplate.nutrition.domain.model.NutritionFact;
import com.plateplate.nutrition.domain.model.RecipeNutrition;
import com.plateplate.nutrition.infrastructure.repository.NutritionFactRepository;
import org.springframework.stereotype.Service;

import java.util.Optional;

@Service
public class NutritionService {

    private final NutritionFactRepository nutritionFactRepository;

    public NutritionService(NutritionFactRepository nutritionFactRepository) {
        this.nutritionFactRepository = nutritionFactRepository;
    }

    public Optional<NutritionFact> findByIngredientId(String ingredientId) {
        return nutritionFactRepository.findByIngredientId(ingredientId);
    }

    public boolean isReasonable(RecipeNutrition nutrition) {
        if (nutrition.getCaloriesPerServing() != null &&
                (nutrition.getCaloriesPerServing() <= 0 || nutrition.getCaloriesPerServing() >= 2000))
            return false;
        if (nutrition.getProteinGrams() != null &&
                (nutrition.getProteinGrams() < 0 || nutrition.getProteinGrams() > 100))
            return false;
        if (nutrition.getCarbsGrams() != null &&
                (nutrition.getCarbsGrams() < 0 || nutrition.getCarbsGrams() > 200))
            return false;
        if (nutrition.getFatGrams() != null &&
                (nutrition.getFatGrams() < 0 || nutrition.getFatGrams() > 100))
            return false;
        return true;
    }

    public int calculateTotalCalories(RecipeNutrition nutrition) {
        if (nutrition.getCaloriesPerServing() == null || nutrition.getServings() == null)
            return 0;
        return nutrition.getCaloriesPerServing() * nutrition.getServings();
    }
}
