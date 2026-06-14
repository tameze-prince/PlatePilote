package com.platepilote.platepilote.authentication.domain.repository;

import com.platepilote.platepilote.authentication.domain.entity.EmailVerificationToken;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;
import java.util.UUID;

/**
 * Repository JPA pour l'entité {@link EmailVerificationToken}.
 * <p>
 * Fournit les opérations d'accès aux données pour les tokens de vérification d'email.
 * </p>
 */
public interface EmailVerificationTokenRepository extends JpaRepository<EmailVerificationToken, UUID> {

    /**
     * Recherche un token de vérification par sa valeur.
     *
     * @param token la valeur du token
     * @return le token trouvé, ou vide si inexistant
     */
    Optional<EmailVerificationToken> findByToken(String token);

    /**
     * Marque comme utilisés tous les tokens actifs non expirés d'un utilisateur.
     *
     * @param userId l'identifiant de l'utilisateur
     */
    @Modifying
    @Query("UPDATE EmailVerificationToken t SET t.used = true WHERE t.userId = :userId AND t.used = false")
    void markActiveTokensUsedForUser(@Param("userId") UUID userId);
}
