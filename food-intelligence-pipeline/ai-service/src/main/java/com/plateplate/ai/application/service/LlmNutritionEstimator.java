package com.plateplate.ai.application.service;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.plateplate.ai.domain.model.EstimatedNutrition;
import com.plateplate.ai.domain.model.ParsedIngredientLine;
import com.plateplate.ai.domain.model.ParsedRecipe;
import com.plateplate.ai.infrastructure.llm.LlmClient;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

public class LlmNutritionEstimator implements NutritionEstimator {
    private static final Logger log = LoggerFactory.getLogger(LlmNutritionEstimator.class);

    private static final String SYSTEM_PROMPT = """
        You are a nutrition estimation assistant. Estimate nutritional values for ingredients.
        Return ONLY valid JSON with no markdown formatting or code blocks.
        """;

    private final LlmClient llmClient;
    private final NutritionEstimator fallback;
    private final ObjectMapper objectMapper;

    public LlmNutritionEstimator(LlmClient llmClient, NutritionEstimator fallback) {
        this.llmClient = llmClient;
        this.fallback = fallback;
        this.objectMapper = new ObjectMapper();
    }

    @Override
    public EstimatedNutrition estimate(List<ParsedIngredientLine> ingredients) {
        try {
            StringBuilder sb = new StringBuilder();
            for (ParsedIngredientLine ing : ingredients) {
                sb.append("- ");
                if (ing.getQuantity() != null) sb.append(ing.getQuantity()).append(" ");
                if (ing.getUnit() != null) sb.append(ing.getUnit()).append(" ");
                sb.append(ing.getName()).append("\n");
            }

            String userMessage = """
                Estimate nutrition for these ingredients. Return JSON:
                {
                  "calories": number,
                  "proteinGrams": number,
                  "carbsGrams": number,
                  "fatGrams": number,
                  "fiberGrams": number,
                  "sugarGrams": number,
                  "sodiumGrams": number,
                  "confidenceScore": 0.0-1.0
                }
                Ingredients:
                """ + sb.toString();

            Optional<String> response = llmClient.chat(SYSTEM_PROMPT, userMessage);
            if (response.isEmpty()) {
                log.warn("LLM nutrition estimation returned empty, falling back");
                return fallback.estimate(ingredients);
            }
            return parseResponse(response.get(), ingredients);
        } catch (Exception e) {
            log.warn("LLM nutrition estimation failed: {}, falling back", e.getMessage());
            return fallback.estimate(ingredients);
        }
    }

    @Override
    public EstimatedNutrition estimate(ParsedRecipe recipe) {
        if (recipe == null || recipe.getIngredients() == null || recipe.getIngredients().isEmpty()) {
            return fallback.estimate(recipe);
        }
        EstimatedNutrition nutrition = estimate(recipe.getIngredients());
        if (recipe.getServings() != null && recipe.getServings() > 0) {
            nutrition.setServings(recipe.getServings());
        }
        return nutrition;
    }

    @Override
    public boolean canEstimate(List<ParsedIngredientLine> ingredients) {
        return true;
    }

    private EstimatedNutrition parseResponse(String json, List<ParsedIngredientLine> fallbackIngredients) {
        try {
            String cleaned = json.replaceAll("(?s)```(?:json)?\\s*", "").trim();
            Map<String, Object> map = objectMapper.readValue(cleaned, new TypeReference<LinkedHashMap<String, Object>>() {});

            EstimatedNutrition nutrition = new EstimatedNutrition();
            nutrition.setCalories(safeDouble(map.get("calories"), 0.0));
            nutrition.setProteinGrams(safeDouble(map.get("proteinGrams"), 0.0));
            nutrition.setCarbsGrams(safeDouble(map.get("carbsGrams"), 0.0));
            nutrition.setFatGrams(safeDouble(map.get("fatGrams"), 0.0));
            nutrition.setFiberGrams(safeDouble(map.get("fiberGrams"), 0.0));
            nutrition.setSugarGrams(safeDouble(map.get("sugarGrams"), 0.0));
            nutrition.setSodiumGrams(safeDouble(map.get("sodiumGrams"), 0.0));
            nutrition.setConfidenceScore(safeDouble(map.get("confidenceScore"), 0.5));

            if (nutrition.getConfidenceScore() < 0.3) {
                log.warn("LLM nutrition confidence too low ({}), falling back", nutrition.getConfidenceScore());
                return fallback.estimate(fallbackIngredients);
            }
            return nutrition;
        } catch (Exception e) {
            log.warn("Failed to parse LLM nutrition JSON: {}", e.getMessage());
            return fallback.estimate(fallbackIngredients);
        }
    }

    private Double safeDouble(Object o, double fallback) {
        if (o instanceof Number n) return n.doubleValue();
        if (o != null) {
            try { return Double.parseDouble(o.toString()); } catch (NumberFormatException e) { /* fall through */ }
        }
        return fallback;
    }
}
