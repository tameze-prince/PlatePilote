package com.platepilote.platepilote.preferences.domain.repository;

/**
 * Repository pour l'accès aux données des préférences alimentaires (régimes).
 */

import com.platepilote.platepilote.preferences.domain.entity.DietaryPreference;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

/**
 * Repository pour l'accès aux données des préférences alimentaires (régimes).
 */
@Repository
public interface DietaryPreferenceRepository extends JpaRepository<DietaryPreference, UUID> {

    /**
     * Récupère toutes les préférences alimentaires actives d'un utilisateur.
     *
     * @param userId identifiant de l'utilisateur
     * @return liste des préférences actives
     */
    List<DietaryPreference> findByUserId(UUID userId);

    /**
     * Supprime définitivement toutes les préférences d'un utilisateur (y compris soft-deleted).
     * Utilisé avant réinsertion lors de la mise à jour groupée.
     *
     * @param userId identifiant de l'utilisateur
     */
    @Modifying
    @Query(value = "DELETE FROM dietary_preferences WHERE user_id = :userId", nativeQuery = true)
    void deleteAllByUserId(UUID userId);
}
