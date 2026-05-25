package com.plateplate.common.util;

import java.util.HashMap;
import java.util.Map;

public final class UnitConverter {

    private static final Map<String, Double> TO_GRAMS = new HashMap<>();
    static {
        TO_GRAMS.put("oz", 28.3495);
        TO_GRAMS.put("lb", 453.592);
        TO_GRAMS.put("g", 1.0);
        TO_GRAMS.put("kg", 1000.0);
    }

    private static final Map<String, Double> TO_MILLILITERS = new HashMap<>();
    static {
        TO_MILLILITERS.put("cup", 236.588);
        TO_MILLILITERS.put("cups", 236.588);
        TO_MILLILITERS.put("tbsp", 14.7868);
        TO_MILLILITERS.put("tablespoon", 14.7868);
        TO_MILLILITERS.put("tablespoons", 14.7868);
        TO_MILLILITERS.put("tsp", 4.92892);
        TO_MILLILITERS.put("teaspoon", 4.92892);
        TO_MILLILITERS.put("teaspoons", 4.92892);
        TO_MILLILITERS.put("ml", 1.0);
        TO_MILLILITERS.put("milliliter", 1.0);
        TO_MILLILITERS.put("milliliters", 1.0);
        TO_MILLILITERS.put("l", 1000.0);
        TO_MILLILITERS.put("liter", 1000.0);
        TO_MILLILITERS.put("liters", 1000.0);
    }

    private UnitConverter() {}

    public static Double convertToGrams(double quantity, String unit) {
        if (unit == null) return null;
        Double factor = TO_GRAMS.get(unit.toLowerCase());
        if (factor == null) return null;
        return quantity * factor;
    }

    public static Double convertToMilliliters(double quantity, String unit) {
        if (unit == null) return null;
        Double factor = TO_MILLILITERS.get(unit.toLowerCase());
        if (factor == null) return null;
        return quantity * factor;
    }
}
