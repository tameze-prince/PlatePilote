package com.platepilote.platepilote.billing.application.service;

import com.platepilote.platepilote.billing.application.service.BillingProviderModels.BillingCheckoutSession;
import com.platepilote.platepilote.billing.application.service.BillingProviderModels.BillingPortalSession;
import com.platepilote.platepilote.billing.application.service.BillingProviderModels.ProviderEvent;

/**
 * Interface pour l'intégration d'un fournisseur de paiement (Stripe, etc.).
 */
public interface BillingProvider {

    /**
     * @return nom du fournisseur (ex. STRIPE)
     */
    String providerName();

    /**
     * Crée un client chez le fournisseur de paiement.
     *
     * @param email email du client
     * @param name  nom du client
     * @return identifiant du client chez le fournisseur
     */
    String createCustomer(String email, String name);

    /**
     * Crée une session de paiement pour un abonnement.
     *
     * @param customerId        identifiant du client chez le fournisseur
     * @param priceId           identifiant du prix
     * @param trialDays         nombre de jours d'essai
     * @param successUrl        URL de redirection en cas de succès
     * @param cancelUrl         URL de redirection en cas d'annulation
     * @param clientReferenceId référence client (userId)
     * @return session de paiement
     */
    BillingCheckoutSession createCheckoutSession(String customerId, String priceId, int trialDays,
                                                  String successUrl, String cancelUrl, String clientReferenceId);

    /**
     * Crée une session portail client pour gérer l'abonnement.
     *
     * @param customerId identifiant du client chez le fournisseur
     * @param returnUrl  URL de retour
     * @return session portail
     */
    BillingPortalSession createPortalSession(String customerId, String returnUrl);

    /**
     * Vérifie et désérialise un webhook provenant du fournisseur.
     *
     * @param rawPayload      corps brut de la requête
     * @param signatureHeader en-tête de signature
     * @return événement désérialisé
     */
    ProviderEvent verifyWebhook(String rawPayload, String signatureHeader);
}
