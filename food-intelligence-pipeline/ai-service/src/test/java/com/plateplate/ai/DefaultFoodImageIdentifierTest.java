package com.plateplate.ai;

import com.plateplate.ai.application.service.DefaultFoodImageIdentifier;
import com.plateplate.ai.domain.model.FoodIdentification;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

class DefaultFoodImageIdentifierTest {

    private DefaultFoodImageIdentifier identifier;

    @BeforeEach
    void setUp() {
        identifier = new DefaultFoodImageIdentifier();
    }

    @Test
    void identifyPizzaUrl() {
        FoodIdentification result = identifier.identify("https://example.com/pizza.jpg");
        assertEquals("Pizza", result.getFoodName());
        assertTrue(result.getConfidenceScore() > 0.5);
        assertTrue(result.getCategories().contains("Italian"));
    }

    @Test
    void identifySaladUrl() {
        FoodIdentification result = identifier.identify("https://example.com/salad.png");
        assertEquals("Salad", result.getFoodName());
        assertTrue(result.getCategories().contains("Healthy"));
    }

    @Test
    void identifyNullUrlReturnsFallback() {
        FoodIdentification result = identifier.identify((String) null);
        assertEquals("Unknown Food", result.getFoodName());
        assertEquals(0.4, result.getConfidenceScore());
    }

    @Test
    void identifyBlankUrlReturnsFallback() {
        FoodIdentification result = identifier.identify("   ");
        assertEquals("Unknown Food", result.getFoodName());
    }

    @Test
    void identifyUnknownUrlReturnsFallback() {
        FoodIdentification result = identifier.identify("https://example.com/abcdef.jpg");
        assertEquals("Unknown Food", result.getFoodName());
    }

    @Test
    void identifyByFilename() {
        FoodIdentification result = identifier.identify(new byte[]{1, 2, 3}, "chicken_curry.jpg");
        assertNotNull(result.getFoodName());
        assertTrue(result.getConfidenceScore() > 0);
    }

    @Test
    void identifyNullBytesReturnsFallback() {
        FoodIdentification result = identifier.identify(null, "test.jpg");
        assertEquals("Unknown Food", result.getFoodName());
    }

    @Test
    void identifyEmptyBytesReturnsFallback() {
        FoodIdentification result = identifier.identify(new byte[0], "test.jpg");
        assertEquals("Unknown Food", result.getFoodName());
    }

    @Test
    void canHandleReturnsFalseForBlank() {
        assertTrue(identifier.canHandle("https://example.com/food.jpg"));
        assertFalse(identifier.canHandle(null));
        assertFalse(identifier.canHandle(""));
    }

    @Test
    void setSourceImageUrlOnIdentification() {
        String url = "https://example.com/pasta.jpg";
        FoodIdentification result = identifier.identify(url);
        assertEquals(url, result.getSourceImageUrl());
    }

    @Test
    void identifyMultipleKeywords() {
        FoodIdentification pizza = identifier.identify("https://example.com/pizza_pepperoni.jpg");
        assertEquals("Pizza", pizza.getFoodName());

        FoodIdentification burger = identifier.identify("https://example.com/burger_meal.jpg");
        assertEquals("Burger", burger.getFoodName());
    }
}
