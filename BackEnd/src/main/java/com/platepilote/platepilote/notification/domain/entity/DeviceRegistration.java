package com.platepilote.platepilote.notification.domain.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.Instant;
import java.util.UUID;

/**
 * Entité représentant l'enregistrement d'un appareil mobile pour les notifications push.
 * <p>
 * Associe un token d'appareil (FCM/APNS) à un utilisateur pour permettre
 * l'envoi de notifications push ciblées.
 */
@Entity
@Table(name = "device_registrations")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class DeviceRegistration {

    /** Identifiant unique de l'enregistrement. */
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    /** Identifiant de l'utilisateur propriétaire de l'appareil. */
    @Column(name = "user_id", nullable = false)
    private UUID userId;

    /** Token d'authentification de l'appareil (FCM/APNS). */
    @Column(name = "device_token", nullable = false, length = 512)
    private String deviceToken;

    /** Plateforme de l'appareil (android, ios, web). */
    @Column(name = "platform")
    private String platform;

    /** Indique si l'appareil est actif pour les notifications. */
    @Column(name = "is_active")
    @Builder.Default
    private Boolean isActive = true;

    /** Date de création de l'enregistrement. */
    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;

    /** Date de dernière mise à jour de l'enregistrement. */
    @Column(name = "updated_at", nullable = false)
    private Instant updatedAt;
}
