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
public class CuisinePreferenceRequest {

    @NotBlank(message = "Cuisine type is required")
    private String cuisineType;
}
