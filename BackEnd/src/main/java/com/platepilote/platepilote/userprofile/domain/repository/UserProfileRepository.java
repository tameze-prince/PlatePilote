package com.platepilote.platepilote.userprofile.domain.repository;

/**
 * USER PROFILE REPOSITORY - DATABASE ACCESS FOR USER PROFILES
 * =============================================================
 * 
 * WHAT IT DOES:
 * Provides methods to query the "user_profiles" table.
 * 
 * METHOD:
 * - findByUserId(uuid) -> Find the profile for a specific user
 *   SQL: SELECT * FROM user_profiles WHERE user_id = ?
 */

import com.platepilote.platepilote.userprofile.domain.entity.UserProfile;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface UserProfileRepository extends JpaRepository<UserProfile, UUID> {

    /**
     * Find a user's profile by their user ID.
     * Returns Optional<UserProfile> - empty if the user hasn't set up their profile yet.
     */
    Optional<UserProfile> findByUserId(UUID userId);
}
