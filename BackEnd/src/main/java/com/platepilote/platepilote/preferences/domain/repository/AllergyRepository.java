package com.platepilote.platepilote.preferences.domain.repository;

/**
 * ALLERGY REPOSITORY - DATABASE ACCESS FOR ALLERGIES
 * ====================================================
 * 
 * METHOD:
 * - findByUserId(uuid) -> Get all allergies for a user
 *   SQL: SELECT * FROM allergies WHERE user_id = ?
 */

import com.platepilote.platepilote.preferences.domain.entity.Allergy;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface AllergyRepository extends JpaRepository<Allergy, UUID> {

    /**
     * Get all allergies for a specific user.
     * Used by RecommendationEngine to filter out recipes containing allergens.
     */
    List<Allergy> findByUserId(UUID userId);
}
