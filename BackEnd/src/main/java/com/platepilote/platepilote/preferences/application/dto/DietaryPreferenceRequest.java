package com.platepilote.platepilote.preferences.application.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

/**
 * Requête de création d'une préférence alimentaire (régime).
 */
@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class DietaryPreferenceRequest {

    /** Type de régime (ex. végétarien, végan, keto) — obligatoire. */
    @NotBlank(message = "Diet type is required")
    private String dietType;
}
