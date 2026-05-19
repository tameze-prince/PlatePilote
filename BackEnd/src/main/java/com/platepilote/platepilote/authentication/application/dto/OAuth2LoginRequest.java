package com.platepilote.platepilote.authentication.application.dto;

import jakarta.validation.constraints.NotBlank;

public record OAuth2LoginRequest(
        @NotBlank String provider,
        @NotBlank String idToken,
        String firstName,
        String lastName
) {}
