package com.platepilote.platepilote.preferences.application.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

/**
 * Requête de création d'une allergie alimentaire.
 */
@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AllergyRequest {

    /** Nom de l'allergène (obligatoire). */
    @NotBlank(message = "Allergen is required")
    private String allergen;

    /** Niveau de sévérité (mild, moderate, severe). */
    private String severity;
}
