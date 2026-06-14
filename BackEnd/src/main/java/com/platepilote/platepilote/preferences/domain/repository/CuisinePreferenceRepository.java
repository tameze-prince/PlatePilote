package com.platepilote.platepilote.preferences.domain.repository;

import com.platepilote.platepilote.preferences.domain.entity.CuisinePreference;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import java.util.List;
import java.util.UUID;

/**
 * Repository pour l'accès aux données des préférences culinaires.
 */
public interface CuisinePreferenceRepository extends JpaRepository<CuisinePreference, UUID> {

    /**
     * Récupère toutes les préférences culinaires actives d'un utilisateur.
     *
     * @param userId identifiant de l'utilisateur
     * @return liste des préférences culinaires actives
     */
    List<CuisinePreference> findByUserId(UUID userId);

    /**
     * Supprime définitivement toutes les préférences culinaires d'un utilisateur (y compris soft-deleted).
     * Utilisé avant réinsertion lors de la mise à jour groupée.
     *
     * @param userId identifiant de l'utilisateur
     */
    @Modifying
    @Query(value = "DELETE FROM cuisine_preferences WHERE user_id = :userId", nativeQuery = true)
    void deleteAllByUserId(UUID userId);
}
