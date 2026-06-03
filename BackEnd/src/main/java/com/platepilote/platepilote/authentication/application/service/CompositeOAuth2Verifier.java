package com.platepilote.platepilote.authentication.application.service;

import com.platepilote.platepilote.authentication.application.config.OAuth2LoginProperties;
import com.platepilote.platepilote.common.kernel.BusinessRuleViolationException;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Primary;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.security.oauth2.jwt.JwtException;
import org.springframework.security.oauth2.jwt.NimbusJwtDecoder;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

/**
 * Vérificateur composite OAuth2 qui achemine la validation vers le vérificateur approprié.
 * <p>
 * Aiguillage :
 * <ul>
 *   <li>Fournisseurs OIDC (Google, Apple) → {@link OidcIdentityVerifier} (JWT via JWKS)</li>
 *   <li>Facebook → {@link FacebookOAuth2Verifier} (API Graph)</li>
 * </ul>
 * </p>
 */
@Service
@Primary
@RequiredArgsConstructor
public class CompositeOAuth2Verifier implements OAuth2IdentityVerifier {

    private final OidcIdentityVerifier oidcVerifier;
    private final FacebookOAuth2Verifier facebookVerifier;

    /**
     * Vérifie un token OAuth2 en fonction du fournisseur.
     *
     * @param provider le fournisseur (google, apple, facebook)
     * @param token    le token à vérifier
     * @return l'identité vérifiée de l'utilisateur
     * @throws BusinessRuleViolationException si le fournisseur n'est pas supporté
     */
    @Override
    public OAuth2Identity verify(String provider, String token) {
        String normalized = normalize(provider);
        return switch (normalized) {
            case "google", "apple" -> oidcVerifier.verify(provider, token);
            case "facebook" -> facebookVerifier.verify(provider, token);
            default -> throw new BusinessRuleViolationException(
                    "Unsupported OAuth2 provider: " + provider
                            + ". Supported: google, apple, facebook");
        };
    }

    /**
     * Normalise le nom du fournisseur (minuscules, sans espaces).
     *
     * @param provider le nom du fournisseur
     * @return le nom normalisé
     * @throws BusinessRuleViolationException si le fournisseur est {@code null} ou vide
     */
    private String normalize(String provider) {
        if (provider == null || provider.isBlank()) {
            throw new BusinessRuleViolationException("OAuth2 provider is required");
        }
        return provider.trim().toLowerCase(Locale.ROOT);
    }
}
