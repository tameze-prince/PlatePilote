package com.plateplate.ai.config;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Configuration;

import java.util.Map;

@Configuration
@ConfigurationProperties(prefix = "app.ai")
public class AiConfig {
    private String primaryProvider;
    private Map<String, ProviderConfig> providers;
    private EstimationConfig estimation;
    private VisionConfig vision;

    public String getPrimaryProvider() { return primaryProvider; }
    public void setPrimaryProvider(String primaryProvider) { this.primaryProvider = primaryProvider; }
    public Map<String, ProviderConfig> getProviders() { return providers; }
    public void setProviders(Map<String, ProviderConfig> providers) { this.providers = providers; }
    public EstimationConfig getEstimation() { return estimation; }
    public void setEstimation(EstimationConfig estimation) { this.estimation = estimation; }
    public VisionConfig getVision() { return vision; }
    public void setVision(VisionConfig vision) { this.vision = vision; }

    public static class ProviderConfig {
        private String baseUrl;
        private String apiKey;
        private String model;

        public String getBaseUrl() { return baseUrl; }
        public void setBaseUrl(String baseUrl) { this.baseUrl = baseUrl; }
        public String getApiKey() { return apiKey; }
        public void setApiKey(String apiKey) { this.apiKey = apiKey; }
        public String getModel() { return model; }
        public void setModel(String model) { this.model = model; }
    }

    public static class EstimationConfig {
        private String mode;

        public String getMode() { return mode; }
        public void setMode(String mode) { this.mode = mode; }
    }

    public static class VisionConfig {
        private String provider;

        public String getProvider() { return provider; }
        public void setProvider(String provider) { this.provider = provider; }
    }
}
