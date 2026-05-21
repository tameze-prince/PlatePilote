package com.platepilote.platepilote.preferences.application.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.util.List;

@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UserPreferencesResponse {

    private List<String> dietaryPreferences;
    private List<AllergyEntry> allergies;
    private List<String> cuisines;

    @Getter
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class AllergyEntry {
        private String allergen;
        private String severity;
    }
}
