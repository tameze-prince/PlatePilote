package com.platepilote.platepilote.subscription.presentation;

import com.platepilote.platepilote.common.dto.ApiResponse;
import com.platepilote.platepilote.subscription.application.service.SubscriptionService;
import com.platepilote.platepilote.subscription.application.service.SubscriptionService.SubscriptionResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.UUID;

@RestController
@RequestMapping("/api/v1/subscription")
@RequiredArgsConstructor
public class SubscriptionController {

    private final SubscriptionService subscriptionService;

    @GetMapping
    public ResponseEntity<ApiResponse<SubscriptionResponse>> getSubscription(
            @AuthenticationPrincipal UserDetails userDetails) {
        UUID userId = UUID.fromString(userDetails.getUsername());
        SubscriptionResponse subscription = subscriptionService.getSubscription(userId);
        return ResponseEntity.ok(ApiResponse.success(subscription));
    }

    @PostMapping("/upgrade")
    public ResponseEntity<ApiResponse<SubscriptionResponse>> upgradeToPremium(
            @AuthenticationPrincipal UserDetails userDetails) {
        UUID userId = UUID.fromString(userDetails.getUsername());
        SubscriptionResponse subscription = subscriptionService.upgradeToPremium(userId);
        return ResponseEntity.ok(ApiResponse.success("Upgraded to Premium", subscription));
    }

    @PostMapping("/cancel")
    public ResponseEntity<ApiResponse<Void>> cancelSubscription(
            @AuthenticationPrincipal UserDetails userDetails) {
        UUID userId = UUID.fromString(userDetails.getUsername());
        subscriptionService.cancelSubscription(userId);
        return ResponseEntity.ok(ApiResponse.success("Subscription will be cancelled at period end", null));
    }
}
