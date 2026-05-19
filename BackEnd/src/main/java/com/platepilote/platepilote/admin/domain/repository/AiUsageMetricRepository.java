package com.platepilote.platepilote.admin.domain.repository;

import com.platepilote.platepilote.admin.domain.entity.AiUsageMetric;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.Instant;
import java.util.UUID;

public interface AiUsageMetricRepository extends JpaRepository<AiUsageMetric, UUID> {

    long countByCreatedAtAfter(Instant createdAt);
}
