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

import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

/**
 * Entité représentant une interaction utilisateur avec une recette.
 * <p>
 * Les interactions (consultation, sauvegarde, cuisson, notation, rejet)
 * sont utilisées par le moteur de recommandation pour ajuster les scores
 * de pertinence des recettes pour chaque utilisateur.
 */
@Entity
@Table(name = "user_interactions")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UserInteraction {

    /** Identifiant unique de l'interaction. */
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    /** Identifiant de l'utilisateur ayant réalisé l'interaction. */
    @Column(name = "user_id", nullable = false)
    private UUID userId;

    /** Identifiant de la recette concernée par l'interaction. */
    @Column(name = "recipe_id", nullable = false)
    private UUID recipeId;

    /** Type d'interaction : saved, cooked, rated, viewed, skipped, disliked. */
    @Column(name = "interaction_type", nullable = false)
    private String interactionType;

    /** Poids de l'interaction utilisé dans le calcul du score de feedback. */
    @Column(nullable = false)
    private BigDecimal weight = BigDecimal.ONE;

    /** Date de création de l'interaction. */
    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;
}
