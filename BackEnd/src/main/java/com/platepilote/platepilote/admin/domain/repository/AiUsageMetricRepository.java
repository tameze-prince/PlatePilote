package com.platepilote.platepilote.admin.domain.repository;

import com.platepilote.platepilote.admin.domain.entity.AiUsageMetric;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.Instant;
import java.util.UUID;

/**
 * Repository pour l'entité {@link AiUsageMetric}.
 */
@Repository
public interface AiUsageMetricRepository extends JpaRepository<AiUsageMetric, UUID> {

    /**
     * Compte le nombre de métriques créées après une date donnée.
     *
     * @param createdAt date limite
     * @return nombre de métriques
     */
    long countByCreatedAtAfter(Instant createdAt);
}
