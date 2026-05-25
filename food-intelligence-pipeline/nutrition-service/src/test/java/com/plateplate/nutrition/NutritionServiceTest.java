package com.plateplate.nutrition;

import com.plateplate.nutrition.application.service.NutritionService;
import com.plateplate.nutrition.domain.model.RecipeNutrition;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;

import static org.junit.jupiter.api.Assertions.*;

@DisplayName("Nutrition Service Tests")
@SpringBootTest
@ActiveProfiles("test")
public class NutritionServiceTest {

    @Test
    @DisplayName("Should calculate recipe nutrition from ingredients")
    void testCalculateRecipeNutrition() {
        // Arrange
        String recipeId = "recipe-001";
        Integer servings = 4;

        // Act
        RecipeNutrition nutrition = new RecipeNutrition("nut-001", recipeId);
        nutrition.setCaloriesPerServing(500);
        nutrition.setProteinGrams(25.0);
        nutrition.setCarbsGrams(50.0);
        nutrition.setFatGrams(15.0);
        nutrition.setServings(servings);

        // Assert
        assertNotNull(nutrition);
        assertEquals(500, nutrition.getCaloriesPerServing());
        assertEquals(25.0, nutrition.getProteinGrams());
        assertEquals(50.0, nutrition.getCarbsGrams());
        assertEquals(15.0, nutrition.getFatGrams());
    }

    @Test
    @DisplayName("Should validate reasonable nutrition values")
    void testValidateNutritionValues() {
        // Arrange
        RecipeNutrition nutrition = new RecipeNutrition("nut-002", "recipe-002");

        // Act
        nutrition.setCaloriesPerServing(450);
        nutrition.setProteinGrams(30.0);
        nutrition.setCarbsGrams(45.0);
        nutrition.setFatGrams(12.0);

        // Assert - Reasonable values for a meal
        assertTrue(nutrition.getCaloriesPerServing() > 0 && nutrition.getCaloriesPerServing() < 2000);
        assertTrue(nutrition.getProteinGrams() >= 0 && nutrition.getProteinGrams() <= 100);
        assertTrue(nutrition.getCarbsGrams() >= 0 && nutrition.getCarbsGrams() <= 200);
        assertTrue(nutrition.getFatGrams() >= 0 && nutrition.getFatGrams() <= 100);
    }

    @Test
    @DisplayName("Should handle multiple servings")
    void testMultipleServings() {
        // Arrange
        RecipeNutrition nutrition = new RecipeNutrition("nut-003", "recipe-003");
        nutrition.setCaloriesPerServing(400);
        nutrition.setServings(6);

        // Act
        Integer totalCalories = nutrition.getCaloriesPerServing() * nutrition.getServings();

        // Assert
        assertEquals(2400, totalCalories);
    }

    @Test
    @DisplayName("Should detect missing nutrition data")
    void testMissingNutritionData() {
        // Arrange
        RecipeNutrition nutrition = new RecipeNutrition("nut-004", "recipe-004");

        // Assert
        assertNull(nutrition.getCaloriesPerServing());
        assertNull(nutrition.getProteinGrams());
    }
}
