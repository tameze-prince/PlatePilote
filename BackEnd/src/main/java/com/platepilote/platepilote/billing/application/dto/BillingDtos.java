package com.platepilote.platepilote.billing.application.dto;

public final class BillingDtos {

    private BillingDtos() {
    }

    public record CheckoutSessionRequest(String plan) {}

    public record CheckoutSessionResponse(String checkoutUrl, String sessionId) {}

    public record CustomerPortalResponse(String portalUrl) {}
}
