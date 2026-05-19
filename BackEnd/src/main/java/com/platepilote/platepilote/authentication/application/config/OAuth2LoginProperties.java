package com.platepilote.platepilote.authentication.application.config;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.List;

@Component
@ConfigurationProperties(prefix = "app.oauth2")
public class OAuth2LoginProperties {

    private final Provider google = new Provider(
            "https://www.googleapis.com/oauth2/v3/certs",
            List.of("https://accounts.google.com", "accounts.google.com")
    );
    private final Provider apple = new Provider(
            "https://appleid.apple.com/auth/keys",
            List.of("https://appleid.apple.com")
    );

    public Provider getGoogle() {
        return google;
    }

    public Provider getApple() {
        return apple;
    }

    public static class Provider {
        private String jwkSetUri;
        private List<String> issuers;
        private List<String> clientIds = new ArrayList<>();

        public Provider() {
        }

        public Provider(String jwkSetUri, List<String> issuers) {
            this.jwkSetUri = jwkSetUri;
            this.issuers = new ArrayList<>(issuers);
        }

        public String getJwkSetUri() {
            return jwkSetUri;
        }

        public void setJwkSetUri(String jwkSetUri) {
            this.jwkSetUri = jwkSetUri;
        }

        public List<String> getIssuers() {
            return issuers;
        }

        public void setIssuers(List<String> issuers) {
            this.issuers = issuers;
        }

        public List<String> getClientIds() {
            return clientIds;
        }

        public void setClientIds(List<String> clientIds) {
            this.clientIds = clientIds;
        }
    }
}
