package com.plateplate.common.util;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

public final class IngredientLineParser {

    private static final Pattern FRACTION = Pattern.compile("(\\d+)/(\\d+)");
    private static final Pattern NUMBER = Pattern.compile("\\d+(\\.\\d+)?");

    public static final class ParsedIngredient {
        public final Double quantity;
        public final String unit;
        public final String ingredient;

        public ParsedIngredient(Double quantity, String unit, String ingredient) {
            this.quantity = quantity;
            this.unit = unit;
            this.ingredient = ingredient;
        }
    }

    public static ParsedIngredient parse(String line) {
        if (line == null || line.isBlank()) return null;
        String trimmed = line.trim();

        String[] parts = trimmed.split("\\s+");
        if (parts.length == 0) return new ParsedIngredient(null, null, trimmed);

        int idx = 0;
        Double quantity = null;

        if (isFraction(parts[idx])) {
            quantity = parseFraction(parts[idx]);
            idx++;
        } else if (isNumber(parts[idx])) {
            quantity = Double.parseDouble(parts[idx]);
            idx++;
            if (idx < parts.length && isFraction(parts[idx])) {
                quantity += parseFraction(parts[idx]);
                idx++;
            }
        }

        if (idx >= parts.length) {
            return new ParsedIngredient(quantity, null, trimmed);
        }

        String unit = null;
        int ingredientStart;

        if (quantity != null && idx + 1 < parts.length && !isNumber(parts[idx + 1])) {
            unit = parts[idx];
            ingredientStart = idx + 1;
        } else {
            ingredientStart = idx;
        }

        StringBuilder ingredientBuilder = new StringBuilder();
        for (int i = ingredientStart; i < parts.length; i++) {
            if (ingredientBuilder.length() > 0) ingredientBuilder.append(" ");
            ingredientBuilder.append(parts[i]);
        }
        String ingredient = ingredientBuilder.toString();

        return new ParsedIngredient(quantity, unit, ingredient);
    }

    private static boolean isNumber(String s) {
        return NUMBER.matcher(s).matches();
    }

    private static boolean isFraction(String s) {
        return FRACTION.matcher(s).matches();
    }

    private static double parseFraction(String s) {
        Matcher m = FRACTION.matcher(s);
        if (m.matches()) {
            return (double) Integer.parseInt(m.group(1)) / Integer.parseInt(m.group(2));
        }
        return 0;
    }
}
