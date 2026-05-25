package com.plateplate.ai;

import com.plateplate.ai.application.service.DefaultRecipeTextParser;
import com.plateplate.ai.domain.model.ParsedIngredientLine;
import com.plateplate.ai.domain.model.ParsedRecipe;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

class DefaultRecipeTextParserTest {

    private DefaultRecipeTextParser parser;

    @BeforeEach
    void setUp() {
        parser = new DefaultRecipeTextParser();
    }

    @Test
    void parseNullReturnsUnknown() {
        ParsedRecipe result = parser.parse(null);
        assertEquals("Unknown", result.getTitle());
        assertTrue(result.getIngredients().isEmpty());
        assertTrue(result.getSteps().isEmpty());
    }

    @Test
    void parseBlankReturnsUnknown() {
        ParsedRecipe result = parser.parse("   ");
        assertEquals("Unknown", result.getTitle());
        assertTrue(result.getIngredients().isEmpty());
        assertTrue(result.getSteps().isEmpty());
    }

    @Test
    void parseSimpleRecipeWithMarkdownTitle() {
        String text = "# Classic Pancakes\n\n" +
            "Ingredients:\n" +
            "1 cup flour\n" +
            "2 eggs\n" +
            "1/2 cup milk\n\n" +
            "Instructions:\n" +
            "Mix dry ingredients.\n" +
            "Add wet ingredients.\n" +
            "Cook on medium heat.";

        ParsedRecipe recipe = parser.parse(text);

        assertEquals("Classic Pancakes", recipe.getTitle());
        assertEquals(3, recipe.getIngredients().size());
        assertEquals("flour", recipe.getIngredients().get(0).getName());
        assertEquals(1.0, recipe.getIngredients().get(0).getQuantity());
        assertEquals(3, recipe.getSteps().size());
    }

    @Test
    void parseRecipeWithTitleHeader() {
        String text = "Title: Chicken Soup\n\n" +
            "Ingredients:\n" +
            "2 chicken breasts\n" +
            "4 cups broth\n\n" +
            "Directions:\n" +
            "Boil broth.\n" +
            "Add chicken.\n" +
            "Simmer 20 min.";

        ParsedRecipe recipe = parser.parse(text);

        assertEquals("Chicken Soup", recipe.getTitle());
    }

    @Test
    void parseNoIngredientsSectionReturnsEmptyIngredients() {
        String text = "# Simple Salad\n\nJust mix everything together.";
        ParsedRecipe recipe = parser.parse(text);
        assertTrue(recipe.getIngredients().isEmpty());
    }

    @Test
    void parseRecipeWithPrepAndCookTime() {
        String text = "# Pasta\n\n" +
            "Prep time: 10 min\n" +
            "Cook time: 15 min\n" +
            "Servings: 4\n\n" +
            "Ingredients:\n" +
            "200g pasta\n\n" +
            "Instructions:\n" +
            "Boil water.\n" +
            "Cook pasta.";

        ParsedRecipe recipe = parser.parse(text);
        assertEquals(Integer.valueOf(10), recipe.getPrepTimeMinutes());
        assertEquals(Integer.valueOf(15), recipe.getCookTimeMinutes());
        assertEquals(Integer.valueOf(4), recipe.getServings());
    }

    @Test
    void parseFrenchRecipe() {
        String text = "# Omelette\n\n" +
            "Ingrédients:\n" +
            "3 eggs\n" +
            "1 tbsp butter\n\n" +
            "Préparation:\n" +
            "Battre les œufs.\n" +
            "Cuire dans le beurre.";

        ParsedRecipe recipe = parser.parse(text);
        assertEquals("Omelette", recipe.getTitle());
        assertEquals(2, recipe.getIngredients().size());
        assertEquals(2, recipe.getSteps().size());
    }

    @Test
    void canHandleReturnsTrueForNonBlank() {
        assertTrue(parser.canHandle("some text"));
        assertFalse(parser.canHandle(null));
        assertFalse(parser.canHandle(""));
    }

    @Test
    void confidenceScoreIncreasesWithMoreData() {
        String full = "# Recipe\n\nIngredients:\n1 cup sugar\n2 eggs\n\nInstructions:\nStep 1\nStep 2\nStep 3";
        ParsedRecipe recipe = parser.parse(full);
        assertTrue(recipe.getConfidenceScore() >= 0.8);
    }

    @Test
    void extractIngredientsUsesIngredientLineParser() {
        String text = "# Test\n\nIngredients:\n" +
            "2 tbsp olive oil\n" +
            "1 lb chicken breast\n" +
            "3 cloves garlic\n\n" +
            "Instructions:\nCook.";

        ParsedRecipe recipe = parser.parse(text);
        assertEquals(3, recipe.getIngredients().size());

        ParsedIngredientLine oil = recipe.getIngredients().get(0);
        assertEquals("olive oil", oil.getName());
        assertEquals(2.0, oil.getQuantity());
        assertEquals("tbsp", oil.getUnit());

        ParsedIngredientLine chicken = recipe.getIngredients().get(1);
        assertEquals("chicken breast", chicken.getName());
        assertEquals(1.0, chicken.getQuantity());
        assertEquals("lb", chicken.getUnit());
    }

    @Test
    void extractStepsRemovesNumbering() {
        String text = "# Recipe\n\nIngredients:\n1 cup sugar\n\nInstructions:\n1. First step\n2. Second step\n3. Third step";
        ParsedRecipe recipe = parser.parse(text);
        assertEquals(3, recipe.getSteps().size());
        assertEquals("First step", recipe.getSteps().get(0));
        assertEquals("Second step", recipe.getSteps().get(1));
    }
}
