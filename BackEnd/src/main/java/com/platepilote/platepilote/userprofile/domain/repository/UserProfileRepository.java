package com.platepilote.platepilote.userprofile.domain.repository;

/**
 * Repository pour l'accès aux données des profils utilisateur.
 * <p>
 * Fournit une méthode de recherche du profil par identifiant utilisateur.
 */

import com.platepilote.platepilote.userprofile.domain.entity.UserProfile;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;
import java.util.UUID;

public interface UserProfileRepository extends JpaRepository<UserProfile, UUID> {

    /**
     * Recherche le profil d'un utilisateur par son identifiant.
     *
     * @param userId identifiant de l'utilisateur
     * @return profil trouvé ou Optional vide si aucun profil n'existe
     */
    Optional<UserProfile> findByUserId(UUID userId);
}
