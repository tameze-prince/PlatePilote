package com.platepilote.platepilote.billing.application.service;

import java.time.Instant;
import java.util.Map;

public final class BillingProviderModels {

    private BillingProviderModels() {
    }

    public record BillingCheckoutSession(String id, String url) {}

    public record BillingPortalSession(String id, String url) {}

    public record ProviderEvent(
            String id,
            String type,
            String customerId,
            String subscriptionId,
            String checkoutSessionId,
            String status,
            String priceId,
            Instant currentPeriodEnd,
            Map<String, String> metadata
    ) {}
}
