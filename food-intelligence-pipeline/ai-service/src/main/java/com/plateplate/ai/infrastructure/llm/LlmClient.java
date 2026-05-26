package com.plateplate.ai.infrastructure.llm;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ArrayNode;
import com.fasterxml.jackson.databind.node.ObjectNode;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.util.retry.Retry;

import java.time.Duration;
import java.util.Map;
import java.util.Optional;

public class LlmClient {
    private static final Logger log = LoggerFactory.getLogger(LlmClient.class);
    private static final int MAX_RETRIES = 2;
    private static final Duration TIMEOUT = Duration.ofSeconds(60);

    private final WebClient webClient;
    private final String model;
    private final String baseUrl;
    private final String apiKey;
    private final ObjectMapper objectMapper;

    public LlmClient(String baseUrl, String apiKey, String model) {
        this.baseUrl = baseUrl;
        this.apiKey = apiKey;
        this.model = model;
        this.objectMapper = new ObjectMapper();
        this.webClient = WebClient.builder()
            .baseUrl(baseUrl)
            .defaultHeader("Authorization", "Bearer " + apiKey)
            .defaultHeader("Content-Type", "application/json")
            .build();
    }

    public Optional<String> chat(String systemPrompt, String userMessage) {
        return chat(systemPrompt, userMessage, null);
    }

    public Optional<String> chat(String systemPrompt, String userMessage, Map<String, Object> extraParams) {
        try {
            ObjectNode body = objectMapper.createObjectNode();
            body.put("model", model);
            body.put("max_tokens", 2000);
            body.put("temperature", 0.1);

            if (extraParams != null) {
                extraParams.forEach((k, v) -> {
                    if (v instanceof String) body.put(k, (String) v);
                    else if (v instanceof Integer) body.put(k, (Integer) v);
                    else if (v instanceof Double) body.put(k, (Double) v);
                    else if (v instanceof Boolean) body.put(k, (Boolean) v);
                });
            }

            ArrayNode messages = body.putArray("messages");
            messages.addObject().put("role", "system").put("content", systemPrompt);
            messages.addObject().put("role", "user").put("content", userMessage);

            String response = webClient.post()
                .uri("/chat/completions")
                .bodyValue(body)
                .retrieve()
                .bodyToMono(String.class)
                .retryWhen(Retry.fixedDelay(MAX_RETRIES, Duration.ofSeconds(2)))
                .block(TIMEOUT);

            if (response == null) return Optional.empty();

            JsonNode root = objectMapper.readTree(response);
            String content = root.path("choices").get(0).path("message").path("content").asText(null);
            return Optional.ofNullable(content);

        } catch (Exception e) {
            log.warn("LLM call failed for model {}: {}", model, e.getMessage());
            return Optional.empty();
        }
    }

    public Optional<String> chatWithVision(String systemPrompt, String userMessage, String imageUrl) {
        try {
            ObjectNode body = objectMapper.createObjectNode();
            body.put("model", model);
            body.put("max_tokens", 2000);
            body.put("temperature", 0.1);

            ArrayNode messages = body.putArray("messages");
            messages.addObject().put("role", "system").put("content", systemPrompt);

            ObjectNode userNode = messages.addObject();
            userNode.put("role", "user");
            ArrayNode content = userNode.putArray("content");
            content.addObject().put("type", "text").put("text", userMessage);

            ObjectNode imagePart = content.addObject();
            imagePart.put("type", "image_url");
            imagePart.putObject("image_url").put("url", imageUrl);

            String response = webClient.post()
                .uri("/chat/completions")
                .bodyValue(body)
                .retrieve()
                .bodyToMono(String.class)
                .retryWhen(Retry.fixedDelay(MAX_RETRIES, Duration.ofSeconds(2)))
                .block(TIMEOUT);

            if (response == null) return Optional.empty();

            JsonNode root = objectMapper.readTree(response);
            String contentText = root.path("choices").get(0).path("message").path("content").asText(null);
            return Optional.ofNullable(contentText);

        } catch (Exception e) {
            log.warn("LLM vision call failed: {}", e.getMessage());
            return Optional.empty();
        }
    }
}
