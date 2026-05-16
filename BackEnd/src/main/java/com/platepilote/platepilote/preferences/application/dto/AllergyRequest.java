package com.platepilote.platepilote.preferences.application.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AllergyRequest {

    @NotBlank(message = "Allergen is required")
    private String allergen;

    private String severity;
}
