package com.platepilote.platepilote.billing.application.service;

import com.platepilote.platepilote.billing.application.service.BillingProviderModels.BillingCheckoutSession;
import com.platepilote.platepilote.billing.application.service.BillingProviderModels.BillingPortalSession;
import com.platepilote.platepilote.billing.application.service.BillingProviderModels.ProviderEvent;

public interface BillingProvider {

    String providerName();

    String createCustomer(String email, String name);

    BillingCheckoutSession createCheckoutSession(String customerId, String priceId, int trialDays,
                                                  String successUrl, String cancelUrl, String clientReferenceId);

    BillingPortalSession createPortalSession(String customerId, String returnUrl);

    ProviderEvent verifyWebhook(String rawPayload, String signatureHeader);
}
