package com.platepilote.platepilote.userprofile.application.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDate;
import java.util.UUID;

@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UserProfileResponse {

    private UUID id;
    private UUID userId;
    private LocalDate dateOfBirth;
    private String gender;
    private BigDecimal heightCm;
    private BigDecimal weightKg;
    private String activityLevel;
    private String healthGoals;
    private Instant createdAt;
    private Instant updatedAt;
}
