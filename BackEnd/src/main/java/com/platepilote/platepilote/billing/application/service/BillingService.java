package com.platepilote.platepilote.billing.application.service;

import com.platepilote.platepilote.admin.application.service.AuditLogService;
import com.platepilote.platepilote.admin.domain.entity.SystemSetting;
import com.platepilote.platepilote.admin.domain.repository.SystemSettingRepository;
import com.platepilote.platepilote.authentication.domain.entity.OurUser;
import com.platepilote.platepilote.authentication.domain.repository.UserRepository;
import com.platepilote.platepilote.billing.application.config.BillingProperties;
import com.platepilote.platepilote.billing.application.dto.BillingDtos.CheckoutSessionResponse;
import com.platepilote.platepilote.billing.application.dto.BillingDtos.CustomerPortalResponse;
import com.platepilote.platepilote.billing.application.service.BillingProviderModels.ProviderEvent;
import com.platepilote.platepilote.billing.domain.entity.BillingCustomer;
import com.platepilote.platepilote.billing.domain.entity.BillingEvent;
import com.platepilote.platepilote.billing.domain.repository.BillingCustomerRepository;
import com.platepilote.platepilote.billing.domain.repository.BillingEventRepository;
import com.platepilote.platepilote.common.kernel.BusinessRuleViolationException;
import com.platepilote.platepilote.common.kernel.ResourceNotFoundException;
import com.platepilote.platepilote.subscription.application.service.EntitlementService;
import com.platepilote.platepilote.subscription.domain.entity.Subscription;
import com.platepilote.platepilote.subscription.domain.repository.SubscriptionRepository;
import com.platepilote.platepilote.subscription.domain.repository.UserEntitlementRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.Map;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Transactional
public class BillingService {

    private static final String STRIPE = "STRIPE";

    private final BillingProvider billingProvider;
    private final BillingProperties billingProperties;
    private final BillingCustomerRepository billingCustomerRepository;
    private final BillingEventRepository billingEventRepository;
    private final UserRepository userRepository;
    private final SubscriptionRepository subscriptionRepository;
    private final UserEntitlementRepository userEntitlementRepository;
    private final EntitlementService entitlementService;
    private final SystemSettingRepository systemSettingRepository;
    private final AuditLogService auditLogService;

    public CheckoutSessionResponse createCheckoutSession(UUID userId, String plan) {
        OurUser user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User", "id", userId.toString()));
        BillingCustomer customer = getOrCreateStripeCustomer(user);
        String normalizedPlan = normalizePlan(plan);
        String priceId = "YEARLY".equals(normalizedPlan)
                ? billingProperties.getStripe().getYearlyPriceId()
                : billingProperties.getStripe().getMonthlyPriceId();
        int trialDays = trialEligible(userId) ? settingInt("billing_free_trial_days", billingProperties.getFreeTrialDays()) : 0;

        var session = billingProvider.createCheckoutSession(
                customer.getProviderCustomerId(),
                priceId,
                trialDays,
                billingProperties.getStripe().getSuccessUrl(),
                billingProperties.getStripe().getCancelUrl(),
                userId.toString());
        String auditEntityId = customer.getId() == null ? customer.getProviderCustomerId() : customer.getId().toString();
        auditLogService.log(userId, user.getEmail(), "STRIPE_CHECKOUT_SESSION_CREATED", "BillingCustomer",
                auditEntityId, Map.of("plan", normalizedPlan, "trialDays", trialDays));
        return new CheckoutSessionResponse(session.url(), session.id());
    }

    public CustomerPortalResponse createCustomerPortal(UUID userId) {
        OurUser user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User", "id", userId.toString()));
        BillingCustomer customer = getOrCreateStripeCustomer(user);
        var session = billingProvider.createPortalSession(
                customer.getProviderCustomerId(),
                billingProperties.getStripe().getPortalReturnUrl());
        return new CustomerPortalResponse(session.url());
    }

    public void processStripeWebhook(String rawPayload, String signatureHeader) {
        ProviderEvent event = billingProvider.verifyWebhook(rawPayload, signatureHeader);
        if (billingEventRepository.findByProviderAndEventId(STRIPE, event.id()).isPresent()) {
            return;
        }
        BillingEvent billingEvent = billingEventRepository.save(BillingEvent.builder()
                .provider(STRIPE)
                .eventId(event.id())
                .eventType(event.type())
                .rawPayload(rawPayload)
                .processed(false)
                .build());
        try {
            applyProviderEvent(event);
            billingEvent.setProcessed(true);
            billingEvent.setProcessedAt(Instant.now());
        } catch (Exception ex) {
            billingEvent.setErrorMessage(ex.getMessage());
            throw ex;
        } finally {
            billingEventRepository.save(billingEvent);
        }
    }

    private BillingCustomer getOrCreateStripeCustomer(OurUser user) {
        return billingCustomerRepository.findByProviderAndUserId(STRIPE, user.getId())
                .orElseGet(() -> {
                    String customerId = billingProvider.createCustomer(user.getEmail(),
                            (user.getFirstName() + " " + user.getLastName()).trim());
                    return billingCustomerRepository.save(BillingCustomer.builder()
                            .userId(user.getId())
                            .provider(STRIPE)
                            .providerCustomerId(customerId)
                            .email(user.getEmail())
                            .build());
                });
    }

    private void applyProviderEvent(ProviderEvent event) {
        if (event.customerId() == null) {
            return;
        }
        BillingCustomer customer = billingCustomerRepository
                .findByProviderAndProviderCustomerId(STRIPE, event.customerId())
                .orElse(null);
        if (customer == null) {
            return;
        }
        if (event.subscriptionId() == null) {
            return;
        }
        Subscription subscription = subscriptionRepository
                .findByProviderAndProviderSubscriptionId(STRIPE, event.subscriptionId())
                .orElseGet(() -> subscriptionRepository.findByUserId(customer.getUserId())
                        .orElseGet(() -> Subscription.builder()
                                .userId(customer.getUserId())
                                .startDate(Instant.now())
                                .build()));

        String status = normalizeStripeStatus(event.status());
        subscription.setProvider(STRIPE);
        subscription.setProviderSubscriptionId(event.subscriptionId());
        subscription.setPurchaseToken(event.checkoutSessionId());
        subscription.setPlanType(planForPrice(event.priceId()));
        subscription.setStatus(status);
        subscription.setExpiresAt(event.currentPeriodEnd());
        subscription.setEndDate(event.currentPeriodEnd());
        subscription.setLastVerifiedAt(Instant.now());
        subscriptionRepository.save(subscription);

        if (premiumActive(status, event.currentPeriodEnd())) {
            entitlementService.grantPremium(customer.getUserId(), STRIPE, event.currentPeriodEnd());
            auditLogService.log(customer.getUserId(), null, "PREMIUM_ENTITLEMENT_GRANTED", "Subscription",
                    event.subscriptionId(), Map.of("provider", STRIPE, "status", status));
        } else {
            entitlementService.revokePremium(customer.getUserId());
            auditLogService.log(customer.getUserId(), null, "PREMIUM_ENTITLEMENT_REVOKED", "Subscription",
                    event.subscriptionId(), Map.of("provider", STRIPE, "status", status));
        }
    }

    private boolean trialEligible(UUID userId) {
        return userEntitlementRepository.findByUserIdAndEntitlementKey(userId, EntitlementService.PREMIUM_ENTITLEMENT)
                .isEmpty();
    }

    private String normalizePlan(String plan) {
        if (plan == null || plan.isBlank()) {
            return "MONTHLY";
        }
        String normalized = plan.trim().toUpperCase();
        if (!normalized.equals("MONTHLY") && !normalized.equals("YEARLY")) {
            throw new BusinessRuleViolationException("Unsupported billing plan: " + plan);
        }
        return normalized;
    }

    private String planForPrice(String priceId) {
        if (priceId != null && priceId.equals(billingProperties.getStripe().getYearlyPriceId())) {
            return "PREMIUM_YEARLY";
        }
        return "PREMIUM_MONTHLY";
    }

    private String normalizeStripeStatus(String status) {
        if (status == null) {
            return "UNKNOWN";
        }
        return switch (status.toLowerCase()) {
            case "active" -> "ACTIVE";
            case "trialing" -> "TRIALING";
            case "past_due" -> "PAST_DUE";
            case "canceled", "cancelled" -> "CANCELLED";
            case "unpaid" -> "UNPAID";
            default -> status.toUpperCase();
        };
    }

    private boolean premiumActive(String status, Instant expiresAt) {
        if ("ACTIVE".equals(status) || "TRIALING".equals(status)) {
            return expiresAt == null || expiresAt.isAfter(Instant.now());
        }
        if ("PAST_DUE".equals(status) && expiresAt != null) {
            int graceDays = settingInt("billing_past_due_grace_days", billingProperties.getPastDueGraceDays());
            return expiresAt.plusSeconds(graceDays * 24L * 60L * 60L).isAfter(Instant.now());
        }
        return false;
    }

    private int settingInt(String key, int fallback) {
        return systemSettingRepository.findBySettingKey(key)
                .map(SystemSetting::getSettingValue)
                .map(value -> {
                    try {
                        return Integer.parseInt(value);
                    } catch (NumberFormatException ex) {
                        return fallback;
                    }
                })
                .orElse(fallback);
    }
}
