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

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@Service
public class AiServiceClient {
    private static final Logger log = LoggerFactory.getLogger(AiServiceClient.class);

    private final RestTemplate restTemplate;
    private final String aiServiceUrl;

    public AiServiceClient(
            RestTemplate restTemplate,
            @Value("${app.ai.service-url:http://localhost:8086/api/v1/ai}") String aiServiceUrl) {
        this.restTemplate = restTemplate;
        this.aiServiceUrl = aiServiceUrl;
    }

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

    public boolean isHealthy() {
        try {
            var response = restTemplate.getForEntity(aiServiceUrl + "/health", Map.class);
            return response.getStatusCode().is2xxSuccessful();
        } catch (RestClientException e) {
            return false;
        }
    }
}
