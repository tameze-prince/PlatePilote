package com.platepilote.platepilote.billing.application.service;

import com.platepilote.platepilote.billing.application.config.BillingProperties;
import com.platepilote.platepilote.billing.application.service.BillingProviderModels.BillingCheckoutSession;
import com.platepilote.platepilote.billing.application.service.BillingProviderModels.BillingPortalSession;
import com.platepilote.platepilote.billing.application.service.BillingProviderModels.ProviderEvent;
import com.platepilote.platepilote.common.kernel.BusinessRuleViolationException;
import com.stripe.Stripe;
import com.stripe.exception.EventDataObjectDeserializationException;
import com.stripe.exception.SignatureVerificationException;
import com.stripe.exception.StripeException;
import com.stripe.model.Event;
import com.stripe.model.StripeObject;
import com.stripe.model.Subscription;
import com.stripe.model.SubscriptionItem;
import com.stripe.model.checkout.Session;
import com.stripe.net.Webhook;
import com.stripe.param.CustomerCreateParams;
import com.stripe.param.checkout.SessionCreateParams;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.util.HashMap;
import java.util.Map;

@Service
public class StripeBillingProvider implements BillingProvider {

    private final BillingProperties properties;

    public StripeBillingProvider(BillingProperties properties) {
        this.properties = properties;
    }

    @Override
    public String providerName() {
        return "STRIPE";
    }

    @Override
    public String createCustomer(String email, String name) {
        requireConfigured(properties.getStripe().getSecretKey(), "STRIPE_SECRET_KEY");
        Stripe.apiKey = properties.getStripe().getSecretKey();
        try {
            var params = CustomerCreateParams.builder()
                    .setEmail(email)
                    .setName(name)
                    .build();
            return com.stripe.model.Customer.create(params).getId();
        } catch (StripeException ex) {
            throw new BusinessRuleViolationException("Unable to create Stripe customer: " + ex.getMessage());
        }
    }

    @Override
    public BillingCheckoutSession createCheckoutSession(String customerId, String priceId, int trialDays,
                                                        String successUrl, String cancelUrl, String clientReferenceId) {
        requireConfigured(properties.getStripe().getSecretKey(), "STRIPE_SECRET_KEY");
        requireConfigured(priceId, "Stripe price id");
        Stripe.apiKey = properties.getStripe().getSecretKey();
        try {
            var subscriptionData = SessionCreateParams.SubscriptionData.builder();
            if (trialDays > 0) {
                subscriptionData.setTrialPeriodDays((long) trialDays);
            }
            SessionCreateParams params = SessionCreateParams.builder()
                    .setMode(SessionCreateParams.Mode.SUBSCRIPTION)
                    .setCustomer(customerId)
                    .setClientReferenceId(clientReferenceId)
                    .setSuccessUrl(successUrl)
                    .setCancelUrl(cancelUrl)
                    .addLineItem(SessionCreateParams.LineItem.builder()
                            .setPrice(priceId)
                            .setQuantity(1L)
                            .build())
                    .setSubscriptionData(subscriptionData.build())
                    .build();
            Session session = Session.create(params);
            return new BillingCheckoutSession(session.getId(), session.getUrl());
        } catch (StripeException ex) {
            throw new BusinessRuleViolationException("Unable to create Stripe checkout session: " + ex.getMessage());
        }
    }

    @Override
    public BillingPortalSession createPortalSession(String customerId, String returnUrl) {
        requireConfigured(properties.getStripe().getSecretKey(), "STRIPE_SECRET_KEY");
        Stripe.apiKey = properties.getStripe().getSecretKey();
        try {
            var params = com.stripe.param.billingportal.SessionCreateParams.builder()
                    .setCustomer(customerId)
                    .setReturnUrl(returnUrl)
                    .build();
            com.stripe.model.billingportal.Session session = com.stripe.model.billingportal.Session.create(params);
            return new BillingPortalSession(session.getId(), session.getUrl());
        } catch (StripeException ex) {
            throw new BusinessRuleViolationException("Unable to create Stripe customer portal: " + ex.getMessage());
        }
    }

    @Override
    public ProviderEvent verifyWebhook(String rawPayload, String signatureHeader) {
        requireConfigured(properties.getStripe().getWebhookSecret(), "STRIPE_WEBHOOK_SECRET");
        Event event;
        try {
            event = Webhook.constructEvent(rawPayload, signatureHeader, properties.getStripe().getWebhookSecret());
        } catch (SignatureVerificationException ex) {
            throw new BusinessRuleViolationException("Invalid Stripe webhook signature");
        }
        StripeObject object = event.getDataObjectDeserializer().getObject()
                .orElseGet(() -> deserializeUnsafe(event));
        return providerEvent(event, object);
    }

    private StripeObject deserializeUnsafe(Event event) {
        try {
            return event.getDataObjectDeserializer().deserializeUnsafe();
        } catch (EventDataObjectDeserializationException ex) {
            throw new BusinessRuleViolationException("Unable to deserialize Stripe webhook payload");
        }
    }

    private ProviderEvent providerEvent(Event event, StripeObject object) {
        Map<String, String> metadata = new HashMap<>();
        metadata.put("rawEventType", event.getType());

        if (object instanceof Subscription subscription) {
            SubscriptionItem item = firstSubscriptionItem(subscription);
            String priceId = item == null || item.getPrice() == null ? null : item.getPrice().getId();
            Instant currentPeriodEnd = item == null ? null : epochSeconds(item.getCurrentPeriodEnd());
            return new ProviderEvent(event.getId(), event.getType(), subscription.getCustomer(), subscription.getId(),
                    null, subscription.getStatus(), priceId, currentPeriodEnd, metadata);
        }

        if (object instanceof Session session) {
            Subscription subscription = session.getSubscriptionObject();
            SubscriptionItem item = subscription == null ? null : firstSubscriptionItem(subscription);
            String priceId = item == null || item.getPrice() == null ? null : item.getPrice().getId();
            Instant currentPeriodEnd = item == null ? null : epochSeconds(item.getCurrentPeriodEnd());
            String status = subscription == null ? session.getStatus() : subscription.getStatus();
            return new ProviderEvent(event.getId(), event.getType(), session.getCustomer(), session.getSubscription(),
                    session.getId(), status, priceId, currentPeriodEnd, metadata);
        }

        return new ProviderEvent(event.getId(), event.getType(), null, null, null, null, null, null, metadata);
    }

    private SubscriptionItem firstSubscriptionItem(Subscription subscription) {
        if (subscription.getItems() == null || subscription.getItems().getData() == null
                || subscription.getItems().getData().isEmpty()) {
            return null;
        }
        return subscription.getItems().getData().getFirst();
    }

    private Instant epochSeconds(Long value) {
        return value == null ? null : Instant.ofEpochSecond(value);
    }

    private void requireConfigured(String value, String name) {
        if (value == null || value.isBlank()) {
            throw new BusinessRuleViolationException(name + " is not configured");
        }
    }
}
