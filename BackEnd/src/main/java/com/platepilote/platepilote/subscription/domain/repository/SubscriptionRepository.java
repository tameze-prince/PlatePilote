package com.platepilote.platepilote.subscription.domain.repository;

import com.platepilote.platepilote.subscription.domain.entity.Subscription;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;
import java.util.UUID;

/**
 * Repository pour l'accès aux données des abonnements.
 */
public interface SubscriptionRepository extends JpaRepository<Subscription, UUID> {

    /**
     * Recherche l'abonnement d'un utilisateur.
     *
     * @param userId identifiant de l'utilisateur
     * @return l'abonnement s'il existe
     */
    Optional<Subscription> findByUserId(UUID userId);

    /**
     * Recherche un abonnement par fournisseur et identifiant chez le fournisseur.
     *
     * @param provider                nom du fournisseur
     * @param providerSubscriptionId  identifiant de l'abonnement chez le fournisseur
     * @return l'abonnement s'il existe
     */
    Optional<Subscription> findByProviderAndProviderSubscriptionId(String provider, String providerSubscriptionId);

    /**
     * Vérifie si un utilisateur possède déjà un abonnement.
     *
     * @param userId identifiant de l'utilisateur
     * @return true si un abonnement existe
     */
    boolean existsByUserId(UUID userId);
}
