package com.platepilote.platepilote.recommendation.domain.repository;

import com.platepilote.platepilote.recommendation.domain.entity.RecommendationEvent;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.Instant;
import java.util.UUID;

public interface RecommendationEventRepository extends JpaRepository<RecommendationEvent, UUID> {

    long countByUserIdAndCreatedAtAfterAndQuotaLimitedFalse(UUID userId, Instant createdAt);

    long countByCreatedAtAfter(Instant createdAt);

    long countByCreatedAtAfterAndQuotaLimitedTrue(Instant createdAt);

    long countByCreatedAtAfterAndResultCount(Instant createdAt, Integer resultCount);
}
