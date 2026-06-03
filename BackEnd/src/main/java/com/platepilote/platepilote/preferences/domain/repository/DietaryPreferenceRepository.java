package com.platepilote.platepilote.preferences.domain.repository;

/**
 * Repository pour l'accès aux données des préférences alimentaires (régimes).
 */

import com.platepilote.platepilote.preferences.domain.entity.DietaryPreference;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

/**
 * Repository pour l'accès aux données des préférences alimentaires (régimes).
 */
@Repository
public interface DietaryPreferenceRepository extends JpaRepository<DietaryPreference, UUID> {

    /**
     * Récupère toutes les préférences alimentaires d'un utilisateur.
     *
     * @param userId identifiant de l'utilisateur
     * @return liste des préférences
     */
    List<DietaryPreference> findByUserId(UUID userId);
}
