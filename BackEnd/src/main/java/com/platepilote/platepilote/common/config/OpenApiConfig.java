package com.platepilote.platepilote.common.config;

/**
 * Configuration OpenAPI / Swagger pour la documentation de l'API.
 * <p>
 * Définit les métadonnées de l'API (titre, version, contact, licence)
 * ainsi que le schéma d'authentification JWT Bearer.
 * </p>
 *
 * <p><b>Accès :</b></p>
 * <ul>
 *   <li>Swagger UI : {@code http://localhost:8080/swagger-ui.html}</li>
 *   <li>Spec OpenAPI : {@code http://localhost:8080/v3/api-docs}</li>
 * </ul>
 *
 * <p><b>Note de sécurité :</b> En production, désactiver Swagger ou le protéger par authentification.</p>
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

    /**
     * Crée et configure l'instance OpenAPI personnalisée avec les métadonnées
     * de l'API et le schéma de sécurité JWT Bearer.
     *
     * @return instance OpenAPI configurée
     */
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
