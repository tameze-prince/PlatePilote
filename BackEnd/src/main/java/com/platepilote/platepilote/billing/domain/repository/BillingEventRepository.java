package com.platepilote.platepilote.billing.domain.repository;

import com.platepilote.platepilote.billing.domain.entity.BillingEvent;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;
import java.util.UUID;

/**
 * Repository pour l'accès aux données des événements de facturation.
 */
public interface BillingEventRepository extends JpaRepository<BillingEvent, UUID> {

    /**
     * Recherche un événement par fournisseur et identifiant d'événement.
     *
     * @param provider nom du fournisseur
     * @param eventId  identifiant de l'événement
     * @return l'événement s'il existe
     */
    Optional<BillingEvent> findByProviderAndEventId(String provider, String eventId);

    /**
     * Récupère tous les événements classés par date de création décroissante.
     *
     * @param pageable paramètres de pagination
     * @return page des événements
     */
    Page<BillingEvent> findAllByOrderByCreatedAtDesc(Pageable pageable);
}
