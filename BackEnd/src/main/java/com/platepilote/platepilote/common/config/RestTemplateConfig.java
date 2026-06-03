package com.platepilote.platepilote.common.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.client.RestTemplate;

/**
 * Configuration du RestTemplate pour les appels HTTP sortants.
 */
@Configuration
public class RestTemplateConfig {

    /**
     * Crée un RestTemplate pour les appels HTTP vers des services externes.
     *
     * @return nouvelle instance de RestTemplate
     */
    @Bean
    public RestTemplate restTemplate() {
        return new RestTemplate();
    }
}
