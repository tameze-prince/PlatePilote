package com.plateplate.ai.config;

import com.plateplate.ai.application.service.*;
import com.plateplate.ai.infrastructure.amqp.AiMessageListener;
import com.plateplate.ai.infrastructure.llm.LlmClient;
import org.springframework.amqp.rabbit.core.RabbitTemplate;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;

@Configuration
public class AiServiceBeanConfig {

    @Bean
    public DefaultRecipeTextParser defaultRecipeTextParser() {
        return new DefaultRecipeTextParser();
    }

    @Bean
    @Primary
    public RecipeTextParser primaryRecipeTextParser(
            LlmClient primaryLlmClient,
            DefaultRecipeTextParser defaultParser) {
        if (primaryLlmClient != null) {
            return new LlmRecipeTextParser(primaryLlmClient, defaultParser);
        }
        return defaultParser;
    }

    @Bean
    public DefaultFoodImageIdentifier defaultFoodImageIdentifier() {
        return new DefaultFoodImageIdentifier();
    }

    @Bean
    @Primary
    public FoodImageIdentifier primaryFoodImageIdentifier(
            LlmClient visionLlmClient,
            DefaultFoodImageIdentifier defaultIdentifier) {
        if (visionLlmClient != null) {
            return new LlmFoodImageIdentifier(visionLlmClient, defaultIdentifier);
        }
        return defaultIdentifier;
    }

    @Bean
    public DefaultNutritionEstimator defaultNutritionEstimator() {
        return new DefaultNutritionEstimator();
    }

    @Bean
    @Primary
    public NutritionEstimator primaryNutritionEstimator(
            LlmClient primaryLlmClient,
            DefaultNutritionEstimator defaultEstimator) {
        if (primaryLlmClient != null) {
            return new LlmNutritionEstimator(primaryLlmClient, defaultEstimator);
        }
        return defaultEstimator;
    }

    @Bean
    public AiMessageListener aiMessageListener(
            FoodImageIdentifier foodImageIdentifier,
            RecipeTextParser recipeTextParser,
            RabbitTemplate rabbitTemplate) {
        return new AiMessageListener(foodImageIdentifier, recipeTextParser, rabbitTemplate);
    }
}
