package com.platepilote.platepilote.billing.application.service;

import java.time.Instant;
import java.util.Map;

/**
 * Modèles partagés entre le service de facturation et les fournisseurs de paiement.
 */
public final class BillingProviderModels {

    private BillingProviderModels() {
    }

    /** Session de paiement créée chez le fournisseur. */
    public record BillingCheckoutSession(
            /** Identifiant de la session. */
            String id,
            /** URL de la session. */
            String url
    ) {}

    /** Session portail client créée chez le fournisseur. */
    public record BillingPortalSession(
            /** Identifiant de la session. */
            String id,
            /** URL de la session. */
            String url
    ) {}

    /** Événement désérialisé provenant du fournisseur de paiement. */
    public record ProviderEvent(
            /** Identifiant de l'événement. */
            String id,
            /** Type d'événement (ex. checkout.session.completed). */
            String type,
            /** Identifiant du client chez le fournisseur. */
            String customerId,
            /** Identifiant de l'abonnement chez le fournisseur. */
            String subscriptionId,
            /** Identifiant de la session de paiement. */
            String checkoutSessionId,
            /** Statut de l'abonnement. */
            String status,
            /** Identifiant du prix associé. */
            String priceId,
            /** Fin de la période en cours. */
            Instant currentPeriodEnd,
            /** Métadonnées supplémentaires. */
            Map<String, String> metadata
    ) {}
}
