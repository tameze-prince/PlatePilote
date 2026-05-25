package com.plateplate.ai;

import com.plateplate.ai.application.service.DefaultNutritionEstimator;
import com.plateplate.ai.domain.model.EstimatedNutrition;
import com.plateplate.ai.domain.model.ParsedIngredientLine;
import com.plateplate.ai.domain.model.ParsedRecipe;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

class DefaultNutritionEstimatorTest {

    private DefaultNutritionEstimator estimator;

    @BeforeEach
    void setUp() {
        estimator = new DefaultNutritionEstimator();
    }

    @Test
    void estimateSingleIngredient() {
        List<ParsedIngredientLine> ingredients = List.of(
            new ParsedIngredientLine("100g chicken breast", 100.0, "g", "chicken breast")
        );

        EstimatedNutrition nutrition = estimator.estimate(ingredients);

        assertNotNull(nutrition);
        assertEquals(165, nutrition.getCalories());
        assertEquals(31, nutrition.getProteinGrams());
        assertEquals(0, nutrition.getCarbsGrams());
        assertEquals(3.6, nutrition.getFatGrams());
    }

    @Test
    void estimateMultipleIngredients() {
        List<ParsedIngredientLine> ingredients = List.of(
            new ParsedIngredientLine("200g chicken breast", 200.0, "g", "chicken breast"),
            new ParsedIngredientLine("100g rice", 100.0, "g", "rice")
        );

        EstimatedNutrition nutrition = estimator.estimate(ingredients);

        assertEquals(460, nutrition.getCalories());
        assertEquals(64.7, nutrition.getProteinGrams());
        assertEquals(28, nutrition.getCarbsGrams());
        assertEquals(7.5, nutrition.getFatGrams());
    }

    @Test
    void estimateEmptyIngredientsReturnsZero() {
        EstimatedNutrition nutrition = estimator.estimate(List.of());
        assertEquals(0.0, nutrition.getCalories());
        assertEquals(0.0, nutrition.getConfidenceScore());
    }

    @Test
    void estimateNullIngredientsReturnsZero() {
        EstimatedNutrition nutrition = estimator.estimate((List<ParsedIngredientLine>) null);
        assertEquals(0.0, nutrition.getCalories());
    }

    @Test
    void estimateFromParsedRecipe() {
        ParsedRecipe recipe = new ParsedRecipe("Test", List.of(
            new ParsedIngredientLine("150g salmon", 150.0, "g", "salmon")
        ), List.of("Cook."));
        recipe.setServings(2);

        EstimatedNutrition nutrition = estimator.estimate(recipe);
        assertNotNull(nutrition);
        assertEquals(312, nutrition.getCalories());
        assertEquals(Integer.valueOf(2), nutrition.getServings());
    }

    @Test
    void estimateVolumeBasedIngredient() {
        List<ParsedIngredientLine> ingredients = List.of(
            new ParsedIngredientLine("1 cup olive oil", 1.0, "cup", "olive oil")
        );

        EstimatedNutrition nutrition = estimator.estimate(ingredients);
        assertNotNull(nutrition);
        assertTrue(nutrition.getCalories() > 0);
    }

    @Test
    void estimateUnknownIngredientReturnsZero() {
        List<ParsedIngredientLine> ingredients = List.of(
            new ParsedIngredientLine("100g unicorn meat", 100.0, "g", "unicorn meat")
        );

        EstimatedNutrition nutrition = estimator.estimate(ingredients);
        assertEquals(0.0, nutrition.getCalories());
        assertEquals(0.2, nutrition.getConfidenceScore());
    }

    @Test
    void estimatePartialMatch() {
        List<ParsedIngredientLine> ingredients = List.of(
            new ParsedIngredientLine("100g chicken breast", 100.0, "g", "chicken breast"),
            new ParsedIngredientLine("50g unicorn dust", 50.0, "g", "unicorn dust")
        );

        EstimatedNutrition nutrition = estimator.estimate(ingredients);
        assertTrue(nutrition.getConfidenceScore() >= 0.5);
    }

    @Test
    void estimateWithOunces() {
        List<ParsedIngredientLine> ingredients = List.of(
            new ParsedIngredientLine("8 oz chicken breast", 8.0, "oz", "chicken breast")
        );

        EstimatedNutrition nutrition = estimator.estimate(ingredients);
        assertTrue(nutrition.getCalories() > 300);
        assertTrue(nutrition.getCalories() < 400);
    }

    @Test
    void canEstimateReturnsTrueWhenIngredientsHaveNames() {
        assertTrue(estimator.canEstimate(List.of(
            new ParsedIngredientLine("1 cup sugar", 1.0, "cup", "sugar")
        )));
        assertFalse(estimator.canEstimate(List.of()));
        assertFalse(estimator.canEstimate(null));
    }

    @Test
    void perIngredientCaloriesMapping() {
        List<ParsedIngredientLine> ingredients = List.of(
            new ParsedIngredientLine("100g chicken breast", 100.0, "g", "chicken breast"),
            new ParsedIngredientLine("100g rice", 100.0, "g", "rice")
        );

        EstimatedNutrition nutrition = estimator.estimate(ingredients);
        assertTrue(nutrition.getPerIngredientCalories().containsKey("chicken breast"));
        assertTrue(nutrition.getPerIngredientCalories().containsKey("rice"));
    }
}
