package com.platepilote.platepilote.common.config;

/**
 * CORS CONFIGURATION - CROSS-ORIGIN REQUEST POLICY
 * ==================================================
 * 
 * WHAT IT IS:
 * Configures Cross-Origin Resource Sharing (CORS) policy.
 * 
 * WHAT IS CORS?
 * Browsers block web pages from making requests to different domains for security.
 * CORS tells the browser: "It's OK to allow requests from these specific origins."
 * 
 * WHY IT'S NEEDED:
 * The Flutter app runs on a different domain/port than the backend.
 * Without CORS, the browser would block all API requests from the app.
 * 
 * CONFIGURATION (from application.yml):
 * - allowed-origins: Which domains can make requests (e.g., http://localhost:3000)
 * - allowed-methods: Which HTTP methods are allowed (GET, POST, PUT, DELETE)
 * - allowed-headers: Which headers can be sent (Authorization, Content-Type)
 * - max-age: How long the browser caches the CORS policy (3600 seconds = 1 hour)
 */

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;
import org.springframework.web.filter.CorsFilter;

import java.util.List;

@Configuration
public class CorsConfig {

    @Value("${app.cors.allowed-origins}")
    private List<String> allowedOrigins;

    @Value("${app.cors.allowed-methods}")
    private List<String> allowedMethods;

    @Value("${app.cors.allowed-headers}")
    private List<String> allowedHeaders;

    @Value("${app.cors.max-age}")
    private long maxAge;

    @Bean
    public CorsFilter corsFilter() {
        CorsConfiguration configuration = new CorsConfiguration();
        configuration.setAllowedOrigins(allowedOrigins);
        configuration.setAllowedMethods(allowedMethods);
        configuration.setAllowedHeaders(allowedHeaders);
        configuration.setMaxAge(maxAge);
        configuration.setAllowCredentials(true);  // Allow cookies/auth headers

        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", configuration);  // Apply to all endpoints
        return new CorsFilter(source);
    }
}
