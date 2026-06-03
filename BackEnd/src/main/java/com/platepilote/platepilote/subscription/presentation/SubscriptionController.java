package com.platepilote.platepilote.subscription.presentation;

import com.platepilote.platepilote.common.dto.ApiResponse;
import com.platepilote.platepilote.common.security.SecurityUtils;
import com.platepilote.platepilote.subscription.application.service.SubscriptionService;
import com.platepilote.platepilote.subscription.application.service.SubscriptionService.SubscriptionResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.UUID;

/**
 * Contrôleur REST exposant les endpoints de gestion des abonnements.
 */
@RestController
@RequestMapping("/api/v1/subscription")
@RequiredArgsConstructor
public class SubscriptionController {

    private final SubscriptionService subscriptionService;

    private final SecurityUtils securityUtils;

    /**
     * Récupère l'abonnement de l'utilisateur connecté.
     *
     * @param userDetails utilisateur authentifié
     * @return l'abonnement
     */
    @GetMapping
    public ResponseEntity<ApiResponse<SubscriptionResponse>> getSubscription(
            @AuthenticationPrincipal UserDetails userDetails) {
        UUID userId = securityUtils.getCurrentUserId(userDetails);
        SubscriptionResponse subscription = subscriptionService.getSubscription(userId);
        return ResponseEntity.ok(ApiResponse.success(subscription));
    }

    /**
     * Passe l'utilisateur connecté au statut Premium (réservé ADMIN/SUPER_ADMIN).
     *
     * @param userDetails utilisateur authentifié
     * @return abonnement Premium
     */
    @PostMapping("/upgrade")
    @PreAuthorize("hasAnyRole('ADMIN','SUPER_ADMIN')")
    public ResponseEntity<ApiResponse<SubscriptionResponse>> upgradeToPremium(
            @AuthenticationPrincipal UserDetails userDetails) {
        UUID userId = securityUtils.getCurrentUserId(userDetails);
        SubscriptionResponse subscription = subscriptionService.upgradeToPremium(userId);
        return ResponseEntity.ok(ApiResponse.success("Upgraded to Premium", subscription));
    }

    /**
     * Annule l'abonnement de l'utilisateur connecté (fin de période).
     *
     * @param userDetails utilisateur authentifié
     * @return confirmation
     */
    @PostMapping("/cancel")
    public ResponseEntity<ApiResponse<Void>> cancelSubscription(
            @AuthenticationPrincipal UserDetails userDetails) {
        UUID userId = securityUtils.getCurrentUserId(userDetails);
        subscriptionService.cancelSubscription(userId);
        return ResponseEntity.ok(ApiResponse.success("Subscription will be cancelled at period end", null));
    }
}
