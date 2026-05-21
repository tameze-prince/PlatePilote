package com.platepilote.platepilote.preferences.application.dto;

import jakarta.validation.Valid;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.util.List;

@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UserPreferencesRequest {

    @Valid
    private List<String> dietaryPreferences;

    @Valid
    private List<@Valid AllergyEntry> allergies;

    @Valid
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
