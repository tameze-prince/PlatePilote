package com.plateplate.common.config;

import org.springframework.amqp.core.Queue;
import org.springframework.amqp.core.TopicExchange;
import org.springframework.amqp.core.Binding;
import org.springframework.amqp.core.BindingBuilder;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class RabbitMQConfig {

    // Exchanges
    @Bean
    public TopicExchange foodPipelineExchange() {
        return new TopicExchange("food-pipeline", true, false);
    }

    // Queues
    @Bean
    public Queue normalizationQueue() {
        return new Queue("food-pipeline.normalization", true);
    }

    @Bean
    public Queue deduplicationQueue() {
        return new Queue("food-pipeline.deduplication", true);
    }

    @Bean
    public Queue nutritionQueue() {
        return new Queue("food-pipeline.nutrition", true);
    }

    @Bean
    public Queue validationQueue() {
        return new Queue("food-pipeline.validation", true);
    }

    @Bean
    public Queue enrichmentQueue() {
        return new Queue("food-pipeline.enrichment", true);
    }

    @Bean
    public Queue classificationQueue() {
        return new Queue("food-pipeline.classification", true);
    }

    @Bean
    public Queue imageQueue() {
        return new Queue("food-pipeline.image", true);
    }

    @Bean
    public Queue pricingQueue() {
        return new Queue("food-pipeline.pricing", true);
    }

    @Bean
    public Queue knowledgeGraphQueue() {
        return new Queue("food-pipeline.knowledge-graph", true);
    }

    @Bean
    public Queue moderationQueue() {
        return new Queue("food-pipeline.moderation", true);
    }

    @Bean
    public Queue analyticsQueue() {
        return new Queue("food-pipeline.analytics", true);
    }

    // Bindings
    @Bean
    public Binding normalizationBinding(Queue normalizationQueue, TopicExchange foodPipelineExchange) {
        return BindingBuilder.bind(normalizationQueue).to(foodPipelineExchange).with("normalization.*");
    }

    @Bean
    public Binding deduplicationBinding(Queue deduplicationQueue, TopicExchange foodPipelineExchange) {
        return BindingBuilder.bind(deduplicationQueue).to(foodPipelineExchange).with("deduplication.*");
    }

    @Bean
    public Binding nutritionBinding(Queue nutritionQueue, TopicExchange foodPipelineExchange) {
        return BindingBuilder.bind(nutritionQueue).to(foodPipelineExchange).with("nutrition.*");
    }

    @Bean
    public Binding validationBinding(Queue validationQueue, TopicExchange foodPipelineExchange) {
        return BindingBuilder.bind(validationQueue).to(foodPipelineExchange).with("validation.*");
    }
}
