package com.platepilote.platepilote.authentication.domain.repository;

import com.platepilote.platepilote.authentication.domain.entity.RefreshToken;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.Instant;
import java.util.Optional;
import java.util.UUID;

/**
 * Repository JPA pour l'entité {@link RefreshToken}.
 * <p>
 * Fournit les opérations d'accès aux données pour les tokens de rafraîchissement JWT.
 * </p>
 */
@Repository
public interface RefreshTokenRepository extends JpaRepository<RefreshToken, UUID> {

    /**
     * Recherche un token de rafraîchissement par sa valeur hachée.
     *
     * @param token la valeur hachée du token
     * @return le token trouvé, ou vide si inexistant
     */
    Optional<RefreshToken> findByToken(String token);

    /**
     * Révoque tous les tokens de rafraîchissement actifs d'un utilisateur.
     *
     * @param userId l'identifiant de l'utilisateur
     * @return le nombre de tokens révoqués
     */
    @Modifying
    @Query("update RefreshToken rt set rt.revoked = true where rt.userId = :userId and rt.revoked = false")
    int revokeAllActiveForUser(@Param("userId") UUID userId);

    /**
     * Supprime les tokens expirés ou révoqués antérieurs à une date donnée.
     *
     * @param before la date limite
     * @return le nombre de tokens supprimés
     */
    @Modifying
    @Query("delete from RefreshToken rt where rt.expiresAt < :before or rt.revoked = true")
    int deleteExpiredOrRevokedBefore(@Param("before") Instant before);
}
