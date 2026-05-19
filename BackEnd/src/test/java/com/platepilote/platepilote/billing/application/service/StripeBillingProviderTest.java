package com.platepilote.platepilote.billing.application.service;

import com.platepilote.platepilote.billing.application.config.BillingProperties;
import com.platepilote.platepilote.common.kernel.BusinessRuleViolationException;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.nio.charset.StandardCharsets;
import java.time.Instant;
import java.util.HexFormat;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

class StripeBillingProviderTest {

    private static final String SECRET = "whsec_test_secret";

    private StripeBillingProvider provider;

    @BeforeEach
    void setUp() {
        BillingProperties properties = new BillingProperties();
        properties.getStripe().setWebhookSecret(SECRET);
        provider = new StripeBillingProvider(properties);
    }

    @Test
    void verifyWebhookParsesSubscriptionEventAfterSignatureVerification() {
        String payload = """
                {
                  "id": "evt_123",
                  "object": "event",
                  "api_version": "2025-03-31.basil",
                  "livemode": false,
                  "type": "customer.subscription.updated",
                  "data": {
                    "object": {
                      "id": "sub_123",
                      "object": "subscription",
                      "customer": "cus_123",
                      "status": "active",
                      "items": {
                        "object": "list",
                        "data": [
                          {
                            "id": "si_123",
                            "object": "subscription_item",
                            "current_period_end": 1893456000,
                            "price": {
                              "id": "price_monthly",
                              "object": "price"
                            }
                          }
                        ]
                      }
                    }
                  }
                }
                """;

        BillingProviderModels.ProviderEvent event = provider.verifyWebhook(payload, signature(payload));

        assertThat(event.id()).isEqualTo("evt_123");
        assertThat(event.customerId()).isEqualTo("cus_123");
        assertThat(event.subscriptionId()).isEqualTo("sub_123");
        assertThat(event.status()).isEqualTo("active");
        assertThat(event.priceId()).isEqualTo("price_monthly");
        assertThat(event.currentPeriodEnd()).isEqualTo(Instant.ofEpochSecond(1893456000));
    }

    @Test
    void verifyWebhookRejectsBadSignature() {
        assertThatThrownBy(() -> provider.verifyWebhook("{}", "t=1,v1=bad"))
                .isInstanceOf(BusinessRuleViolationException.class)
                .hasMessageContaining("Invalid Stripe webhook signature");
    }

    private static String signature(String payload) {
        long timestamp = Instant.now().getEpochSecond();
        String signedPayload = timestamp + "." + payload;
        try {
            Mac mac = Mac.getInstance("HmacSHA256");
            mac.init(new SecretKeySpec(SECRET.getBytes(StandardCharsets.UTF_8), "HmacSHA256"));
            String digest = HexFormat.of().formatHex(mac.doFinal(signedPayload.getBytes(StandardCharsets.UTF_8)));
            return "t=" + timestamp + ",v1=" + digest;
        } catch (Exception ex) {
            throw new IllegalStateException(ex);
        }
    }
}
