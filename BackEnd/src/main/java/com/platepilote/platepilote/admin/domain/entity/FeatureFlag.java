package com.platepilote.platepilote.admin.domain.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.Instant;
import java.util.UUID;

/**
 * Entité représentant un feature flag (interrupteur de fonctionnalité).
 * <p>
 * Permet d'activer ou désactiver des fonctionnalités sans redéploiement.
 * </p>
 */
@Entity
@Table(name = "feature_flags")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class FeatureFlag {

    /** Identifiant unique du feature flag. */
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    /** Clé unique identifiant la fonctionnalité. */
    @Column(name = "flag_key", nullable = false, unique = true)
    private String flagKey;

    /** Description de la fonctionnalité. */
    @Column(columnDefinition = "TEXT")
    private String description;

    /** État d'activation du flag. */
    @Column(nullable = false)
    private Boolean enabled = false;

    /** Date de création du flag. */
    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;

    /** Date de dernière modification du flag. */
    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false)
    private Instant updatedAt;
}
