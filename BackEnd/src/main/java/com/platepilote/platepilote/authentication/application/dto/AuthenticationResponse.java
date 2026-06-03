package com.platepilote.platepilote.authentication.application.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

/**
 * Réponse d'authentification renvoyée après une connexion ou une inscription réussie.
 * <p>
 * Contient les tokens JWT (accès et rafraîchissement) que le client Flutter doit stocker
 * et utiliser pour les requêtes authentifiées.
 * </p>
 */
@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AuthenticationResponse {

    /** Token JWT d'accès, valide 1 heure, envoyé dans l'en-tête Authorization. */
    private String accessToken;

    /** Token JWT de rafraîchissement, valide 7 jours, permet d'obtenir un nouveau token d'accès. */
    private String refreshToken;

    /** Type du token, toujours {@code "Bearer"}. */
    private String tokenType = "Bearer";
}
