package com.platepilote.platepilote.mealplanning.domain.repository;

import com.platepilote.platepilote.mealplanning.domain.entity.SwapTracking;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import java.time.Instant;
import java.util.UUID;

/**
 * Repository d'accès aux données de suivi des échanges (swaps).
 * <p>
 * Table associée : {@code swap_tracking}.
 * </p>
 */
public interface SwapTrackingRepository extends JpaRepository<SwapTracking, UUID> {

    /**
     * Compte le nombre d'échanges effectués par un utilisateur depuis une date donnée.
     *
     * @param userId identifiant de l'utilisateur
     * @param since  date limite (les échanges antérieurs sont ignorés)
     * @return nombre d'échanges depuis la date spécifiée
     */
    @Query("SELECT COUNT(s) FROM SwapTracking s WHERE s.userId = :userId AND s.swappedAt >= :since")
    long countByUserIdAndSwappedAtAfter(@Param("userId") UUID userId, @Param("since") Instant since);
}
