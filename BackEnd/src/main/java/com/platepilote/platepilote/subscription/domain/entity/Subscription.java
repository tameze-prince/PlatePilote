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

@Entity
@Table(name = "subscriptions")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Subscription extends BaseEntity {

    @Column(name = "user_id", nullable = false, unique = true)
    private UUID userId;

    @Column(name = "plan_type", nullable = false)
    private String planType = "FREE";

    @Column(nullable = false)
    private String status = "ACTIVE";

    @Column(name = "start_date", nullable = false)
    private Instant startDate;

    @Column(name = "end_date")
    private Instant endDate;

    @Column(name = "trial_end_date")
    private Instant trialEndDate;

    @Column(name = "cancel_at_period_end")
    private Boolean cancelAtPeriodEnd = false;

    @Column(name = "provider")
    private String provider = "INTERNAL";

    @Column(name = "provider_subscription_id")
    private String providerSubscriptionId;

    @Column(name = "purchase_token", length = 1000)
    private String purchaseToken;

    @Column(name = "original_transaction_id")
    private String originalTransactionId;

    @Column(name = "expires_at")
    private Instant expiresAt;

    @Column(name = "last_verified_at")
    private Instant lastVerifiedAt;
}
