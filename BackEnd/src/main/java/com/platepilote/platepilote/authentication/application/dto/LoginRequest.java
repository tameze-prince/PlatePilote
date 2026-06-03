package com.platepilote.platepilote.authentication.application.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

/**
 * Requête de connexion envoyée par le client Flutter.
 * <p>
 * Contient l'email et le mot de passe de l'utilisateur.
 * La validation est assurée par les annotations Jakarta Validation.
 * </p>
 */
@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class LoginRequest {

    /** Email de l'utilisateur (obligatoire, format email valide). */
    @NotBlank(message = "Email is required")
    @Email(message = "Email must be valid")
    private String email;

    /** Mot de passe de l'utilisateur (obligatoire). */
    @NotBlank(message = "Password is required")
    private String password;
}
