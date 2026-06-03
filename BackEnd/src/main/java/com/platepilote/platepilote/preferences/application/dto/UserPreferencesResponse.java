package com.platepilote.platepilote.preferences.application.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.util.List;

/**
 * Réponse contenant l'ensemble des préférences utilisateur.
 */
@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UserPreferencesResponse {

    /** Liste des régimes alimentaires. */
    private List<String> dietaryPreferences;
    /** Liste des allergies avec leur sévérité. */
    private List<AllergyEntry> allergies;
    /** Liste des cuisines préférées. */
    private List<String> cuisines;

    /**
     * Entrée représentant une allergie dans la réponse groupée.
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
