package com.platepilote.platepilote.authentication.application.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.platepilote.platepilote.authentication.application.config.OAuth2LoginProperties;
import com.platepilote.platepilote.common.kernel.BusinessRuleViolationException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.Locale;

/**
 * Vérificateur OAuth2 pour Facebook via l'API Graph.
 * <p>
 * Contrairement à Google et Apple (OIDC avec JWTs signés), Facebook utilise
 * des tokens d'accès opaques validés en appelant l'API Graph :
 * <ul>
 *   <li>{@code GET /me?fields=id,email,name,picture&access_token=...}</li>
 *   <li>{@code GET /app?access_token=...} (vérifie que l'application possède le token)</li>
 * </ul>
 * </p>
 */
@Service
@RequiredArgsConstructor
@Slf4j
@SuppressWarnings("null") // Suppression des warnings de nullabilité pour les champs injectés et les variables locales  
public class FacebookOAuth2Verifier implements OAuth2IdentityVerifier {

    private final OAuth2LoginProperties properties;
    private final RestTemplate restTemplate;
    private final ObjectMapper objectMapper;

    /**
     * Vérifie un token d'accès Facebook et retourne l'identité de l'utilisateur.
     *
     * @param provider    le fournisseur (doit être {@code "facebook"})
     * @param accessToken le token d'accès Facebook
     * @return l'identité vérifiée
     * @throws BusinessRuleViolationException si la vérification échoue
     */
    @Override
    public OAuth2Identity verify(String provider, String accessToken) {
        String normalizedProvider = normalizeProvider(provider);
        if (!"facebook".equals(normalizedProvider)) {
            throw new BusinessRuleViolationException(
                    "FacebookOAuth2Verifier only handles 'facebook', got: " + provider);
        }

        OAuth2LoginProperties.Provider providerProps = properties.getFacebook();
        String appId = providerProps.getClientIds().isEmpty()
                ? null : providerProps.getClientIds().getFirst();
        String graphUri = providerProps.getGraphUri();
        String appSecret = providerProps.getAppSecret();

        if (appId == null || appId.isBlank()) {
            throw new BusinessRuleViolationException(
                    "OAuth2 Facebook client id is not configured");
        }
        if (graphUri == null || graphUri.isBlank()) {
            throw new BusinessRuleViolationException(
                    "OAuth2 Facebook graph URI is not configured");
        }

        // 1. Vérifie que le token d'accès appartient à notre application
        verifyAppAccessToken(graphUri, accessToken, appId, appSecret);

        // 2. Récupère le profil utilisateur
        return fetchUserProfile(graphUri, accessToken, appSecret);
    }

    /**
     * Vérifie que le token d'accès appartient bien à l'application.
     *
     * @param graphUri     l'URI de l'API Graph
     * @param accessToken  le token d'accès à vérifier
     * @param appId        l'ID de l'application
     * @param appSecret    le secret de l'application
     */
    private void verifyAppAccessToken(String graphUri, String accessToken,
                                       String appId, String appSecret) {
        String appAccessToken = appId + "|" + appSecret;
        String url = graphUri + "/app"
                + "?access_token=" + appAccessToken
                + "&input_token=" + accessToken;

        try {
            ResponseEntity<String> response = restTemplate.exchange(
                    url, HttpMethod.GET, null, String.class);
            JsonNode root = objectMapper.readTree(response.getBody());
            if (root.has("error")) {
                throw new BusinessRuleViolationException(
                        "Facebook token verification failed: " + root.get("error").get("message"));
            }
            String verifiedAppId = root.path("id").asText(null);
            if (!appId.equals(verifiedAppId)) {
                throw new BusinessRuleViolationException("Facebook token does not belong to this app");
            }
        } catch (BusinessRuleViolationException e) {
            throw e;
        } catch (Exception e) {
            log.warn("Facebook app token verification failed: {}", e.getMessage());
            throw new BusinessRuleViolationException("Facebook token verification failed");
        }
    }

    /**
     * Récupère le profil utilisateur depuis l'API Graph Facebook.
     *
     * @param graphUri    l'URI de l'API Graph
     * @param accessToken le token d'accès
     * @param appSecret   le secret de l'application
     * @return l'identité OAuth2 de l'utilisateur
     */
    private OAuth2Identity fetchUserProfile(String graphUri, String accessToken, String appSecret) {
        String url = graphUri + "/me"
                + "?fields=id,email,name,picture"
                + "&access_token=" + accessToken;

        try {
            ResponseEntity<String> response = restTemplate.exchange(
                    url, HttpMethod.GET, new HttpEntity<>(new HttpHeaders()), String.class);
            JsonNode user = objectMapper.readTree(response.getBody());

            if (user.has("error")) {
                throw new BusinessRuleViolationException(
                        "Facebook user info failed: " + user.get("error").get("message"));
            }

            String id = user.path("id").asText(null);
            String email = user.has("email") && !user.get("email").isNull()
                    ? user.get("email").asText().toLowerCase(Locale.ROOT) : null;
            String name = user.has("name") ? user.get("name").asText() : null;
            String picture = user.has("picture")
                    ? user.path("picture").path("data").path("url").asText(null) : null;

            if (id == null || id.isBlank()) {
                throw new BusinessRuleViolationException("Facebook token is missing subject");
            }

            // Les emails Facebook sont toujours vérifiés
            boolean emailVerified = email != null && !email.isBlank();

            String firstName = null;
            String lastName = null;
            if (name != null && !name.isBlank()) {
                String[] parts = name.split("\\s+", 2);
                firstName = parts[0];
                lastName = parts.length > 1 ? parts[1] : null;
            }

            return new OAuth2Identity("facebook", id, email, emailVerified,
                    firstName, lastName, picture);

        } catch (BusinessRuleViolationException e) {
            throw e;
        } catch (Exception e) {
            log.warn("Facebook user profile fetch failed: {}", e.getMessage());
            throw new BusinessRuleViolationException("Facebook user profile fetch failed");
        }
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
}
