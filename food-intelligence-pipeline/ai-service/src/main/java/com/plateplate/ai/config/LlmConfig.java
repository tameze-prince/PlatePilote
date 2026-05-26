package com.plateplate.ai.config;

import com.plateplate.ai.infrastructure.llm.LlmClient;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class LlmConfig {
    private static final Logger log = LoggerFactory.getLogger(LlmConfig.class);

    @Bean
    public LlmClient primaryLlmClient(AiConfig aiConfig) {
        String provider = aiConfig.getPrimaryProvider();
        AiConfig.ProviderConfig cfg = aiConfig.getProviders().get(provider);
        if (cfg == null || cfg.getApiKey() == null || cfg.getApiKey().isBlank()) {
            log.warn("No API key configured for provider '{}', LLM features will fall back to defaults", provider);
            return null;
        }
        log.info("Initializing LLM client: provider={}, model={}", provider, cfg.getModel());
        return new LlmClient(cfg.getBaseUrl(), cfg.getApiKey(), cfg.getModel());
    }

    @Bean
    public LlmClient visionLlmClient(AiConfig aiConfig) {
        String provider = aiConfig.getVision().getProvider();
        AiConfig.ProviderConfig cfg = aiConfig.getProviders().get(provider);
        if (cfg == null || cfg.getApiKey() == null || cfg.getApiKey().isBlank()) {
            log.warn("No API key configured for vision provider '{}', image identification will fall back", provider);
            return null;
        }
        return new LlmClient(cfg.getBaseUrl(), cfg.getApiKey(), cfg.getModel());
    }
}
