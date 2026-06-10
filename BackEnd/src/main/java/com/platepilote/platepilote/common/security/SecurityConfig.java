package com.platepilote.platepilote.common.security;

/**
 * Configuration de la sécurité HTTP de l'application.
 * <p>
 * Définit les endpoints publics, les règles d'autorisation par rôle,
 * la gestion de session sans état (stateless), et le filtre JWT.
 * </p>
 *
 * <p>Endpoints publics (sans authentification) :</p>
 * <ul>
 *   <li>{@code /api/v1/auth/**} — connexion, inscription, rafraîchissement</li>
 *   <li>{@code /api/v1/recipes/public/**} — recettes publiques</li>
 *   <li>{@code /swagger-ui/**}, {@code /v3/api-docs/**} — documentation</li>
 *   <li>{@code /actuator/**} — health check</li>
 * </ul>
 */
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.AuthenticationProvider;
import org.springframework.security.authentication.dao.DaoAuthenticationProvider;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsUtils;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

import java.util.List;

@Configuration
@EnableWebSecurity
@EnableMethodSecurity
@RequiredArgsConstructor
public class SecurityConfig {

    private final JwtAuthenticationFilter jwtAuthFilter;
        private final RateLimitingFilter rateLimitingFilter;
        private final UserDetailsService userDetailsService;

        /** Origines CORS autorisées, injectées via application properties / profiles. */
        @Value("${app.cors.allowed-origins:http://localhost:5173,http://localhost:3000}")
        private List<String> corsAllowedOrigins;

    /** Endpoints publics accessibles sans authentification. */
    private static final String[] PUBLIC_ENDPOINTS = {
            "/api/v1/auth/register",
            "/api/v1/auth/login",
            "/api/v1/auth/oauth2",
            "/api/v1/auth/refresh",
            "/api/v1/auth/verify-email",
            "/api/v1/auth/resend-verification",
            "/api/v1/auth/logout",
            "/api/v1/billing/stripe/webhook",
            "/api/v1/recipes/public/**",
            "/api/v1/ingredients/**",
            "/api/v1/pricing/**",
            "/v3/api-docs/**",
            "/swagger-ui/**",
            "/swagger-ui.html",
            "/api/v1/auth/forgot-password",
            "/api/v1/auth/reset-password",
            "/actuator/health",
            "/actuator/info"
    };

    /**
     * Configure la chaîne de filtres de sécurité.
     * <p>
     * Désactive CSRF, définit les règles d'autorisation, configure les sessions
     * sans état et enregistre le filtre JWT.
     * </p>
     *
     * @param http configuration HTTP de sécurité
     * @return chaîne de filtres de sécurité
     * @throws Exception en cas d'erreur de configuration
     */
    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
                // Disable CSRF protection - not needed for stateless JWT APIs
                // (CSRF is for browser sessions with cookies, not token-based auth)
                .csrf(AbstractHttpConfigurer::disable)
                .cors(cors -> cors.configurationSource(corsConfigurationSource()))

                .authorizeHttpRequests(auth -> auth
                        .requestMatchers(CorsUtils::isPreFlightRequest).permitAll()
                        .requestMatchers(PUBLIC_ENDPOINTS).permitAll()
                        .requestMatchers("/api/v1/admin/users/*/roles", "/api/v1/admin/feature-flags/**")
                            .hasRole("SUPER_ADMIN")
                        .requestMatchers("/api/v1/admin/**")
                            .hasAnyRole("ADMIN", "SUPER_ADMIN", "SUPPORT_AGENT", "ANALYST", "CONTENT_MANAGER")
                        .requestMatchers("/api/v1/imports/**")
                            .hasAnyRole("ADMIN", "SUPER_ADMIN", "CONTENT_MANAGER", "SYSTEM")
                        .anyRequest().authenticated()
                )

                .sessionManagement(session -> session
                        .sessionCreationPolicy(SessionCreationPolicy.STATELESS)
                )

                .authenticationProvider(authenticationProvider())

                .addFilterBefore(jwtAuthFilter, UsernamePasswordAuthenticationFilter.class)
                .addFilterBefore(rateLimitingFilter, UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }

    /**
     * Fournisseur d'authentification qui valide les identifiants utilisateur.
     * Utilise {@link UserDetailsService} pour charger les données utilisateur
     * et {@link BCryptPasswordEncoder} pour vérifier les mots de passe.
     *
     * @return fournisseur d'authentification
     */
    @Bean
    public AuthenticationProvider authenticationProvider() {
        DaoAuthenticationProvider authProvider = new DaoAuthenticationProvider();
        authProvider.setUserDetailsService(userDetailsService);
        authProvider.setPasswordEncoder(passwordEncoder());
        return authProvider;
    }

    /**
     * Gestionnaire d'authentification utilisé par l'endpoint de connexion.
     *
     * @param config configuration d'authentification Spring
     * @return gestionnaire d'authentification
     * @throws Exception en cas d'erreur
     */
    @Bean
    public AuthenticationManager authenticationManager(AuthenticationConfiguration config) throws Exception {
        return config.getAuthenticationManager();
    }

    /**
     * Encodeur de mots de passe utilisant BCrypt.
     * BCrypt est un algorithme de hachage unidirectionnel conçu pour les mots de passe.
     *
     * @return encodeur BCrypt
     */
    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    /**
         * Source de configuration CORS pour autoriser les requêtes cross-origin.
         * Les origines autorisées sont définies par le profil Spring (dev / prod)
         * via la propriété {@code app.cors.allowed-origins}.
         * <ul>
         *   <li>Profil {@code dev} (défaut) : {@code http://localhost:5173}, {@code http://localhost:3000}</li>
         *   <li>Profil {@code prod} : {@code https://platepilote.com}, {@code https://www.platepilote.com}</li>
         * </ul>
         *
         * @return source de configuration CORS
         */
        @Bean
        public CorsConfigurationSource corsConfigurationSource() {
            CorsConfiguration configuration = new CorsConfiguration();
            configuration.setAllowedOriginPatterns(corsAllowedOrigins);
            configuration.setAllowedMethods(java.util.List.of("GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"));
            configuration.setAllowedHeaders(java.util.List.of("Authorization", "Content-Type", "X-Requested-With", "Accept"));
            configuration.setMaxAge(java.time.Duration.ofHours(1));
            configuration.setAllowCredentials(true);

            UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
            source.registerCorsConfiguration("/**", configuration);
            return source;
        }
}
