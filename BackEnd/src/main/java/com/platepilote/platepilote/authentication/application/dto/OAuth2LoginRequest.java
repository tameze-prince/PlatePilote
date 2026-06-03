package com.platepilote.platepilote.authentication.application.dto;

import jakarta.validation.constraints.NotBlank;

/**
 * Requête de connexion OAuth2 envoyée par le client Flutter.
 * <p>
 * Contient le fournisseur d'identité (google, apple, facebook),
 * le token d'identification, et optionnellement le prénom et nom.
 * </p>
 *
 * @param provider  le fournisseur OAuth2 (google, apple, facebook)
 * @param idToken   le token JWT (OIDC) ou token d'accès (Facebook)
 * @param firstName le prénom (optionnel, utilisé pour créer le compte)
 * @param lastName  le nom de famille (optionnel)
 */
public record OAuth2LoginRequest(
        @NotBlank String provider,
        @NotBlank String idToken,
        String firstName,
        String lastName
) {}
