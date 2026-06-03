package com.platepilote.platepilote.preferences.application.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

/**
 * Requête de création d'une préférence culinaire.
 */
@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CuisinePreferenceRequest {

    /** Type de cuisine (ex. italienne, japonaise, mexicaine) — obligatoire. */
    @NotBlank(message = "Cuisine type is required")
    private String cuisineType;
}
