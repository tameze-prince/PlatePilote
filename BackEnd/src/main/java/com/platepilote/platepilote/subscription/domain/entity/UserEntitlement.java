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
 * Entité représentant un droit (entitlement) accordé à un utilisateur.
 * Table en base : {@code user_entitlements}.
 */
@Entity
@Table(name = "user_entitlements")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UserEntitlement extends BaseEntity {

    /** Identifiant de l'utilisateur. */
    @Column(name = "user_id", nullable = false)
    private UUID userId;

    /** Clé de l'entitlement (ex. premium). */
    @Column(name = "entitlement_key", nullable = false)
    private String entitlementKey;

    /** Source de l'octroi (INTERNAL, STRIPE, etc.). */
    @Column(nullable = false)
    private String source = "INTERNAL";

    /** Statut (ACTIVE, CANCELLED, EXPIRED). */
    @Column(nullable = false)
    private String status = "ACTIVE";

    /** Date de début de validité. */
    @Column(name = "starts_at", nullable = false)
    private Instant startsAt;

    /** Date d'expiration. */
    @Column(name = "expires_at")
    private Instant expiresAt;

    /** Date de dernière vérification. */
    @Column(name = "last_verified_at")
    private Instant lastVerifiedAt;

    /** Métadonnées supplémentaires (JSON). */
    @Column(columnDefinition = "TEXT")
    private String metadata;
}
