package com.platepilote.platepilote.common.config;

/**
 * OPENAPI CONFIGURATION - SWAGGER API DOCUMENTATION
 * ===================================================
 * 
 * WHAT IT IS:
 * Configures Swagger/OpenAPI documentation for the API.
 * 
 * WHAT IS SWAGGER?
 * Swagger is an interactive API documentation tool.
 * It shows all available endpoints, request/response formats, and lets you test them.
 * 
 * HOW TO ACCESS:
 * - Swagger UI: http://localhost:8080/swagger-ui.html
 * - Raw OpenAPI spec: http://localhost:8080/v3/api-docs
 * 
 * WHAT IT SHOWS:
 * - All REST endpoints (URLs, HTTP methods)
 * - Request parameters and body formats
 * - Response formats and status codes
 * - Authentication requirements (JWT Bearer token)
 * 
 * SECURITY NOTE:
 * In production, Swagger should be disabled or protected.
 * It exposes all API endpoints which could be a security risk.
 */

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Contact;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.info.License;
import io.swagger.v3.oas.models.security.SecurityRequirement;
import io.swagger.v3.oas.models.security.SecurityScheme;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class OpenApiConfig {

    @Bean
    public OpenAPI customOpenAPI() {
        final String securitySchemeName = "bearerAuth";

        return new OpenAPI()
                .info(new Info()
                        .title("PlatePilote API")
                        .version("1.0.0")
                        .description("Modular Monolith Backend with DDD - API Documentation")
                        .contact(new Contact()
                                .name("PlatePilote Team")
                                .email("contact@platepilote.com"))
                        .license(new License()
                                .name("Apache 2.0")
                                .url("https://www.apache.org/licenses/LICENSE-2.0")))
                .addSecurityItem(new SecurityRequirement().addList(securitySchemeName))
                .components(new io.swagger.v3.oas.models.Components()
                        .addSecuritySchemes(securitySchemeName,
                                new SecurityScheme()
                                        .name(securitySchemeName)
                                        .type(SecurityScheme.Type.HTTP)
                                        .scheme("bearer")
                                        .bearerFormat("JWT")));
    }
}
