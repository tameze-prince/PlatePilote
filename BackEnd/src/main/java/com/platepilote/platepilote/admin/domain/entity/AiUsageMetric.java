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

import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

/**
 * Entité représentant une métrique d'utilisation de l'IA.
 * <p>
 * Enregistre chaque appel aux services d'IA (OpenAI, etc.) pour le suivi des coûts et de l'utilisation.
 * </p>
 */
@Entity
@Table(name = "ai_usage_metrics")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class AiUsageMetric {

    /** Identifiant unique de la métrique. */
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    /** Identifiant de l'utilisateur à l'origine de l'appel. */
    @Column(name = "user_id")
    private UUID userId;

    /** Fournisseur IA utilisé (ex : openai, anthropic). */
    private String provider;

    /** Opération réalisée (ex : generate_recipe, suggest_meal). */
    @Column(nullable = false)
    private String operation;

    /** Nombre de tokens en entrée. */
    @Column(name = "input_tokens")
    private Integer inputTokens;

    /** Nombre de tokens en sortie. */
    @Column(name = "output_tokens")
    private Integer outputTokens;

    /** Coût estimé de l'appel. */
    @Column(name = "estimated_cost", precision = 10, scale = 4)
    private BigDecimal estimatedCost;

    /** Indique si l'appel a réussi. */
    private Boolean success;

    /** Message d'erreur en cas d'échec. */
    @Column(name = "error_message", columnDefinition = "TEXT")
    private String errorMessage;

    /** Date de création de la métrique. */
    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;
}
