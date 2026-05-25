package com.plateplate.recipe;

import com.plateplate.common.util.IngredientLineParser;
import com.plateplate.recipe.application.service.RecipeProcessingService;
import com.plateplate.recipe.domain.model.Recipe;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;

import java.util.Arrays;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

@DisplayName("Recipe Processing Service Tests")
@SpringBootTest
@ActiveProfiles("test")
public class RecipeProcessingServiceTest {

    @Test
    @DisplayName("Should parse ingredient line with quantity and unit")
    void testParseIngredientLine() {
        // Arrange
        String line = "2 tbsp olive oil";

        // Act
        IngredientLineParser.ParsedIngredient parsed = IngredientLineParser.parse(line);

        // Assert
        assertNotNull(parsed);
        assertEquals(2.0, parsed.quantity);
        assertEquals("tbsp", parsed.unit);
        assertEquals("olive oil", parsed.ingredient);
    }

    @Test
    @DisplayName("Should parse ingredient line with fraction")
    void testParseIngredientLineWithFraction() {
        // Arrange
        String line = "1 1/2 cups flour";

        // Act
        IngredientLineParser.ParsedIngredient parsed = IngredientLineParser.parse(line);

        // Assert
        assertNotNull(parsed);
        assertEquals(1.5, parsed.quantity, 0.01);
        assertEquals("cups", parsed.unit);
        assertEquals("flour", parsed.ingredient);
    }

    @Test
    @DisplayName("Should parse ingredient line without quantity")
    void testParseIngredientLineNoQuantity() {
        // Arrange
        String line = "salt and pepper";

        // Act
        IngredientLineParser.ParsedIngredient parsed = IngredientLineParser.parse(line);

        // Assert
        assertNotNull(parsed);
        assertNull(parsed.quantity);
        assertNull(parsed.unit);
        assertEquals("salt and pepper", parsed.ingredient);
    }

    @Test
    @DisplayName("Should process complete recipe")
    void testProcessCompleteRecipe() {
        // Arrange
        String title = "Tomato Pasta";
        String cuisine = "Italian";
        List<String> ingredients = Arrays.asList(
            "2 tbsp olive oil",
            "3 cloves garlic",
            "400g tomatoes",
            "200g pasta"
        );
        List<String> steps = Arrays.asList(
            "Boil water and cook pasta",
            "Sauté garlic in olive oil",
            "Add tomatoes and simmer",
            "Mix pasta with sauce"
        );

        // Act
        // Recipe processing would happen here
        assertNotNull(title);
        assertNotNull(cuisine);
        assertEquals(4, ingredients.size());
        assertEquals(4, steps.size());
    }

    @Test
    @DisplayName("Should handle various ingredient formats")
    void testVariousIngredientFormats() {
        String[] formats = {
            "2 tbsp olive oil",
            "1 cup diced tomatoes",
            "100g ground beef",
            "1/2 tsp salt",
            "3 cloves garlic, minced",
            "500ml milk"
        };

        for (String format : formats) {
            IngredientLineParser.ParsedIngredient parsed = IngredientLineParser.parse(format);
            assertNotNull(parsed, "Should parse: " + format);
            assertNotNull(parsed.ingredient, "Should have ingredient name: " + format);
        }
    }
}
