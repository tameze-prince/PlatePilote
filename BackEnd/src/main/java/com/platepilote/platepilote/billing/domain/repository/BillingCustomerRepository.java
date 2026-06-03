package com.platepilote.platepilote.billing.domain.repository;

import com.platepilote.platepilote.billing.domain.entity.BillingCustomer;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;
import java.util.UUID;

/**
 * Repository pour l'accès aux données des clients de facturation.
 */
public interface BillingCustomerRepository extends JpaRepository<BillingCustomer, UUID> {

    /**
     * Recherche un client par fournisseur et identifiant utilisateur.
     *
     * @param provider nom du fournisseur
     * @param userId   identifiant de l'utilisateur
     * @return le client s'il existe
     */
    Optional<BillingCustomer> findByProviderAndUserId(String provider, UUID userId);

    /**
     * Recherche un client par fournisseur et identifiant client chez le fournisseur.
     *
     * @param provider            nom du fournisseur
     * @param providerCustomerId  identifiant client chez le fournisseur
     * @return le client s'il existe
     */
    Optional<BillingCustomer> findByProviderAndProviderCustomerId(String provider, String providerCustomerId);
}
