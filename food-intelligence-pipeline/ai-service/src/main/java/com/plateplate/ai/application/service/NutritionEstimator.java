package com.plateplate.ai.application.service;

import com.plateplate.ai.domain.model.EstimatedNutrition;
import com.plateplate.ai.domain.model.ParsedIngredientLine;
import com.plateplate.ai.domain.model.ParsedRecipe;

import java.util.List;

public interface NutritionEstimator {
    EstimatedNutrition estimate(List<ParsedIngredientLine> ingredients);
    EstimatedNutrition estimate(ParsedRecipe recipe);
    boolean canEstimate(List<ParsedIngredientLine> ingredients);
}
