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
 * Entité représentant un paramètre de configuration système.
 * <p>
 * Stocke des paires clé/valeur configurables par l'administration.
 * </p>
 */
@Entity
@Table(name = "system_settings")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class SystemSetting {

    /** Identifiant unique du paramètre. */
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    /** Clé unique du paramètre. */
    @Column(name = "setting_key", nullable = false, unique = true)
    private String settingKey;

    /** Valeur du paramètre. */
    @Column(name = "setting_value", columnDefinition = "TEXT")
    private String settingValue;

    /** Description du paramètre. */
    @Column(columnDefinition = "TEXT")
    private String description;

    /** Date de création du paramètre. */
    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;

    /** Date de dernière modification du paramètre. */
    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false)
    private Instant updatedAt;
}
