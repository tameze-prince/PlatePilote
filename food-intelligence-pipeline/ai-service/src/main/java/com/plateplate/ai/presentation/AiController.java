package com.plateplate.ai.presentation;

import com.plateplate.ai.application.service.FoodImageIdentifier;
import com.plateplate.ai.application.service.NutritionEstimator;
import com.plateplate.ai.application.service.RecipeTextParser;
import com.plateplate.ai.domain.model.EstimatedNutrition;
import com.plateplate.ai.domain.model.FoodIdentification;
import com.plateplate.ai.domain.model.ParsedIngredientLine;
import com.plateplate.ai.domain.model.ParsedRecipe;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/v1/ai")
public class AiController {
    private static final Logger log = LoggerFactory.getLogger(AiController.class);

    private final RecipeTextParser recipeTextParser;
    private final FoodImageIdentifier foodImageIdentifier;
    private final NutritionEstimator nutritionEstimator;

    public AiController(
            RecipeTextParser recipeTextParser,
            FoodImageIdentifier foodImageIdentifier,
            NutritionEstimator nutritionEstimator) {
        this.recipeTextParser = recipeTextParser;
        this.foodImageIdentifier = foodImageIdentifier;
        this.nutritionEstimator = nutritionEstimator;
    }

    @PostMapping("/parse-recipe")
    public ResponseEntity<ParsedRecipe> parseRecipe(@RequestBody Map<String, String> body) {
        String text = body.get("text");
        if (text == null || text.isBlank()) {
            return ResponseEntity.badRequest().build();
        }
        log.info("Parsing recipe text ({} chars)", text.length());
        ParsedRecipe recipe = recipeTextParser.parse(text);
        return ResponseEntity.ok(recipe);
    }

    @PostMapping("/identify-food")
    public ResponseEntity<FoodIdentification> identifyFood(@RequestBody Map<String, String> body) {
        String imageUrl = body.get("imageUrl");
        if (imageUrl == null || imageUrl.isBlank()) {
            return ResponseEntity.badRequest().build();
        }
        log.info("Identifying food from image: {}", imageUrl);
        FoodIdentification identification = foodImageIdentifier.identify(imageUrl);
        return ResponseEntity.ok(identification);
    }

    @PostMapping("/estimate-nutrition")
    public ResponseEntity<EstimatedNutrition> estimateNutrition(@RequestBody Map<String, Object> body) {
        @SuppressWarnings("unchecked")
        List<Map<String, Object>> ingredientMaps = (List<Map<String, Object>>) body.get("ingredients");
        if (ingredientMaps == null || ingredientMaps.isEmpty()) {
            return ResponseEntity.badRequest().build();
        }
        List<ParsedIngredientLine> ingredients = ingredientMaps.stream().map(m -> {
            ParsedIngredientLine pil = new ParsedIngredientLine();
            pil.setName((String) m.get("name"));
            if (m.get("quantity") instanceof Number n) pil.setQuantity(n.doubleValue());
            pil.setUnit((String) m.get("unit"));
            return pil;
        }).toList();

        log.info("Estimating nutrition for {} ingredients", ingredients.size());
        EstimatedNutrition nutrition = nutritionEstimator.estimate(ingredients);
        return ResponseEntity.ok(nutrition);
    }

    @GetMapping("/health")
    public ResponseEntity<Map<String, String>> health() {
        return ResponseEntity.ok(Map.of(
            "status", "UP",
            "service", "ai-service"
        ));
    }
}
