package com.platepilote.platepilote.preferences.application.dto;

import jakarta.validation.Valid;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.util.List;

/**
 * Requête de mise à jour groupée des préférences utilisateur.
 */
@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UserPreferencesRequest {

    /** Liste des régimes alimentaires. */
    @Valid
    private List<String> dietaryPreferences;

    /** Liste des allergies alimentaires. */
    @Valid
    private List<@Valid AllergyEntry> allergies;

    /** Liste des cuisines préférées. */
    @Valid
    private List<String> cuisines;

    /**
     * Entrée représentant une allergie dans la requête groupée.
     */
    @Getter
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class AllergyEntry {
        /** Nom de l'allergène. */
        private String allergen;
        /** Niveau de sévérité. */
        private String severity;
    }
}
