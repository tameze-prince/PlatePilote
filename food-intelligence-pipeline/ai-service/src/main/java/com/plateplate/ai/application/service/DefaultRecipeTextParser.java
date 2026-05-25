package com.plateplate.ai.application.service;

import com.plateplate.ai.domain.model.ParsedIngredientLine;
import com.plateplate.ai.domain.model.ParsedRecipe;
import com.plateplate.common.util.IngredientLineParser;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.ArrayList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class DefaultRecipeTextParser implements RecipeTextParser {
    private static final Logger log = LoggerFactory.getLogger(DefaultRecipeTextParser.class);
    private static final Pattern TITLE_PATTERN = Pattern.compile("^#\\s+(.+)|^(?:Recipe[:\n]|Title[:\n])\\s*(.+)", Pattern.MULTILINE | Pattern.CASE_INSENSITIVE);
    private static final Pattern INGREDIENTS_HEADER = Pattern.compile("(?m)^(?:Ingredients|Ingrédients|What you need)[:\n]\\s*$", Pattern.CASE_INSENSITIVE);
    private static final Pattern INSTRUCTIONS_HEADER = Pattern.compile("(?m)^(?:Instructions|Directions|Steps|Method|Préparation|Instructions)[:\n]\\s*$", Pattern.CASE_INSENSITIVE);
    private static final Pattern TIME_PATTERN = Pattern.compile("(?i)(?:prep|preparation|cuisson|cook|total)\\s*(?:time|temps)?[:\s]*(\\d+)\\s*(?:min|minutes|mn)");
    private static final Pattern SERVINGS_PATTERN = Pattern.compile("(?i)(?:servings|serves|portions|yield|pour)\\s*:?\\s*(\\d+)");

    private final IngredientLineParser ingredientLineParser;

    public DefaultRecipeTextParser() {
        this.ingredientLineParser = new IngredientLineParser();
    }

    @Override
    public ParsedRecipe parse(String rawText) {
        if (rawText == null || rawText.isBlank()) {
            log.warn("Empty recipe text provided");
            return new ParsedRecipe("Unknown", List.of(), List.of());
        }

        String title = extractTitle(rawText);
        List<ParsedIngredientLine> ingredients = extractIngredients(rawText);
        List<String> steps = extractSteps(rawText);
        ParsedRecipe recipe = new ParsedRecipe(title, ingredients, steps);

        Integer prepTime = extractTime(rawText, "prep");
        Integer cookTime = extractTime(rawText, "cook");
        if (prepTime != null) recipe.setPrepTimeMinutes(prepTime);
        if (cookTime != null) recipe.setCookTimeMinutes(cookTime);

        Matcher servingsMatcher = SERVINGS_PATTERN.matcher(rawText);
        if (servingsMatcher.find()) {
            recipe.setServings(Integer.parseInt(servingsMatcher.group(1)));
        }

        recipe.setConfidenceScore(computeConfidence(title, ingredients, steps));
        return recipe;
    }

    @Override
    public boolean canHandle(String rawText) {
        return rawText != null && !rawText.isBlank();
    }

    private String extractTitle(String text) {
        Matcher m = TITLE_PATTERN.matcher(text);
        if (m.find()) {
            return m.group(1) != null ? m.group(1).trim() : m.group(2).trim();
        }
        String firstLine = text.lines().findFirst().orElse("").trim();
        return firstLine.length() <= 100 ? firstLine : firstLine.substring(0, 100).trim();
    }

    private List<ParsedIngredientLine> extractIngredients(String text) {
        List<ParsedIngredientLine> result = new ArrayList<>();
        Matcher headerMatcher = INGREDIENTS_HEADER.matcher(text);
        if (!headerMatcher.find()) return result;

        int start = headerMatcher.end();
        Matcher nextSection = INSTRUCTIONS_HEADER.matcher(text);
        int end = nextSection.find() ? nextSection.start() : text.length();

        String section = text.substring(start, end);
        for (String line : section.split("\n")) {
            line = line.trim();
            if (line.isBlank() || line.startsWith("- ") || line.startsWith("* ")) continue;
            if (line.matches("^[\\d]+\\.\\s.*")) {
                line = line.replaceFirst("^[\\d]+\\.\\s+", "");
            }

            com.plateplate.common.util.IngredientLineParser.ParsedIngredient parsed =
                ingredientLineParser.parse(line);
            if (parsed != null && parsed.ingredient != null && !parsed.ingredient.isBlank()) {
                ParsedIngredientLine pil = new ParsedIngredientLine(line, parsed.quantity, parsed.unit, parsed.ingredient);
                result.add(pil);
            }
        }

        return result;
    }

    private List<String> extractSteps(String text) {
        List<String> result = new ArrayList<>();
        Matcher headerMatcher = INSTRUCTIONS_HEADER.matcher(text);
        if (!headerMatcher.find()) return result;

        int start = headerMatcher.end();
        String section = text.substring(start).trim();

        for (String line : section.split("\n")) {
            line = line.trim();
            if (line.isBlank()) continue;
            line = line.replaceAll("^\\d+\\.\\s*", "");
            result.add(line);
        }

        return result;
    }

    private Integer extractTime(String text, String type) {
        Pattern p = Pattern.compile(
            "(?i)(" + type + ")\\s*(?:time|temps)?[:\s]*(\\d+)\\s*(?:min|minutes|mn)",
            Pattern.CASE_INSENSITIVE
        );
        Matcher m = p.matcher(text);
        if (m.find()) return Integer.parseInt(m.group(2));
        return null;
    }

    private double computeConfidence(String title, List<ParsedIngredientLine> ingredients, List<String> steps) {
        double score = 0.5;
        if (title != null && !title.isBlank() && !title.equals("Unknown")) score += 0.15;
        if (ingredients.size() >= 2) score += 0.2;
        if (steps.size() >= 2) score += 0.15;
        return Math.min(score, 1.0);
    }
}
