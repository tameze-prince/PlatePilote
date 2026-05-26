package com.plateplate.ai;

import com.plateplate.ai.infrastructure.llm.LlmClient;
import org.junit.jupiter.api.Test;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;

class LlmIntegrationTest {
    private static final Logger log = LoggerFactory.getLogger(LlmIntegrationTest.class);

    @Test
    void testOpenRouter() {
        String apiKey = System.getenv("OPENROUTER_API_KEY");
        if (apiKey == null || apiKey.isBlank()) {
            log.warn("SKIP: OPENROUTER_API_KEY not set");
            return;
        }
        LlmClient client = new LlmClient(
            "https://openrouter.ai/api/v1",
            apiKey,
            "gpt-oss-120b"
        );
        Optional<String> response = client.chat(
            "You are a helpful assistant. Answer concisely.",
            "Say 'hello' in French."
        );
        if (response.isPresent()) {
            log.info("OpenRouter OK: {}", response.get());
            assertTrue(response.get().toLowerCase().contains("bonjour"));
        } else {
            log.warn("OpenRouter returned empty (possible rate limit or timeout)");
        }
    }

    @Test
    void testRecipeParsingWithOpenRouter() {
        String apiKey = System.getenv("OPENROUTER_API_KEY");
        if (apiKey == null || apiKey.isBlank()) {
            log.warn("SKIP: OPENROUTER_API_KEY not set");
            return;
        }
        LlmClient client = new LlmClient(
            "https://openrouter.ai/api/v1",
            apiKey,
            "gpt-oss-120b"
        );
        String recipeText = """
            # Classic Pancakes
            Ingredients:
            1 cup flour
            2 tbsp sugar
            1 cup milk
            1 egg
            Instructions:
            Mix dry ingredients.
            Add wet ingredients.
            Cook on griddle.
            """;

        String prompt = """
            Parse this recipe text and return JSON with these fields:
            - title (string)
            - ingredients (array of {name: string, quantity: number|null, unit: string|null})
            - steps (array of strings)
            - servings (number or null)
            
            Recipe:
            """ + recipeText;

        Optional<String> response = client.chat(
            "You are a recipe parsing assistant. Return ONLY valid JSON.",
            prompt
        );
        if (response.isPresent()) {
            log.info("Parsed recipe JSON: {}", response.get());
        } else {
            log.warn("Recipe parsing returned empty");
        }
    }

    @Test
    void testNutritionEstimationWithOpenRouter() {
        String apiKey = System.getenv("OPENROUTER_API_KEY");
        if (apiKey == null || apiKey.isBlank()) {
            log.warn("SKIP: OPENROUTER_API_KEY not set");
            return;
        }
        LlmClient client = new LlmClient(
            "https://openrouter.ai/api/v1",
            apiKey,
            "gpt-oss-120b"
        );

        String prompt = """
            Estimate nutrition for these ingredients. Return JSON:
            {"calories": number, "proteinGrams": number, "carbsGrams": number, "fatGrams": number, "fiberGrams": number, "sugarGrams": number, "sodiumGrams": number, "confidenceScore": 0.0-1.0}
            Ingredients:
            - 200g chicken breast
            - 100g rice
            """;

        Optional<String> response = client.chat(
            "You are a nutrition estimation assistant. Return ONLY valid JSON.",
            prompt
        );
        if (response.isPresent()) {
            log.info("Nutrition JSON: {}", response.get());
        } else {
            log.warn("Nutrition estimation returned empty");
        }
    }
}
