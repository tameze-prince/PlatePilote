package com.platepilote.platepilote.subscription.domain.entity;

import com.platepilote.platepilote.common.kernel.BaseEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.Instant;
import java.util.UUID;

/**
 * Entité représentant l'abonnement d'un utilisateur.
 * Table en base : {@code subscriptions}.
 */
@Entity
@Table(name = "subscriptions")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Subscription extends BaseEntity {

    /** Identifiant de l'utilisateur (unique). */
    @Column(name = "user_id", nullable = false, unique = true)
    private UUID userId;

    /** Type de plan (FREE, PREMIUM_MONTHLY, PREMIUM_YEARLY). */
    @Column(name = "plan_type", nullable = false)
    private String planType = "FREE";

    /** Statut (ACTIVE, CANCELLED, PAST_DUE, etc.). */
    @Column(nullable = false)
    private String status = "ACTIVE";

    /** Date de début de l'abonnement. */
    @Column(name = "start_date", nullable = false)
    private Instant startDate;

    /** Date de fin. */
    @Column(name = "end_date")
    private Instant endDate;

    /** Date de fin de la période d'essai. */
    @Column(name = "trial_end_date")
    private Instant trialEndDate;

    /** Annulation en fin de période. */
    @Column(name = "cancel_at_period_end")
    private Boolean cancelAtPeriodEnd = false;

    /** Fournisseur de paiement (STRIPE, INTERNAL). */
    @Column(name = "provider")
    private String provider = "INTERNAL";

    /** Identifiant de l'abonnement chez le fournisseur. */
    @Column(name = "provider_subscription_id")
    private String providerSubscriptionId;

    /** Token d'achat (reçu de validation). */
    @Column(name = "purchase_token", length = 1000)
    private String purchaseToken;

    /** Identifiant de transaction d'origine. */
    @Column(name = "original_transaction_id")
    private String originalTransactionId;

    /** Date d'expiration du plan. */
    @Column(name = "expires_at")
    private Instant expiresAt;

    /** Date de dernière vérification. */
    @Column(name = "last_verified_at")
    private Instant lastVerifiedAt;
}
