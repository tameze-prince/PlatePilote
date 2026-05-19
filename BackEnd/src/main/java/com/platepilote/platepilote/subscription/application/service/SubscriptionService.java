package com.platepilote.platepilote.subscription.application.service;

import com.platepilote.platepilote.common.kernel.BusinessRuleViolationException;
import com.platepilote.platepilote.common.kernel.ResourceNotFoundException;
import com.platepilote.platepilote.subscription.domain.entity.Subscription;
import com.platepilote.platepilote.subscription.domain.repository.SubscriptionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Transactional
public class SubscriptionService {

    private final SubscriptionRepository subscriptionRepository;
    private final EntitlementService entitlementService;

    @Transactional(readOnly = true)
    public SubscriptionResponse getSubscription(UUID userId) {
        Subscription subscription = subscriptionRepository.findByUserId(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Subscription", "userId", userId.toString()));

        return toResponse(subscription);
    }

    public SubscriptionResponse createFreeSubscription(UUID userId) {
        if (subscriptionRepository.existsByUserId(userId)) {
            throw new BusinessRuleViolationException("User already has a subscription");
        }

        Subscription subscription = Subscription.builder()
                .userId(userId)
                .planType("FREE")
                .status("ACTIVE")
                .startDate(Instant.now())
                .build();

        Subscription saved = subscriptionRepository.save(subscription);
        return toResponse(saved);
    }

    public SubscriptionResponse upgradeToPremium(UUID userId) {
        Subscription subscription = subscriptionRepository.findByUserId(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Subscription", "userId", userId.toString()));

        subscription.setPlanType("PREMIUM");
        subscription.setStartDate(Instant.now());
        Instant expiresAt = Instant.now().plusSeconds(30L * 24 * 60 * 60);
        subscription.setEndDate(expiresAt); // 30 days
        subscription.setExpiresAt(expiresAt);
        subscription.setProvider("INTERNAL");
        subscription.setLastVerifiedAt(Instant.now());
        subscription.setCancelAtPeriodEnd(false);
        entitlementService.grantPremium(userId, "INTERNAL", expiresAt);

        Subscription saved = subscriptionRepository.save(subscription);
        return toResponse(saved);
    }

    public void cancelSubscription(UUID userId) {
        Subscription subscription = subscriptionRepository.findByUserId(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Subscription", "userId", userId.toString()));

        subscription.setCancelAtPeriodEnd(true);
        subscriptionRepository.save(subscription);
        entitlementService.revokePremium(userId);
    }

    private SubscriptionResponse toResponse(Subscription subscription) {
        return new SubscriptionResponse(
                subscription.getId(),
                subscription.getPlanType(),
                subscription.getStatus(),
                subscription.getStartDate(),
                subscription.getEndDate(),
                subscription.getTrialEndDate(),
                subscription.getCancelAtPeriodEnd(),
                subscription.getProvider(),
                subscription.getExpiresAt(),
                subscription.getLastVerifiedAt(),
                subscription.getCreatedAt()
        );
    }

    public record SubscriptionResponse(
            UUID id,
            String planType,
            String status,
            Instant startDate,
            Instant endDate,
            Instant trialEndDate,
            Boolean cancelAtPeriodEnd,
            String provider,
            Instant expiresAt,
            Instant lastVerifiedAt,
            Instant createdAt
    ) {}
}
