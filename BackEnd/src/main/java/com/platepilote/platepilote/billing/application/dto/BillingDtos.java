package com.platepilote.platepilote.billing.application.dto;

/**
 * DTOs pour le module de facturation.
 */
public final class BillingDtos {

    private BillingDtos() {
    }

    /** Requête de création de session de paiement. */
    public record CheckoutSessionRequest(
            /** Plan souhaité (MONTHLY / YEARLY). */
            String plan
    ) {}

    /** Réponse avec l'URL de la session de paiement. */
    public record CheckoutSessionResponse(
            /** URL de la session de paiement Stripe. */
            String checkoutUrl,
            /** Identifiant de la session. */
            String sessionId
    ) {}

    /** Réponse avec l'URL du portail client. */
    public record CustomerPortalResponse(
            /** URL du portail client Stripe. */
            String portalUrl
    ) {}
}
