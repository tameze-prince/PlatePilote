package com.platepilote.platepilote.subscription.domain.repository;

import com.platepilote.platepilote.subscription.domain.entity.UserEntitlement;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.Instant;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

/**
 * Repository pour l'accès aux données des entitlements utilisateur.
 */
@Repository
public interface UserEntitlementRepository extends JpaRepository<UserEntitlement, UUID> {

    /**
     * Recherche un entitlement par utilisateur et clé.
     *
     * @param userId         identifiant de l'utilisateur
     * @param entitlementKey clé de l'entitlement
     * @return l'entitlement s'il existe
     */
    Optional<UserEntitlement> findByUserIdAndEntitlementKey(UUID userId, String entitlementKey);

    /**
     * Recherche les entitlements actifs d'un utilisateur.
     *
     * @param userId identifiant de l'utilisateur
     * @param status statut souhaité
     * @return liste des entitlements correspondants
     */
    List<UserEntitlement> findByUserIdAndStatusAndDeletedAtIsNull(UUID userId, String status);

    /**
     * Vérifie l'existence d'un entitlement actif.
     *
     * @param userId         identifiant de l'utilisateur
     * @param entitlementKey clé de l'entitlement
     * @param status         statut souhaité
     * @return true si un entitlement correspondant existe
     */
    boolean existsByUserIdAndEntitlementKeyAndStatusAndDeletedAtIsNull(UUID userId, String entitlementKey, String status);

    /**
     * Recherche les entitlements expirés (pour nettoyage ou relance).
     *
     * @param status   statut souhaité
     * @param expiresAt date seuil d'expiration
     * @return liste des entitlements expirés
     */
    List<UserEntitlement> findByStatusAndExpiresAtBeforeAndDeletedAtIsNull(String status, Instant expiresAt);
}
