package com.plateplate.ai.infrastructure.amqp;

import com.plateplate.ai.application.service.FoodImageIdentifier;
import com.plateplate.ai.application.service.RecipeTextParser;
import com.plateplate.ai.domain.model.FoodIdentification;
import com.plateplate.ai.domain.model.ParsedRecipe;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.amqp.core.Message;
import org.springframework.amqp.core.MessageListener;
import org.springframework.amqp.rabbit.core.RabbitTemplate;

import java.nio.charset.StandardCharsets;

public class AiMessageListener implements MessageListener {
    private static final Logger log = LoggerFactory.getLogger(AiMessageListener.class);

    private final FoodImageIdentifier foodImageIdentifier;
    private final RecipeTextParser recipeTextParser;
    private final RabbitTemplate rabbitTemplate;

    public AiMessageListener(
            FoodImageIdentifier foodImageIdentifier,
            RecipeTextParser recipeTextParser,
            RabbitTemplate rabbitTemplate) {
        this.foodImageIdentifier = foodImageIdentifier;
        this.recipeTextParser = recipeTextParser;
        this.rabbitTemplate = rabbitTemplate;
    }

    @Override
    public void onMessage(Message message) {
        String routingKey = message.getMessageProperties().getReceivedRoutingKey();
        String body = new String(message.getBody(), StandardCharsets.UTF_8);

        try {
            if (routingKey != null && routingKey.startsWith("image.")) {
                log.info("Processing image message from routing key: {}", routingKey);
                FoodIdentification identification = foodImageIdentifier.identify(body);
                rabbitTemplate.convertAndSend("food-pipeline", "enrichment.image", identification);
                log.info("Image identified: {}", identification.getFoodName());

            } else if (routingKey != null && routingKey.startsWith("text-parsing.")) {
                log.info("Processing text parsing message from routing key: {}", routingKey);
                ParsedRecipe recipe = recipeTextParser.parse(body);
                rabbitTemplate.convertAndSend("food-pipeline", "normalization.recipe", recipe);
                log.info("Recipe parsed: {}", recipe.getTitle());
            }
        } catch (Exception e) {
            log.error("Failed to process message from {}: {}", routingKey, e.getMessage());
        }
    }
}
