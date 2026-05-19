package com.platepilote.platepilote.billing.application.service;

import com.platepilote.platepilote.admin.application.service.AuditLogService;
import com.platepilote.platepilote.admin.domain.repository.SystemSettingRepository;
import com.platepilote.platepilote.authentication.domain.entity.OurUser;
import com.platepilote.platepilote.authentication.domain.repository.UserRepository;
import com.platepilote.platepilote.billing.application.config.BillingProperties;
import com.platepilote.platepilote.billing.application.service.BillingProviderModels.BillingCheckoutSession;
import com.platepilote.platepilote.billing.application.service.BillingProviderModels.BillingPortalSession;
import com.platepilote.platepilote.billing.application.service.BillingProviderModels.ProviderEvent;
import com.platepilote.platepilote.billing.domain.entity.BillingCustomer;
import com.platepilote.platepilote.billing.domain.entity.BillingEvent;
import com.platepilote.platepilote.billing.domain.repository.BillingCustomerRepository;
import com.platepilote.platepilote.billing.domain.repository.BillingEventRepository;
import com.platepilote.platepilote.subscription.application.service.EntitlementService;
import com.platepilote.platepilote.subscription.domain.entity.Subscription;
import com.platepilote.platepilote.subscription.domain.repository.SubscriptionRepository;
import com.platepilote.platepilote.subscription.domain.repository.UserEntitlementRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.Instant;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class BillingServiceTest {

    @Mock private BillingProvider billingProvider;
    @Mock private BillingCustomerRepository billingCustomerRepository;
    @Mock private BillingEventRepository billingEventRepository;
    @Mock private UserRepository userRepository;
    @Mock private SubscriptionRepository subscriptionRepository;
    @Mock private UserEntitlementRepository userEntitlementRepository;
    @Mock private EntitlementService entitlementService;
    @Mock private SystemSettingRepository systemSettingRepository;
    @Mock private AuditLogService auditLogService;

    private BillingService billingService;
    private BillingProperties properties;

    @BeforeEach
    void setUp() {
        properties = new BillingProperties();
        properties.getStripe().setMonthlyPriceId("price_monthly");
        properties.getStripe().setYearlyPriceId("price_yearly");
        properties.getStripe().setSuccessUrl("https://example.com/success");
        properties.getStripe().setCancelUrl("https://example.com/cancel");
        properties.getStripe().setPortalReturnUrl("https://example.com/portal");
        billingService = new BillingService(billingProvider, properties, billingCustomerRepository,
                billingEventRepository, userRepository, subscriptionRepository, userEntitlementRepository,
                entitlementService, systemSettingRepository, auditLogService);
    }

    @Test
    void checkoutSessionUsesYearlyPriceAndTrialForEligibleUser() {
        UUID userId = UUID.randomUUID();
        OurUser user = user(userId);
        when(userRepository.findById(userId)).thenReturn(Optional.of(user));
        when(billingCustomerRepository.findByProviderAndUserId("STRIPE", userId)).thenReturn(Optional.empty());
        when(billingProvider.createCustomer("user@example.com", "User One")).thenReturn("cus_123");
        when(billingCustomerRepository.save(any(BillingCustomer.class))).thenAnswer(invocation -> invocation.getArgument(0));
        when(userEntitlementRepository.findByUserIdAndEntitlementKey(userId, EntitlementService.PREMIUM_ENTITLEMENT))
                .thenReturn(Optional.empty());
        when(billingProvider.createCheckoutSession(eq("cus_123"), eq("price_yearly"), eq(30), any(), any(), eq(userId.toString())))
                .thenReturn(new BillingCheckoutSession("cs_123", "https://checkout"));

        var response = billingService.createCheckoutSession(userId, "YEARLY");

        assertThat(response.sessionId()).isEqualTo("cs_123");
        assertThat(response.checkoutUrl()).isEqualTo("https://checkout");
    }

    @Test
    void duplicateWebhookIsIgnored() {
        ProviderEvent event = new ProviderEvent("evt_1", "customer.subscription.updated",
                "cus_123", "sub_123", null, "active", "price_monthly",
                Instant.now().plusSeconds(3600), Map.of());
        when(billingProvider.verifyWebhook("{}", "sig")).thenReturn(event);
        when(billingEventRepository.findByProviderAndEventId("STRIPE", "evt_1"))
                .thenReturn(Optional.of(BillingEvent.builder().eventId("evt_1").provider("STRIPE").build()));

        billingService.processStripeWebhook("{}", "sig");

        verify(subscriptionRepository, never()).save(any());
        verify(entitlementService, never()).grantPremium(any(), any(), any());
    }

    @Test
    void activeSubscriptionWebhookGrantsPremium() {
        UUID userId = UUID.randomUUID();
        Instant periodEnd = Instant.now().plusSeconds(3600);
        ProviderEvent event = new ProviderEvent("evt_1", "customer.subscription.updated",
                "cus_123", "sub_123", "cs_123", "active", "price_monthly", periodEnd, Map.of());
        when(billingProvider.verifyWebhook("{}", "sig")).thenReturn(event);
        when(billingEventRepository.findByProviderAndEventId("STRIPE", "evt_1")).thenReturn(Optional.empty());
        when(billingEventRepository.save(any(BillingEvent.class))).thenAnswer(invocation -> invocation.getArgument(0));
        when(billingCustomerRepository.findByProviderAndProviderCustomerId("STRIPE", "cus_123"))
                .thenReturn(Optional.of(BillingCustomer.builder().userId(userId).providerCustomerId("cus_123").provider("STRIPE").build()));
        when(subscriptionRepository.findByProviderAndProviderSubscriptionId("STRIPE", "sub_123")).thenReturn(Optional.empty());
        when(subscriptionRepository.findByUserId(userId)).thenReturn(Optional.empty());
        when(subscriptionRepository.save(any(Subscription.class))).thenAnswer(invocation -> invocation.getArgument(0));

        billingService.processStripeWebhook("{}", "sig");

        verify(entitlementService).grantPremium(userId, "STRIPE", periodEnd);
    }

    private OurUser user(UUID id) {
        OurUser user = OurUser.builder()
                .email("user@example.com")
                .firstName("User")
                .lastName("One")
                .enabled(true)
                .build();
        user.setId(id);
        return user;
    }
}
