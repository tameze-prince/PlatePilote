package com.platepilote.platepilote.recommendation.domain.entity;

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
 * Entité représentant un événement de recommandation enregistré pour chaque appel au moteur de recommandation.
 * <p>
 * Permet le suivi des quotas, des performances et de l'utilisation du service de recommandation.
 * Chaque événement contient le type de requête, le nombre de résultats, la durée d'exécution
 * et les informations de localisation (pays, devise).
 */
@Entity
@Table(name = "recommendation_events")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class RecommendationEvent {

    /** Identifiant unique de l'événement de recommandation. */
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    /** Identifiant de l'utilisateur ayant effectué la demande de recommandation. */
    @Column(name = "user_id", nullable = false)
    private UUID userId;

    /** Type de requête (ex: STANDARD, QUICK_MEAL, WEEKLY_PLAN). */
    @Column(name = "request_type", nullable = false)
    private String requestType;

    /** Code pays ISO 3166-1 alpha-2 utilisé pour la régionalisation des résultats. */
    @Column(name = "country_code")
    private String countryCode;

    /** Code devise ISO 4217 utilisé pour l'affichage des prix estimés. */
    @Column(name = "currency_code")
    private String currencyCode;

    /** Nombre de résultats retournés par la recommandation. */
    @Column(name = "result_count", nullable = false)
    private Integer resultCount = 0;

    /** Durée d'exécution de la recommandation en millisecondes. */
    @Column(name = "duration_ms")
    private Integer durationMs;

    /** Indique si la requête a été bloquée par le quota hebdomadaire gratuit. */
    @Column(name = "quota_limited", nullable = false)
    private Boolean quotaLimited = false;

    /** Date de création de l'événement. */
    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;
}
