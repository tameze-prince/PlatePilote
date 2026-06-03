package com.platepilote.platepilote.recommendation.domain.repository;

import com.platepilote.platepilote.recommendation.domain.entity.RecommendationEvent;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.Instant;
import java.util.UUID;

/**
 * Repository pour l'accès aux données des événements de recommandation.
 * <p>
 * Permet le comptage des requêtes pour la gestion des quotas et les statistiques d'utilisation.
 */
public interface RecommendationEventRepository extends JpaRepository<RecommendationEvent, UUID> {

    /**
     * Compte les événements de recommandation non limités par quota pour un utilisateur depuis une date donnée.
     *
     * @param userId    identifiant de l'utilisateur
     * @param createdAt date de début de la période
     * @return nombre d'événements éligibles
     */
    long countByUserIdAndCreatedAtAfterAndQuotaLimitedFalse(UUID userId, Instant createdAt);

    /**
     * Compte tous les événements de recommandation depuis une date donnée.
     *
     * @param createdAt date de début de la période
     * @return nombre total d'événements
     */
    long countByCreatedAtAfter(Instant createdAt);

    /**
     * Compte les événements de recommandation limités par quota depuis une date donnée.
     *
     * @param createdAt date de début de la période
     * @return nombre d'événements quota-limited
     */
    long countByCreatedAtAfterAndQuotaLimitedTrue(Instant createdAt);

    /**
     * Compte les événements de recommandation avec un nombre de résultats spécifique depuis une date donnée.
     *
     * @param createdAt   date de début de la période
     * @param resultCount nombre de résultats cible
     * @return nombre d'événements correspondants
     */
    long countByCreatedAtAfterAndResultCount(Instant createdAt, Integer resultCount);
}
