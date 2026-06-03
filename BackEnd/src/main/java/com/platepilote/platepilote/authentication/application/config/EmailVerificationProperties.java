package com.platepilote.platepilote.authentication.application.config;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

/**
 * Propriétés de configuration pour la vérification des emails.
 * <p>
 * Les valeurs sont injectées depuis le fichier {@code application.yml}
 * via le préfixe {@code app.email.verification}.
 * </p>
 */
@Component
@ConfigurationProperties(prefix = "app.email.verification")
public class EmailVerificationProperties {

    /** Adresse expéditrice des emails. */
    private String from = "PlatePilote <no-reply@platepilote.com>";

    /** URL frontend de vérification d'email. */
    private String frontendUrl = "http://localhost:3000/verify-email";

    /** Durée de validité du token en heures. */
    private int expirationHours = 24;

    /** Lève une exception en cas d'échec d'envoi si {@code true}. */
    private boolean failOnSendError = false;

    /**
     * Retourne l'adresse expéditrice.
     * @return l'adresse expéditrice
     */
    public String getFrom() {
        return from;
    }

    /**
     * Définit l'adresse expéditrice.
     * @param from la nouvelle adresse expéditrice
     */
    public void setFrom(String from) {
        this.from = from;
    }

    /**
     * Retourne l'URL frontend de vérification.
     * @return l'URL de vérification
     */
    public String getFrontendUrl() {
        return frontendUrl;
    }

    /**
     * Définit l'URL frontend de vérification.
     * @param frontendUrl la nouvelle URL
     */
    public void setFrontendUrl(String frontendUrl) {
        this.frontendUrl = frontendUrl;
    }

    /**
     * Retourne la durée de validité du token en heures.
     * @return le nombre d'heures
     */
    public int getExpirationHours() {
        return expirationHours;
    }

    /**
     * Définit la durée de validité du token.
     * @param expirationHours le nombre d'heures
     */
    public void setExpirationHours(int expirationHours) {
        this.expirationHours = expirationHours;
    }

    /**
     * Indique s'il faut lever une exception en cas d'échec d'envoi.
     * @return {@code true} si une exception doit être levée
     */
    public boolean isFailOnSendError() {
        return failOnSendError;
    }

    /**
     * Définit le comportement en cas d'échec d'envoi.
     * @param failOnSendError {@code true} pour lever une exception
     */
    public void setFailOnSendError(boolean failOnSendError) {
        this.failOnSendError = failOnSendError;
    }
}
