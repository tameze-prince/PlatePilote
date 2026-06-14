package com.platepilote.platepilote.preferences.domain.repository;

/**
 * Repository pour l'accès aux données des allergies.
 */

import com.platepilote.platepilote.preferences.domain.entity.Allergy;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import java.util.List;
import java.util.UUID;

/**
 * Repository pour l'accès aux données des allergies.
 */
public interface AllergyRepository extends JpaRepository<Allergy, UUID> {

    /**
     * Récupère toutes les allergies actives d'un utilisateur.
     *
     * @param userId identifiant de l'utilisateur
     * @return liste des allergies actives
     */
    List<Allergy> findByUserId(UUID userId);

    /**
     * Supprime définitivement toutes les allergies d'un utilisateur (y compris soft-deleted).
     * Utilisé avant réinsertion lors de la mise à jour groupée.
     *
     * @param userId identifiant de l'utilisateur
     */
    @Modifying
    @Query(value = "DELETE FROM allergies WHERE user_id = :userId", nativeQuery = true)
    void deleteAllByUserId(UUID userId);
}
