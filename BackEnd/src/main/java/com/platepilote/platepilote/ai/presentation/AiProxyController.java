package com.platepilote.platepilote.ai.presentation;

import com.platepilote.platepilote.ai.application.service.AiServiceClient;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * Contrôleur proxy REST vers le service d'IA externalisé.
 * <p>
 * Expose les endpoints de parsing de recettes, identification d'aliments
 * et estimation nutritionnelle en tant que proxy vers le service d'IA
 * configuré. Retourne une erreur 503 si le service d'IA est indisponible.
 */
@RestController
@RequestMapping("/api/v1/ai")
public class AiProxyController {

    /** Client du service d'IA. */
    private final AiServiceClient aiServiceClient;

    /**
     * Constructeur avec injection du client IA.
     *
     * @param aiServiceClient client du service d'IA
     */
    public AiProxyController(AiServiceClient aiServiceClient) {
        this.aiServiceClient = aiServiceClient;
    }

    /**
     * Parse un texte de recette pour en extraire les ingrédients et instructions.
     *
     * @param body requête contenant le champ "text"
     * @return résultat du parsing ou 503 si le service IA est indisponible
     */
    @PostMapping("/parse-recipe")
    public ResponseEntity<?> parseRecipe(@RequestBody Map<String, String> body) {
        return aiServiceClient.parseRecipe(body.getOrDefault("text", ""))
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.status(503).body(Map.of("error", "AI service unavailable")));
    }

    /**
     * Identifie un aliment à partir d'une URL d'image.
     *
     * @param body requête contenant le champ "imageUrl"
     * @return résultat de l'identification ou 503 si le service IA est indisponible
     */
    @PostMapping("/identify-food")
    public ResponseEntity<?> identifyFood(@RequestBody Map<String, String> body) {
        return aiServiceClient.identifyFood(body.getOrDefault("imageUrl", ""))
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.status(503).body(Map.of("error", "AI service unavailable")));
    }

    /**
     * Estime les valeurs nutritionnelles d'une liste d'ingrédients.
     *
     * @param body requête contenant le champ "ingredients"
     * @return estimation nutritionnelle ou 503 si le service IA est indisponible
     */
    @PostMapping("/estimate-nutrition")
    public ResponseEntity<?> estimateNutrition(@RequestBody Map<String, List<Map<String, Object>>> body) {
        return aiServiceClient.estimateNutrition(body.getOrDefault("ingredients", List.of()))
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.status(503).body(Map.of("error", "AI service unavailable")));
    }
}
