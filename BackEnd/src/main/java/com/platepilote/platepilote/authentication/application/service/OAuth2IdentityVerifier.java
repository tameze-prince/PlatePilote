package com.platepilote.platepilote.authentication.application.service;

/**
 * Interface de vérification d'identité OAuth2.
 * <p>
 * Chaque implémentation sait vérifier un token auprès d'un fournisseur OAuth2
 * (Google, Apple, Facebook) et retourner une {@link OAuth2Identity} contenant
 * les informations de l'utilisateur.
 * </p>
 *
 * @see OidcIdentityVerifier
 * @see FacebookOAuth2Verifier
 * @see CompositeOAuth2Verifier
 */
public interface OAuth2IdentityVerifier {

    /**
     * Vérifie un token OAuth2 et retourne l'identité de l'utilisateur.
     *
     * @param provider le fournisseur (google, apple, facebook)
     * @param idToken  le token JWT (OIDC) ou token d'accès (Facebook)
     * @return l'identité vérifiée de l'utilisateur
     */
    OAuth2Identity verify(String provider, String idToken);

    /**
     * Identité OAuth2 vérifiée d'un utilisateur.
     *
     * @param provider      le fournisseur (google, apple, facebook)
     * @param providerId    l'identifiant unique chez le fournisseur
     * @param email         l'email vérifié (peut être {@code null})
     * @param emailVerified si l'email est vérifié
     * @param firstName     le prénom (peut être {@code null})
     * @param lastName      le nom de famille (peut être {@code null})
     * @param avatarUrl     l'URL de l'avatar (peut être {@code null})
     */
    record OAuth2Identity(
            String provider,
            String providerId,
            String email,
            boolean emailVerified,
            String firstName,
            String lastName,
            String avatarUrl
    ) {}
}
