package com.platepilote.platepilote.authentication.application.config;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;
import org.springframework.validation.annotation.Validated;

/**
 * Propriétés de configuration OAuth2 pour les fournisseurs d'identité.
 * <p>
 * Toutes les valeurs sont injectées depuis {@code application.yml} ou les variables d'environnement.
 * </p>
 *
 * <p>Variables d'environnement requises en production :</p>
 * <ul>
 *   <li>{@code GOOGLE_OAUTH_CLIENT_IDS} — IDs client Google (Web, iOS, Android) séparés par des virgules</li>
 *   <li>{@code GOOGLE_OAUTH_JWK_SET_URI} — {@code https://www.googleapis.com/oauth2/v3/certs}</li>
 *   <li>{@code GOOGLE_OAUTH_ISSUERS} — {@code https://accounts.google.com,accounts.google.com}</li>
 *   <li>{@code APPLE_OAUTH_CLIENT_IDS} — IDs client Apple séparés par des virgules</li>
 *   <li>{@code APPLE_OAUTH_JWK_SET_URI} — {@code https://appleid.apple.com/auth/keys}</li>
 *   <li>{@code APPLE_OAUTH_ISSUERS} — {@code https://appleid.apple.com}</li>
 *   <li>{@code FACEBOOK_OAUTH_CLIENT_ID} — ID de l'application Facebook</li>
 *   <li>{@code FACEBOOK_OAUTH_CLIENT_SECRET} — Secret de l'application Facebook</li>
 *   <li>{@code FACEBOOK_OAUTH_GRAPH_URI} — {@code https://graph.facebook.com/v19.0}</li>
 * </ul>
 */
@Component
@Validated
@ConfigurationProperties(prefix = "app.oauth2")
public class OAuth2LoginProperties {

    /** Configuration du fournisseur Google. */
    private final Provider google = new Provider();

    /** Configuration du fournisseur Apple. */
    private final Provider apple = new Provider();

    /** Configuration du fournisseur Facebook. */
    private final Provider facebook = new Provider();

    /**
     * Retourne la configuration Google.
     * @return la configuration Google
     */
    public Provider getGoogle() { return google; }

    /**
     * Retourne la configuration Apple.
     * @return la configuration Apple
     */
    public Provider getApple() { return apple; }

    /**
     * Retourne la configuration Facebook.
     * @return la configuration Facebook
     */
    public Provider getFacebook() { return facebook; }

    /**
     * Configuration d'un fournisseur OAuth2.
     * <p>
     * Les champs sont liés de manière flexible par Spring (relaxed binding).
     * </p>
     */
    public static class Provider {

        /** IDs client OAuth2 séparés par des virgules (audience / azp). */
        private String clientId;

        /** URI JWK Set pour la validation JWT (fournisseurs OIDC : Google, Apple). */
        private String jwkSetUri;

        /** Émetteurs autorisés, séparés par des virgules (fournisseurs OIDC). */
        private String issuers;

        /** URL de base de l'API Graph Facebook pour la validation du token. */
        private String graphUri;

        /** Secret de l'application Facebook pour la génération du token d'accès. */
        private String appSecret;

        /**
         * Retourne l'ID client brut.
         * @return l'ID client
         */
        public String getClientId() { return clientId; }

        /**
         * Définit l'ID client.
         * @param clientId le nouvel ID client
         */
        public void setClientId(String clientId) { this.clientId = clientId; }

        /**
         * Retourne les IDs client sous forme de liste.
         * @return la liste des IDs client, vide si non définie
         */
        public java.util.List<String> getClientIds() {
            if (clientId == null || clientId.isBlank()) {
                return java.util.List.of();
            }
            return java.util.Arrays.stream(clientId.split(","))
                    .map(String::trim)
                    .filter(s -> !s.isBlank())
                    .toList();
        }

        /**
         * Retourne l'URI JWK Set.
         * @return l'URI JWK Set
         */
        public String getJwkSetUri() { return jwkSetUri; }

        /**
         * Définit l'URI JWK Set.
         * @param jwkSetUri la nouvelle URI
         */
        public void setJwkSetUri(String jwkSetUri) { this.jwkSetUri = jwkSetUri; }

        /**
         * Retourne les émetteurs sous forme de liste.
         * @return la liste des émetteurs, ou l'hôte de JWK Set URI par défaut
         */
        public java.util.List<String> getIssuers() {
            if (issuers == null || issuers.isBlank()) {
                return jwkSetUri != null ? java.util.List.of(jwkSetUri) : java.util.List.of();
            }
            return java.util.Arrays.stream(issuers.split(","))
                    .map(String::trim)
                    .filter(s -> !s.isBlank())
                    .toList();
        }

        /**
         * Définit les émetteurs.
         * @param issuers la chaîne des émetteurs séparés par des virgules
         */
        public void setIssuers(String issuers) { this.issuers = issuers; }

        /**
         * Retourne l'URI de l'API Graph Facebook.
         * @return l'URI Graph
         */
        public String getGraphUri() { return graphUri; }

        /**
         * Définit l'URI de l'API Graph Facebook.
         * @param graphUri la nouvelle URI
         */
        public void setGraphUri(String graphUri) { this.graphUri = graphUri; }

        /**
         * Retourne le secret de l'application Facebook.
         * @return le secret
         */
        public String getAppSecret() { return appSecret; }

        /**
         * Définit le secret de l'application Facebook.
         * @param appSecret le nouveau secret
         */
        public void setAppSecret(String appSecret) { this.appSecret = appSecret; }
    }
}
