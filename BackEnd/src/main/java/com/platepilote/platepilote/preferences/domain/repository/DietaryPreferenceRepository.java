package com.platepilote.platepilote.preferences.domain.repository;

/**
 * DIETARY PREFERENCE REPOSITORY - DATABASE ACCESS FOR DIETARY PREFERENCES
 * =========================================================================
 * 
 * METHOD:
 * - findByUserId(uuid) -> Get all dietary preferences for a user
 *   SQL: SELECT * FROM dietary_preferences WHERE user_id = ?
 */

import com.platepilote.platepilote.preferences.domain.entity.DietaryPreference;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface DietaryPreferenceRepository extends JpaRepository<DietaryPreference, UUID> {

    /**
     * Get all dietary preferences for a specific user.
     * Returns a list because a user can have multiple preferences.
     */
    List<DietaryPreference> findByUserId(UUID userId);
}
