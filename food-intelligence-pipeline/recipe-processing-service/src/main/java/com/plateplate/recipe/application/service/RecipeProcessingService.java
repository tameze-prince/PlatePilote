package com.plateplate.recipe.application.service;

import com.plateplate.common.util.IngredientLineParser;
import com.plateplate.recipe.domain.model.Recipe;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.UUID;

@Service
public class RecipeProcessingService {

    public IngredientLineParser.ParsedIngredient parseIngredientLine(String line) {
        return IngredientLineParser.parse(line);
    }

    public Recipe createRecipe(String title, String cuisine, List<String> ingredientLines, List<String> steps) {
        Recipe recipe = new Recipe();
        recipe.setId(UUID.randomUUID().toString());
        recipe.setTitle(title);
        recipe.setCuisine(cuisine);
        recipe.setIngredientLines(ingredientLines);
        recipe.setSteps(steps);
        return recipe;
    }

    public boolean isValidIngredientFormat(String line) {
        return IngredientLineParser.parse(line) != null;
    }
}
