package com.platepilote.platepilote.billing.presentation;

import com.platepilote.platepilote.billing.application.dto.BillingDtos.CheckoutSessionRequest;
import com.platepilote.platepilote.billing.application.dto.BillingDtos.CheckoutSessionResponse;
import com.platepilote.platepilote.billing.application.dto.BillingDtos.CustomerPortalResponse;
import com.platepilote.platepilote.billing.application.service.BillingService;
import com.platepilote.platepilote.common.dto.ApiResponse;
import com.platepilote.platepilote.common.security.SecurityUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.UUID;

@RestController
@RequestMapping("/api/v1/billing/stripe")
@RequiredArgsConstructor
public class BillingController {

    private final BillingService billingService;
    private final SecurityUtils securityUtils;

    @PostMapping("/checkout-session")
    public ResponseEntity<ApiResponse<CheckoutSessionResponse>> checkoutSession(
            @AuthenticationPrincipal UserDetails userDetails,
            @RequestBody CheckoutSessionRequest request) {
        UUID userId = securityUtils.getCurrentUserId(userDetails);
        return ResponseEntity.ok(ApiResponse.success("Checkout session created",
                billingService.createCheckoutSession(userId, request.plan())));
    }

    @PostMapping("/customer-portal")
    public ResponseEntity<ApiResponse<CustomerPortalResponse>> customerPortal(
            @AuthenticationPrincipal UserDetails userDetails) {
        UUID userId = securityUtils.getCurrentUserId(userDetails);
        return ResponseEntity.ok(ApiResponse.success("Customer portal created",
                billingService.createCustomerPortal(userId)));
    }

    @PostMapping("/webhook")
    public ResponseEntity<ApiResponse<Void>> webhook(
            @RequestBody String rawPayload,
            @RequestHeader(name = "Stripe-Signature", required = false) String signatureHeader) {
        billingService.processStripeWebhook(rawPayload, signatureHeader);
        return ResponseEntity.ok(ApiResponse.success("Webhook processed", null));
    }
}
