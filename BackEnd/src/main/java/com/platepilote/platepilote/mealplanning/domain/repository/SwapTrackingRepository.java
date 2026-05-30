package com.platepilote.platepilote.mealplanning.domain.repository;

import com.platepilote.platepilote.mealplanning.domain.entity.SwapTracking;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.Instant;
import java.util.UUID;

@Repository
public interface SwapTrackingRepository extends JpaRepository<SwapTracking, UUID> {

    @Query("SELECT COUNT(s) FROM SwapTracking s WHERE s.userId = :userId AND s.swappedAt >= :since")
    long countByUserIdAndSwappedAtAfter(@Param("userId") UUID userId, @Param("since") Instant since);
}
