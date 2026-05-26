package com.plateplate.ai.application.service;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.plateplate.ai.domain.model.ParsedIngredientLine;
import com.plateplate.ai.domain.model.ParsedRecipe;
import com.plateplate.ai.infrastructure.llm.LlmClient;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

public class LlmRecipeTextParser implements RecipeTextParser {
    private static final Logger log = LoggerFactory.getLogger(LlmRecipeTextParser.class);

    private static final String SYSTEM_PROMPT = """
        You are a recipe parsing assistant. Extract structured recipe data from raw text.
        Return ONLY valid JSON with no markdown formatting or code blocks.
        """;

    private final LlmClient llmClient;
    private final RecipeTextParser fallback;
    private final ObjectMapper objectMapper;

    public LlmRecipeTextParser(LlmClient llmClient, RecipeTextParser fallback) {
        this.llmClient = llmClient;
        this.fallback = fallback;
        this.objectMapper = new ObjectMapper();
    }

    @Override
    public ParsedRecipe parse(String rawText) {
        try {
            String userMessage = buildPrompt(rawText);
            Optional<String> response = llmClient.chat(SYSTEM_PROMPT, userMessage);
            if (response.isEmpty()) {
                log.warn("LLM returned empty, falling back to default parser");
                return fallback.parse(rawText);
            }
            return parseResponse(response.get(), rawText);
        } catch (Exception e) {
            log.warn("LLM recipe parsing failed: {}, falling back to default parser", e.getMessage());
            return fallback.parse(rawText);
        }
    }

    @Override
    public boolean canHandle(String rawText) {
        return true;
    }

    private String buildPrompt(String rawText) {
        return """
            Parse this recipe text and return JSON with these fields:
            - title (string): recipe name
            - ingredients (array of {name: string, quantity: number|null, unit: string|null})
            - steps (array of strings)
            - cuisine (string or null)
            - prepTimeMinutes (number or null)
            - cookTimeMinutes (number or null)
            - servings (number or null)

            Recipe text:
            ---
            """ + rawText + "\n---";
    }

    @SuppressWarnings("unchecked")
    private ParsedRecipe parseResponse(String json, String originalText) {
        try {
            String cleaned = json.replaceAll("(?s)```(?:json)?\\s*", "").trim();
            Map<String, Object> map = objectMapper.readValue(cleaned, new TypeReference<LinkedHashMap<String, Object>>() {});

            String title = map.getOrDefault("title", "Unknown").toString();
            List<Map<String, Object>> ingreds = (List<Map<String, Object>>) map.getOrDefault("ingredients", List.of());
            List<String> steps = (List<String>) map.getOrDefault("steps", List.of());

            List<ParsedIngredientLine> ingredients = ingreds.stream().map(m -> {
                ParsedIngredientLine pil = new ParsedIngredientLine();
                pil.setName(safeStr(m.get("name")));
                pil.setQuantity(safeDouble(m.get("quantity")));
                pil.setUnit(safeStr(m.get("unit")));
                pil.setVerified(true);
                return pil;
            }).toList();

            if (ingredients.isEmpty()) {
                log.warn("LLM returned empty ingredients, falling back");
                return fallback.parse(originalText);
            }

            ParsedRecipe recipe = new ParsedRecipe(title, ingredients, steps);
            if (map.containsKey("cuisine") && map.get("cuisine") != null)
                recipe.setCuisine(map.get("cuisine").toString());
            if (map.containsKey("prepTimeMinutes") && map.get("prepTimeMinutes") != null)
                recipe.setPrepTimeMinutes(safeInt(map.get("prepTimeMinutes")));
            if (map.containsKey("cookTimeMinutes") && map.get("cookTimeMinutes") != null)
                recipe.setCookTimeMinutes(safeInt(map.get("cookTimeMinutes")));
            if (map.containsKey("servings") && map.get("servings") != null)
                recipe.setServings(safeInt(map.get("servings")));
            recipe.setConfidenceScore(0.95);
            return recipe;

        } catch (Exception e) {
            log.warn("Failed to parse LLM response JSON: {}", e.getMessage());
            return fallback.parse(originalText);
        }
    }

    private String safeStr(Object o) { return o == null ? null : o.toString(); }
    private Double safeDouble(Object o) {
        if (o == null) return null;
        if (o instanceof Number n) return n.doubleValue();
        try { return Double.parseDouble(o.toString()); } catch (NumberFormatException e) { return null; }
    }
    private Integer safeInt(Object o) {
        if (o == null) return null;
        if (o instanceof Number n) return n.intValue();
        try { return Integer.parseInt(o.toString()); } catch (NumberFormatException e) { return null; }
    }
}
