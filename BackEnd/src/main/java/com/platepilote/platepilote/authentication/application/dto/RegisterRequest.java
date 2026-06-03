package com.platepilote.platepilote.authentication.application.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

/**
 * Requête d'inscription envoyée par le client Flutter.
 * <p>
 * Contient les informations nécessaires à la création d'un compte utilisateur.
 * La validation est assurée par les annotations Jakarta Validation.
 * En cas d'échec, {@code GlobalExceptionHandler} renvoie une erreur HTTP 400.
 * </p>
 */
@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class RegisterRequest {

    /** Prénom de l'utilisateur (obligatoire). */
    @NotBlank(message = "First name is required")
    private String firstName;

    /** Nom de famille de l'utilisateur (obligatoire). */
    @NotBlank(message = "Last name is required")
    private String lastName;

    /** Email de l'utilisateur (obligatoire, format email valide). */
    @NotBlank(message = "Email is required")
    @Email(message = "Email must be valid")
    private String email;

    /** Mot de passe de l'utilisateur (obligatoire, au moins 8 caractères). */
    @NotBlank(message = "Password is required")
    @Size(min = 8, message = "Password must be at least 8 characters")
    private String password;
}
