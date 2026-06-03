package com.platepilote.platepilote.ai.application.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpMethod;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestClientException;
import org.springframework.web.client.RestTemplate;

import java.util.List;
import java.util.Map;
import java.util.Optional;

/**
 * Client HTTP pour le service d'IA externalisé.
 * <p>
 * Permet d'appeler les endpoints du service d'IA pour le parsing de recettes,
 * l'identification d'aliments par image et l'estimation nutritionnelle.
 * Configure l'URL du service via la propriété {@code app.ai.service-url}
 * (défaut: http://localhost:8086/api/v1/ai).
 */
@Service
@SuppressWarnings("null")
public class AiServiceClient {
    private static final Logger log = LoggerFactory.getLogger(AiServiceClient.class);

    /** Client HTTP RestTemplate. */
    private final RestTemplate restTemplate;

    /** URL de base du service d'IA. */
    private final String aiServiceUrl;

    /**
     * Constructeur avec injection de dépendances.
     *
     * @param restTemplate  client HTTP
     * @param aiServiceUrl  URL du service d'IA (injectée via configuration)
     */
    public AiServiceClient(
            RestTemplate restTemplate,
            @Value("${app.ai.service-url:http://localhost:8086/api/v1/ai}") String aiServiceUrl) {
        this.restTemplate = restTemplate;
        this.aiServiceUrl = aiServiceUrl;
    }

    /**
     * Parse un texte de recette via le service d'IA pour en extraire
     * les ingrédients, les quantités et les instructions.
     *
     * @param texte brut de la recette
     * @return résultat du parsing ou empty si le service est indisponible
     */
    public Optional<Map<String, Object>> parseRecipe(String text) {
        try {
            var response = restTemplate.exchange(
                aiServiceUrl + "/parse-recipe",
                HttpMethod.POST,
                new HttpEntity<>(Map.of("text", text)),
                new ParameterizedTypeReference<Map<String, Object>>() {}
            );
            return Optional.ofNullable(response.getBody());
        } catch (RestClientException e) {
            log.warn("AI service parse-recipe failed: {}", e.getMessage());
            return Optional.empty();
        }
    }

    /**
     * Identifie un aliment à partir d'une URL d'image via le service d'IA.
     *
     * @param imageUrl URL de l'image de l'aliment
     * @return résultat de l'identification ou empty si le service est indisponible
     */
    public Optional<Map<String, Object>> identifyFood(String imageUrl) {
        try {
            var response = restTemplate.exchange(
                aiServiceUrl + "/identify-food",
                HttpMethod.POST,
                new HttpEntity<>(Map.of("imageUrl", imageUrl)),
                new ParameterizedTypeReference<Map<String, Object>>() {}
            );
            return Optional.ofNullable(response.getBody());
        } catch (RestClientException e) {
            log.warn("AI service identify-food failed: {}", e.getMessage());
            return Optional.empty();
        }
    }

    /**
     * Estime les valeurs nutritionnelles d'un ensemble d'ingrédients via le service d'IA.
     *
     * @param ingredients liste d'ingrédients avec leurs quantités
     * @return estimation nutritionnelle ou empty si le service est indisponible
     */
    public Optional<Map<String, Object>> estimateNutrition(List<Map<String, Object>> ingredients) {
        try {
            var response = restTemplate.exchange(
                aiServiceUrl + "/estimate-nutrition",
                HttpMethod.POST,
                new HttpEntity<>(Map.of("ingredients", ingredients)),
                new ParameterizedTypeReference<Map<String, Object>>() {}
            );
            return Optional.ofNullable(response.getBody());
        } catch (RestClientException e) {
            log.warn("AI service estimate-nutrition failed: {}", e.getMessage());
            return Optional.empty();
        }
    }

    /**
     * Vérifie si le service d'IA est joignable et en bonne santé.
     *
     * @return true si le service répond avec un code 2xx
     */
    public boolean isHealthy() {
        try {
            var response = restTemplate.getForEntity(aiServiceUrl + "/health", Map.class);
            return response.getStatusCode().is2xxSuccessful();
        } catch (RestClientException e) {
            return false;
        }
    }
}
