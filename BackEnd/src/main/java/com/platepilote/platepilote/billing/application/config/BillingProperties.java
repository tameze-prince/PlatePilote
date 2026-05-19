package com.platepilote.platepilote.billing.application.config;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

@Component
@ConfigurationProperties(prefix = "app.billing")
public class BillingProperties {

    private final Stripe stripe = new Stripe();
    private int freeTrialDays = 30;
    private int pastDueGraceDays = 3;

    public Stripe getStripe() {
        return stripe;
    }

    public int getFreeTrialDays() {
        return freeTrialDays;
    }

    public void setFreeTrialDays(int freeTrialDays) {
        this.freeTrialDays = freeTrialDays;
    }

    public int getPastDueGraceDays() {
        return pastDueGraceDays;
    }

    public void setPastDueGraceDays(int pastDueGraceDays) {
        this.pastDueGraceDays = pastDueGraceDays;
    }

    public static class Stripe {
        private String secretKey = "";
        private String webhookSecret = "";
        private String monthlyPriceId = "";
        private String yearlyPriceId = "";
        private String successUrl = "";
        private String cancelUrl = "";
        private String portalReturnUrl = "";

        public String getSecretKey() {
            return secretKey;
        }

        public void setSecretKey(String secretKey) {
            this.secretKey = secretKey;
        }

        public String getWebhookSecret() {
            return webhookSecret;
        }

        public void setWebhookSecret(String webhookSecret) {
            this.webhookSecret = webhookSecret;
        }

        public String getMonthlyPriceId() {
            return monthlyPriceId;
        }

        public void setMonthlyPriceId(String monthlyPriceId) {
            this.monthlyPriceId = monthlyPriceId;
        }

        public String getYearlyPriceId() {
            return yearlyPriceId;
        }

        public void setYearlyPriceId(String yearlyPriceId) {
            this.yearlyPriceId = yearlyPriceId;
        }

        public String getSuccessUrl() {
            return successUrl;
        }

        public void setSuccessUrl(String successUrl) {
            this.successUrl = successUrl;
        }

        public String getCancelUrl() {
            return cancelUrl;
        }

        public void setCancelUrl(String cancelUrl) {
            this.cancelUrl = cancelUrl;
        }

        public String getPortalReturnUrl() {
            return portalReturnUrl;
        }

        public void setPortalReturnUrl(String portalReturnUrl) {
            this.portalReturnUrl = portalReturnUrl;
        }
    }
}
