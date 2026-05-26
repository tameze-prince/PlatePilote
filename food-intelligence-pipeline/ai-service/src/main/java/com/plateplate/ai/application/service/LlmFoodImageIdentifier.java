package com.plateplate.ai.application.service;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.plateplate.ai.domain.model.FoodIdentification;
import com.plateplate.ai.infrastructure.llm.LlmClient;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

public class LlmFoodImageIdentifier implements FoodImageIdentifier {
    private static final Logger log = LoggerFactory.getLogger(LlmFoodImageIdentifier.class);

    private static final String SYSTEM_PROMPT = """
        You are a food identification assistant. Identify food items from images.
        Return ONLY valid JSON with no markdown formatting or code blocks.
        """;

    private final LlmClient visionClient;
    private final FoodImageIdentifier fallback;
    private final ObjectMapper objectMapper;

    public LlmFoodImageIdentifier(LlmClient visionClient, FoodImageIdentifier fallback) {
        this.visionClient = visionClient;
        this.fallback = fallback;
        this.objectMapper = new ObjectMapper();
    }

    @Override
    public FoodIdentification identify(String imageUrl) {
        try {
            String userMessage = "Identify the food in this image. Return JSON with: foodName (string), confidenceScore (0-1 double), categories (array of strings), detectedIngredients (array of strings).";
            Optional<String> response = visionClient.chatWithVision(SYSTEM_PROMPT, userMessage, imageUrl);
            if (response.isEmpty()) {
                log.warn("Vision LLM returned empty, falling back");
                return fallback.identify(imageUrl);
            }
            return parseResponse(response.get(), imageUrl);
        } catch (Exception e) {
            log.warn("Vision identification failed: {}, falling back", e.getMessage());
            return fallback.identify(imageUrl);
        }
    }

    @Override
    public FoodIdentification identify(byte[] imageBytes, String filename) {
        return identify(filename);
    }

    @Override
    public boolean canHandle(String imageUrl) {
        return true;
    }

    @SuppressWarnings("unchecked")
    private FoodIdentification parseResponse(String json, String sourceUrl) {
        try {
            String cleaned = json.replaceAll("(?s)```(?:json)?\\s*", "").trim();
            Map<String, Object> map = objectMapper.readValue(cleaned, new TypeReference<LinkedHashMap<String, Object>>() {});

            FoodIdentification id = new FoodIdentification(
                map.getOrDefault("foodName", "Unknown Food").toString(),
                safeDouble(map.get("confidenceScore"), 0.5),
                (List<String>) map.getOrDefault("categories", List.of("Uncategorized"))
            );
            id.setSourceImageUrl(sourceUrl);
            if (map.containsKey("detectedIngredients")) {
                id.setDetectedIngredients((List<String>) map.get("detectedIngredients"));
            }
            return id;
        } catch (Exception e) {
            log.warn("Failed to parse vision response JSON: {}", e.getMessage());
            return fallback.identify(sourceUrl);
        }
    }

    private Double safeDouble(Object o, double fallback) {
        if (o instanceof Number n) return n.doubleValue();
        return fallback;
    }
}
