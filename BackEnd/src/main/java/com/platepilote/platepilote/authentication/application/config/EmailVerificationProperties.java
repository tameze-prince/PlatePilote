package com.platepilote.platepilote.authentication.application.config;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

@Component
@ConfigurationProperties(prefix = "app.email.verification")
public class EmailVerificationProperties {

    private String from = "PlatePilote <no-reply@platepilote.com>";
    private String frontendUrl = "http://localhost:3000/verify-email";
    private int expirationHours = 24;
    private boolean failOnSendError = false;

    public String getFrom() {
        return from;
    }

    public void setFrom(String from) {
        this.from = from;
    }

    public String getFrontendUrl() {
        return frontendUrl;
    }

    public void setFrontendUrl(String frontendUrl) {
        this.frontendUrl = frontendUrl;
    }

    public int getExpirationHours() {
        return expirationHours;
    }

    public void setExpirationHours(int expirationHours) {
        this.expirationHours = expirationHours;
    }

    public boolean isFailOnSendError() {
        return failOnSendError;
    }

    public void setFailOnSendError(boolean failOnSendError) {
        this.failOnSendError = failOnSendError;
    }
}
