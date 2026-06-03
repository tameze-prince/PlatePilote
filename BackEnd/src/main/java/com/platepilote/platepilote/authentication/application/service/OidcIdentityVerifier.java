package com.platepilote.platepilote.authentication.application.service;

import com.platepilote.platepilote.authentication.application.config.OAuth2LoginProperties;
import com.platepilote.platepilote.common.kernel.BusinessRuleViolationException;
import lombok.RequiredArgsConstructor;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.security.oauth2.jwt.JwtException;
import org.springframework.security.oauth2.jwt.NimbusJwtDecoder;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

/**
 * Vérificateur OAuth2 pour les fournisseurs OIDC (Google, Apple).
 * <p>
 * Valide les tokens JWT en utilisant JWKS (JSON Web Key Set) récupéré
 * via l'URI fournie dans {@link OAuth2LoginProperties.Provider#jwkSetUri}.
 * Vérifie l'émetteur (issuer) et le public (audience) du token.
 * </p>
 */
@Service
@RequiredArgsConstructor
public class OidcIdentityVerifier implements OAuth2IdentityVerifier {

    private final OAuth2LoginProperties properties;
    private final Map<String, NimbusJwtDecoder> decoders = new ConcurrentHashMap<>();

    /**
     * Vérifie un token ID OIDC (Google ou Apple) et retourne l'identité.
     *
     * @param provider le fournisseur (google, apple)
     * @param idToken  le token JWT ID
     * @return l'identité vérifiée
     * @throws BusinessRuleViolationException si la validation échoue
     */
    @Override
    public OAuth2Identity verify(String provider, String idToken) {
        String normalizedProvider = normalizeProvider(provider);
        OAuth2LoginProperties.Provider providerProperties = providerProperties(normalizedProvider);
        List<String> clientIds = configuredClientIds(providerProperties);
        if (clientIds.isEmpty()) {
            throw new BusinessRuleViolationException("OAuth2 " + normalizedProvider + " client id is not configured");
        }

        Jwt jwt;
        try {
            jwt = decoder(normalizedProvider, providerProperties).decode(idToken);
        } catch (JwtException ex) {
            throw new BusinessRuleViolationException("Invalid OAuth2 token");
        }

        String issuer = jwt.getIssuer() == null ? "" : jwt.getIssuer().toString();
        if (!providerProperties.getIssuers().contains(issuer)) {
            throw new BusinessRuleViolationException("Invalid OAuth2 issuer");
        }
        if (jwt.getAudience().stream().noneMatch(clientIds::contains)) {
            throw new BusinessRuleViolationException("Invalid OAuth2 audience");
        }

        String providerId = jwt.getSubject();
        String email = jwt.getClaimAsString("email");
        if (providerId == null || providerId.isBlank()) {
            throw new BusinessRuleViolationException("OAuth2 token is missing subject");
        }

        String name = jwt.getClaimAsString("name");
        String firstName = valueOrDefault(jwt.getClaimAsString("given_name"), splitName(name, true));
        String lastName = valueOrDefault(jwt.getClaimAsString("family_name"), splitName(name, false));

        return new OAuth2Identity(
                normalizedProvider,
                providerId,
                email == null ? null : email.toLowerCase(Locale.ROOT),
                emailVerified(jwt),
                firstName,
                lastName,
                jwt.getClaimAsString("picture")
        );
    }

    /**
     * Retourne (ou crée) un {@link NimbusJwtDecoder} pour le fournisseur donné.
     *
     * @param provider           le nom du fournisseur
     * @param providerProperties les propriétés du fournisseur
     * @return le décodeur JWT
     */
    private NimbusJwtDecoder decoder(String provider, OAuth2LoginProperties.Provider providerProperties) {
        return decoders.computeIfAbsent(provider,
                ignored -> NimbusJwtDecoder.withJwkSetUri(providerProperties.getJwkSetUri()).build());
    }

    /**
     * Retourne les propriétés du fournisseur en fonction de son nom.
     *
     * @param provider le nom normalisé du fournisseur
     * @return les propriétés associées
     * @throws BusinessRuleViolationException si le fournisseur n'est pas supporté
     */
    private OAuth2LoginProperties.Provider providerProperties(String provider) {
        return switch (provider) {
            case "google" -> properties.getGoogle();
            case "apple" -> properties.getApple();
            default -> throw new BusinessRuleViolationException("Unsupported OAuth2 provider: " + provider);
        };
    }

    /**
     * Filtre et retourne la liste des IDs client configurés (non nuls, non vides).
     *
     * @param providerProperties les propriétés du fournisseur
     * @return la liste des IDs client valides
     */
    private List<String> configuredClientIds(OAuth2LoginProperties.Provider providerProperties) {
        if (providerProperties.getClientIds() == null) {
            return List.of();
        }
        return providerProperties.getClientIds().stream()
                .filter(value -> value != null && !value.isBlank())
                .map(String::trim)
                .toList();
    }

    /**
     * Normalise le nom du fournisseur.
     *
     * @param provider le nom du fournisseur
     * @return le nom normalisé en minuscules
     * @throws BusinessRuleViolationException si le fournisseur est {@code null} ou vide
     */
    private String normalizeProvider(String provider) {
        if (provider == null || provider.isBlank()) {
            throw new BusinessRuleViolationException("OAuth2 provider is required");
        }
        return provider.trim().toLowerCase(Locale.ROOT);
    }

    /**
     * Vérifie si la revendication {@code email_verified} du JWT est vraie.
     *
     * @param jwt le token JWT
     * @return {@code true} si l'email est vérifié
     */
    private boolean emailVerified(Jwt jwt) {
        Object value = jwt.getClaims().get("email_verified");
        if (value instanceof Boolean bool) {
            return bool;
        }
        return value != null && Boolean.parseBoolean(value.toString());
    }

    /**
     * Extrait le prénom ou le nom depuis le champ {@code name}.
     *
     * @param name  le nom complet
     * @param first {@code true} pour le prénom, {@code false} pour le nom
     * @return la partie extraite, ou {@code null} si indisponible
     */
    private String splitName(String name, boolean first) {
        if (name == null || name.isBlank()) {
            return null;
        }
        List<String> parts = List.of(name.trim().split("\\s+", 2));
        if (first) {
            return parts.getFirst();
        }
        return parts.size() > 1 ? parts.get(1) : null;
    }

    /**
     * Retourne {@code value} si non vide, sinon {@code fallback}.
     *
     * @param value    la valeur principale
     * @param fallback la valeur de repli
     * @return {@code value} ou {@code fallback}
     */
    private String valueOrDefault(String value, String fallback) {
        return value == null || value.isBlank() ? fallback : value;
    }
}
