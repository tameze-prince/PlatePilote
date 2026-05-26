package com.platepilote.platepilote.ai.presentation;

import com.platepilote.platepilote.ai.application.service.AiServiceClient;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/v1/ai")
public class AiProxyController {

    private final AiServiceClient aiServiceClient;

    public AiProxyController(AiServiceClient aiServiceClient) {
        this.aiServiceClient = aiServiceClient;
    }

    @PostMapping("/parse-recipe")
    public ResponseEntity<?> parseRecipe(@RequestBody Map<String, String> body) {
        return aiServiceClient.parseRecipe(body.getOrDefault("text", ""))
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.status(503).body(Map.of("error", "AI service unavailable")));
    }

    @PostMapping("/identify-food")
    public ResponseEntity<?> identifyFood(@RequestBody Map<String, String> body) {
        return aiServiceClient.identifyFood(body.getOrDefault("imageUrl", ""))
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.status(503).body(Map.of("error", "AI service unavailable")));
    }

    @PostMapping("/estimate-nutrition")
    public ResponseEntity<?> estimateNutrition(@RequestBody Map<String, List<Map<String, Object>>> body) {
        return aiServiceClient.estimateNutrition(body.getOrDefault("ingredients", List.of()))
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.status(503).body(Map.of("error", "AI service unavailable")));
    }
}
