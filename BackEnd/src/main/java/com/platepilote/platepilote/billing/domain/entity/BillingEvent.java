package com.platepilote.platepilote.billing.domain.entity;

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

import java.time.Instant;
import java.util.UUID;

/**
 * Entité représentant un événement de webhook de facturation.
 * Table en base : {@code billing_events}.
 */
@Entity
@Table(name = "billing_events")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class BillingEvent {

    /** Identifiant unique de l'événement. */
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    /** Nom du fournisseur de paiement. */
    @Column(nullable = false)
    private String provider;

    /** Identifiant de l'événement chez le fournisseur. */
    @Column(name = "event_id", nullable = false)
    private String eventId;

    /** Type d'événement (ex. checkout.session.completed). */
    @Column(name = "event_type", nullable = false)
    private String eventType;

    /** Indique si l'événement a été traité. */
    @Column(nullable = false)
    private Boolean processed = false;

    /** Message d'erreur en cas d'échec du traitement. */
    @Column(name = "error_message", columnDefinition = "TEXT")
    private String errorMessage;

    /** Payload brut de l'événement. */
    @Column(name = "raw_payload", columnDefinition = "TEXT")
    private String rawPayload;

    /** Date de création de l'événement. */
    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;

    /** Date de traitement de l'événement. */
    @Column(name = "processed_at")
    private Instant processedAt;
}
