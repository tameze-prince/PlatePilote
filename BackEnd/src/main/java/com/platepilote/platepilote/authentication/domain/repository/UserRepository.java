package com.platepilote.platepilote.authentication.domain.repository;

import com.platepilote.platepilote.authentication.domain.entity.OurUser;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import java.util.Optional;
import java.util.UUID;

/**
 * Repository JPA pour l'entité {@link OurUser}.
 * <p>
 * Fournit les opérations d'accès aux données pour les utilisateurs.
 * Spring Data JPA génère automatiquement les implémentations des méthodes.
 * </p>
 */
public interface UserRepository extends JpaRepository<OurUser, UUID> {

    /**
     * Recherche un utilisateur par son email.
     *
     * @param email l'email de l'utilisateur
     * @return l'utilisateur trouvé, ou vide si inexistant
     */
    Optional<OurUser> findByEmail(String email);

    /**
     * Recherche un utilisateur par son fournisseur OAuth et son identifiant chez le fournisseur
     * (insensible à la casse pour le fournisseur).
     *
     * @param provider   le fournisseur OAuth
     * @param providerId l'identifiant chez le fournisseur
     * @return l'utilisateur trouvé, ou vide si inexistant
     */
    Optional<OurUser> findByProviderIgnoreCaseAndProviderId(String provider, String providerId);

    /**
     * Vérifie si un email est déjà utilisé.
     *
     * @param email l'email à vérifier
     * @return {@code true} si un utilisateur avec cet email existe
     */
    boolean existsByEmail(String email);

    /**
     * Recherche des utilisateurs par email, prénom ou nom (insensible à la casse).
     *
     * @param query    le terme de recherche
     * @param pageable les paramètres de pagination
     * @return une page de résultats
     */
    @Query("SELECT u FROM OurUser u WHERE LOWER(u.email) LIKE LOWER(CONCAT('%', :query, '%')) " +
            "OR LOWER(u.firstName) LIKE LOWER(CONCAT('%', :query, '%')) " +
            "OR LOWER(u.lastName) LIKE LOWER(CONCAT('%', :query, '%'))")
    org.springframework.data.domain.Page<OurUser> search(@Param("query") String query, org.springframework.data.domain.Pageable pageable);
}
