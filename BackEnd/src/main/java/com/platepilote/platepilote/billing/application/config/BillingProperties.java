package com.platepilote.platepilote.billing.application.config;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

/**
 * Propriétés de configuration pour la facturation (Stripe).
 * Préfixe : {@code app.billing}.
 */
@Component
@ConfigurationProperties(prefix = "app.billing")
public class BillingProperties {

    /** Configuration Stripe. */
    private final Stripe stripe = new Stripe();
    /** Nombre de jours d'essai gratuit. */
    private int freeTrialDays = 30;
    /** Nombre de jours de grâce après impayé. */
    private int pastDueGraceDays = 3;

    /**
     * @return la configuration Stripe
     */
    public Stripe getStripe() {
        return stripe;
    }

    /**
     * @return nombre de jours d'essai gratuit
     */
    public int getFreeTrialDays() {
        return freeTrialDays;
    }

    /**
     * Définit le nombre de jours d'essai gratuit.
     * @param freeTrialDays jours d'essai
     */
    public void setFreeTrialDays(int freeTrialDays) {
        this.freeTrialDays = freeTrialDays;
    }

    /**
     * @return nombre de jours de grâce après impayé
     */
    public int getPastDueGraceDays() {
        return pastDueGraceDays;
    }

    /**
     * Définit le nombre de jours de grâce après impayé.
     * @param pastDueGraceDays jours de grâce
     */
    public void setPastDueGraceDays(int pastDueGraceDays) {
        this.pastDueGraceDays = pastDueGraceDays;
    }

    /**
     * Configuration spécifique à Stripe.
     */
    public static class Stripe {
        /** Clé secrète Stripe. */
        private String secretKey = "";
        /** Secret du webhook Stripe. */
        private String webhookSecret = "";
        /** ID du prix mensuel Stripe. */
        private String monthlyPriceId = "";
        /** ID du prix annuel Stripe. */
        private String yearlyPriceId = "";
        /** URL de redirection après succès du paiement. */
        private String successUrl = "";
        /** URL de redirection après annulation du paiement. */
        private String cancelUrl = "";
        /** URL de retour du portail client. */
        private String portalReturnUrl = "";

        /**
         * @return clé secrète Stripe
         */
        public String getSecretKey() {
            return secretKey;
        }

        /**
         * Définit la clé secrète Stripe.
         * @param secretKey clé secrète
         */
        public void setSecretKey(String secretKey) {
            this.secretKey = secretKey;
        }

        /**
         * @return secret du webhook Stripe
         */
        public String getWebhookSecret() {
            return webhookSecret;
        }

        /**
         * Définit le secret du webhook Stripe.
         * @param webhookSecret secret du webhook
         */
        public void setWebhookSecret(String webhookSecret) {
            this.webhookSecret = webhookSecret;
        }

        /**
         * @return ID du prix mensuel Stripe
         */
        public String getMonthlyPriceId() {
            return monthlyPriceId;
        }

        /**
         * Définit l'ID du prix mensuel Stripe.
         * @param monthlyPriceId ID du prix mensuel
         */
        public void setMonthlyPriceId(String monthlyPriceId) {
            this.monthlyPriceId = monthlyPriceId;
        }

        /**
         * @return ID du prix annuel Stripe
         */
        public String getYearlyPriceId() {
            return yearlyPriceId;
        }

        /**
         * Définit l'ID du prix annuel Stripe.
         * @param yearlyPriceId ID du prix annuel
         */
        public void setYearlyPriceId(String yearlyPriceId) {
            this.yearlyPriceId = yearlyPriceId;
        }

        /**
         * @return URL de succès Stripe
         */
        public String getSuccessUrl() {
            return successUrl;
        }

        /**
         * Définit l'URL de succès Stripe.
         * @param successUrl URL de succès
         */
        public void setSuccessUrl(String successUrl) {
            this.successUrl = successUrl;
        }

        /**
         * @return URL d'annulation Stripe
         */
        public String getCancelUrl() {
            return cancelUrl;
        }

        /**
         * Définit l'URL d'annulation Stripe.
         * @param cancelUrl URL d'annulation
         */
        public void setCancelUrl(String cancelUrl) {
            this.cancelUrl = cancelUrl;
        }

        /**
         * @return URL de retour du portail client
         */
        public String getPortalReturnUrl() {
            return portalReturnUrl;
        }

        /**
         * Définit l'URL de retour du portail client.
         * @param portalReturnUrl URL de retour
         */
        public void setPortalReturnUrl(String portalReturnUrl) {
            this.portalReturnUrl = portalReturnUrl;
        }
    }
}
