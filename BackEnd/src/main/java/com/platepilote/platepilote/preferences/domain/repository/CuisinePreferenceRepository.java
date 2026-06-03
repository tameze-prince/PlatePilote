package com.platepilote.platepilote.preferences.domain.repository;

import com.platepilote.platepilote.preferences.domain.entity.CuisinePreference;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

/**
 * Repository pour l'accès aux données des préférences culinaires.
 */
@Repository
public interface CuisinePreferenceRepository extends JpaRepository<CuisinePreference, UUID> {

    /**
     * Récupère toutes les préférences culinaires d'un utilisateur.
     *
     * @param userId identifiant de l'utilisateur
     * @return liste des préférences culinaires
     */
    List<CuisinePreference> findByUserId(UUID userId);
}
