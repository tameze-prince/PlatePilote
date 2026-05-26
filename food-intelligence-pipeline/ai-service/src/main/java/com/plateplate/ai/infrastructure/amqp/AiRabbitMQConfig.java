package com.plateplate.ai.infrastructure.amqp;

import org.springframework.amqp.core.Binding;
import org.springframework.amqp.core.BindingBuilder;
import org.springframework.amqp.core.Queue;
import org.springframework.amqp.core.TopicExchange;
import org.springframework.amqp.rabbit.connection.ConnectionFactory;
import org.springframework.amqp.rabbit.listener.SimpleMessageListenerContainer;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class AiRabbitMQConfig {

    @Bean
    public Queue textParsingQueue() {
        return new Queue("food-pipeline.text-parsing", true);
    }

    @Bean
    public Binding textParsingBinding(Queue textParsingQueue, TopicExchange foodPipelineExchange) {
        return BindingBuilder.bind(textParsingQueue)
            .to(foodPipelineExchange).with("text-parsing.*");
    }

    @Bean
    public SimpleMessageListenerContainer aiListenerContainer(
            ConnectionFactory connectionFactory,
            AiMessageListener messageListener) {
        SimpleMessageListenerContainer container = new SimpleMessageListenerContainer();
        container.setConnectionFactory(connectionFactory);
        container.setQueueNames("food-pipeline.image", "food-pipeline.text-parsing");
        container.setMessageListener(messageListener);
        container.setDefaultRequeueRejected(false);
        return container;
    }
}
