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

/**
 * Service métier pour la gestion des abonnements utilisateur.
 */
@Service
@RequiredArgsConstructor
@Transactional
public class SubscriptionService {

    private final SubscriptionRepository subscriptionRepository;
    private final EntitlementService entitlementService;

    /**
     * Récupère l'abonnement d'un utilisateur.
     * Crée un abonnement FREE par défaut s'il n'en existe pas.
     *
     * @param userId identifiant de l'utilisateur
     * @return l'abonnement (existant ou FREE par défaut)
     */
    public SubscriptionResponse getSubscription(UUID userId) {
        return subscriptionRepository.findByUserId(userId)
                .map(this::toResponse)
                .orElseGet(() -> getOrCreateFreeSubscription(userId));
    }

    private SubscriptionResponse getOrCreateFreeSubscription(UUID userId) {
        Subscription subscription = Subscription.builder()
                .userId(userId)
                .planType("FREE")
                .status("ACTIVE")
                .startDate(Instant.now())
                .build();
        Subscription saved = subscriptionRepository.save(subscription);
        return toResponse(saved);
    }

    /**
     * Crée un abonnement FREE pour un utilisateur.
     *
     * @param userId identifiant de l'utilisateur
     * @return l'abonnement FREE créé
     * @throws BusinessRuleViolationException si l'utilisateur a déjà un abonnement
     */
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

    /**
     * Passe un abonnement au statut Premium (interne, 30 jours).
     *
     * @param userId identifiant de l'utilisateur
     * @return l'abonnement Premium créé
     */
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

    /**
     * Annule l'abonnement d'un utilisateur (fin de période).
     *
     * @param userId identifiant de l'utilisateur
     */
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

    /**
     * Réponse contenant les détails d'un abonnement.
     */
    public record SubscriptionResponse(
            /** Identifiant de l'abonnement. */
            UUID id,
            /** Type de plan (FREE, PREMIUM_MONTHLY, PREMIUM_YEARLY). */
            String planType,
            /** Statut (ACTIVE, CANCELLED, PAST_DUE, etc.). */
            String status,
            /** Date de début. */
            Instant startDate,
            /** Date de fin. */
            Instant endDate,
            /** Date de fin d'essai. */
            Instant trialEndDate,
            /** Annulation en fin de période. */
            Boolean cancelAtPeriodEnd,
            /** Fournisseur de paiement. */
            String provider,
            /** Date d'expiration. */
            Instant expiresAt,
            /** Dernière vérification. */
            Instant lastVerifiedAt,
            /** Date de création. */
            Instant createdAt
    ) {}
}
