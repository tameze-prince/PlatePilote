package com.platepilote.platepilote.common.security;

/**
 * SECURITY CONFIGURATION - SPRING SECURITY SETUP
 * =================================================
 * 
 * WHAT IT IS:
 * This class configures how Spring Security protects the application.
 * 
 * WHAT IT DOES:
 * 1. Disables CSRF (not needed for stateless JWT APIs)
 * 2. Defines which endpoints are public (no login required)
 * 3. Defines which endpoints require authentication
 * 4. Sets up stateless sessions (no server-side session storage)
 * 5. Registers the JWT filter to validate tokens on every request
 * 
 * PUBLIC ENDPOINTS (no login needed):
 * - /api/v1/auth/** -> Login, register, refresh token
 * - /api/v1/recipes/public/** -> Browse public recipes
 * - /swagger-ui/** -> API documentation
 * - /actuator/health -> Health check for Docker/load balancers
 * 
 * ALL OTHER ENDPOINTS require a valid JWT token in the Authorization header.
 */

import lombok.RequiredArgsConstructor;
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

@Configuration  // Tells Spring: "This class contains bean definitions"
@EnableWebSecurity  // Enables Spring Security's web security support
@EnableMethodSecurity  // Enables @PreAuthorize and @PostAuthorize annotations
@RequiredArgsConstructor  // Lombok: Generates constructor for final fields
public class SecurityConfig {

    private final JwtAuthenticationFilter jwtAuthFilter;
    private final UserDetailsService userDetailsService;

    /**
     * These endpoints can be accessed WITHOUT logging in.
     * Everything else requires authentication.
     */
    private static final String[] PUBLIC_ENDPOINTS = {
            "/api/v1/auth/register",     // Create account
            "/api/v1/auth/login",        // Login
            "/api/v1/auth/oauth2",       // Google/Apple OAuth2 ID token login
            "/api/v1/auth/refresh",      // Refresh access token
            "/api/v1/auth/verify-email", // Verify local-account email
            "/api/v1/auth/resend-verification", // Resend local-account verification email
            "/api/v1/auth/logout",       // Revoke a provided refresh token
            "/api/v1/billing/stripe/webhook", // Stripe signed billing webhook
            "/api/v1/recipes/public/**", // Browse public recipes
            "/api/v1/ingredients/**",    // Food intelligence database
            "/api/v1/pricing/**",        // Price and barcode lookup
            "/v3/api-docs/**",           // OpenAPI documentation
            "/swagger-ui/**",            // Swagger UI
            "/swagger-ui.html",
            "/api/v1/auth/forgot-password",
            "/api/v1/auth/reset-password",
            "/actuator/health",          // Health check
            "/actuator/info"
    };

    /**
     * Main security configuration method.
     * This is where we define the security rules for the application.
     */
    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
                // Disable CSRF protection - not needed for stateless JWT APIs
                // (CSRF is for browser sessions with cookies, not token-based auth)
                .csrf(AbstractHttpConfigurer::disable)
                .cors(cors -> cors.configurationSource(corsConfigurationSource()))
                
                // Define which URLs need authentication and which are public
                .authorizeHttpRequests(auth -> auth
                        .requestMatchers(CorsUtils::isPreFlightRequest).permitAll()
                        .requestMatchers(PUBLIC_ENDPOINTS).permitAll()  // Public endpoints
                        .requestMatchers("/api/v1/admin/users/*/roles", "/api/v1/admin/feature-flags/**")
                            .hasRole("SUPER_ADMIN")
                        .requestMatchers("/api/v1/admin/**")
                            .hasAnyRole("ADMIN", "SUPER_ADMIN", "SUPPORT_AGENT", "ANALYST", "CONTENT_MANAGER")
                        .requestMatchers("/api/v1/imports/**")
                            .hasAnyRole("ADMIN", "SUPER_ADMIN", "CONTENT_MANAGER", "SYSTEM")
                        .anyRequest().authenticated()                    // Everything else needs login
                )
                
                // Stateless session management - no server-side session storage
                // Every request must include a valid JWT token
                .sessionManagement(session -> session
                        .sessionCreationPolicy(SessionCreationPolicy.STATELESS)
                )
                
                // Register our authentication provider (username/password validation)
                .authenticationProvider(authenticationProvider())
                
                // Add our JWT filter BEFORE the standard username/password filter
                // This intercepts every request to validate the JWT token
                .addFilterBefore(jwtAuthFilter, UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }

    /**
     * Authentication provider - validates username and password.
     * Uses our UserDetailsService to load user data and BCrypt to verify passwords.
     */
    @Bean
    public AuthenticationProvider authenticationProvider() {
        DaoAuthenticationProvider authProvider = new DaoAuthenticationProvider();
        authProvider.setUserDetailsService(userDetailsService);
        authProvider.setPasswordEncoder(passwordEncoder());
        return authProvider;
    }

    /**
     * Authentication manager - orchestrates the authentication process.
     * Used by the login endpoint to validate credentials.
     */
    @Bean
    public AuthenticationManager authenticationManager(AuthenticationConfiguration config) throws Exception {
        return config.getAuthenticationManager();
    }

    /**
     * Password encoder - hashes passwords using BCrypt.
     * BCrypt is a one-way hashing algorithm designed for passwords.
     * Even if the database is stolen, passwords cannot be recovered.
     */
    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration configuration = new CorsConfiguration();
        configuration.setAllowedOriginPatterns(java.util.List.of("http://localhost:*"));
        configuration.setAllowedMethods(java.util.List.of("GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"));
        configuration.setAllowedHeaders(java.util.List.of("Authorization", "Content-Type", "X-Requested-With", "Accept"));
        configuration.setMaxAge(java.time.Duration.ofHours(1));
        configuration.setAllowCredentials(true);

        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", configuration);
        return source;
    }
}
