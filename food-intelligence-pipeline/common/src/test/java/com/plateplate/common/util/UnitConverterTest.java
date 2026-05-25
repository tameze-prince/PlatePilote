package com.plateplate.common.util;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

@DisplayName("Unit Converter Tests")
public class UnitConverterTest {

    @Test
    @DisplayName("Should convert ounces to grams")
    void testOunceToGram() {
        Double result = UnitConverter.convertToGrams(1.0, "oz");
        assertNotNull(result);
        assertEquals(28.35, result, 0.1);
    }

    @Test
    @DisplayName("Should convert pounds to grams")
    void testPoundToGram() {
        Double result = UnitConverter.convertToGrams(1.0, "lb");
        assertNotNull(result);
        assertEquals(453.592, result, 1.0);
    }

    @Test
    @DisplayName("Should return same value for grams")
    void testGramToGram() {
        Double result = UnitConverter.convertToGrams(100.0, "g");
        assertNotNull(result);
        assertEquals(100.0, result);
    }

    @Test
    @DisplayName("Should convert cups to milliliters")
    void testCupToMilliliter() {
        Double result = UnitConverter.convertToMilliliters(1.0, "cup");
        assertNotNull(result);
        assertEquals(236.588, result, 1.0);
    }

    @Test
    @DisplayName("Should convert tbsp to milliliters")
    void testTablespoonToMilliliter() {
        Double result = UnitConverter.convertToMilliliters(1.0, "tbsp");
        assertNotNull(result);
        assertEquals(14.787, result, 0.1);
    }

    @Test
    @DisplayName("Should return same value for milliliters")
    void testMilliliterToMilliliter() {
        Double result = UnitConverter.convertToMilliliters(500.0, "ml");
        assertNotNull(result);
        assertEquals(500.0, result);
    }

    @Test
    @DisplayName("Should handle unknown units")
    void testUnknownUnit() {
        Double result = UnitConverter.convertToGrams(1.0, "unknown");
        assertNull(result);
    }
}
