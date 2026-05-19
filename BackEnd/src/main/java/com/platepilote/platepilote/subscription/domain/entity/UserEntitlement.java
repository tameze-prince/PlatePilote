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
@Table(name = "user_entitlements")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UserEntitlement extends BaseEntity {

    @Column(name = "user_id", nullable = false)
    private UUID userId;

    @Column(name = "entitlement_key", nullable = false)
    private String entitlementKey;

    @Column(nullable = false)
    private String source = "INTERNAL";

    @Column(nullable = false)
    private String status = "ACTIVE";

    @Column(name = "starts_at", nullable = false)
    private Instant startsAt;

    @Column(name = "expires_at")
    private Instant expiresAt;

    @Column(name = "last_verified_at")
    private Instant lastVerifiedAt;

    @Column(columnDefinition = "TEXT")
    private String metadata;
}
