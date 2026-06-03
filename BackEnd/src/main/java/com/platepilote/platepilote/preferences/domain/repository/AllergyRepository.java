package com.platepilote.platepilote.preferences.domain.repository;

/**
 * Repository pour l'accès aux données des allergies.
 */

import com.platepilote.platepilote.preferences.domain.entity.Allergy;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

/**
 * Repository pour l'accès aux données des allergies.
 */
@Repository
public interface AllergyRepository extends JpaRepository<Allergy, UUID> {

    /**
     * Récupère toutes les allergies d'un utilisateur.
     *
     * @param userId identifiant de l'utilisateur
     * @return liste des allergies
     */
    List<Allergy> findByUserId(UUID userId);
}
