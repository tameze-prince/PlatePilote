package com.platepilote.platepilote.billing.domain.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.Instant;
import java.util.UUID;

/**
 * Durable outbox entry for provider-side subscription cancellation.
 * Deliberately has no FK to users: the request must survive account anonymization.
 */
@Entity
@Table(name = "billing_cancellation_requests")
@Getter
@Setter
@NoArgsConstructor
public class BillingCancellationRequest {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(name = "user_id", nullable = false)
    private UUID userId;

    @Column(name = "subscription_id")
    private UUID subscriptionId;

    @Column(nullable = false, length = 32)
    private String provider;

    @Column(name = "provider_subscription_id", nullable = false, length = 255)
    private String providerSubscriptionId;

    @Column(nullable = false, length = 24)
    private String status = "PENDING";

    @Column(name = "attempt_count", nullable = false)
    private int attemptCount;

    @Column(name = "next_attempt_at", nullable = false)
    private Instant nextAttemptAt;

    @Column(name = "last_error", columnDefinition = "TEXT")
    private String lastError;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false)
    private Instant updatedAt;

    public void markCompleted(Instant now) {
        status = "COMPLETED";
        lastError = null;
        updatedAt = now;
    }

    public void markFailedAttempt(String error, Instant now, Instant retryAt, int maxAttempts) {
        attemptCount++;
        lastError = error == null ? "Unknown provider error" : error.substring(0, Math.min(error.length(), 2000));
        updatedAt = now;
        if (attemptCount >= maxAttempts) {
            status = "FAILED";
        } else {
            status = "PENDING";
            nextAttemptAt = retryAt;
        }
    }
}
