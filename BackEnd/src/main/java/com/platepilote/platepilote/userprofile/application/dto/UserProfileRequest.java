package com.platepilote.platepilote.userprofile.application.dto;

import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDate;

@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UserProfileRequest {

    private LocalDate dateOfBirth;

    @Size(max = 20, message = "Gender must be at most 20 characters")
    private String gender;

    @DecimalMin(value = "50.0", message = "Height must be at least 50 cm")
    @DecimalMax(value = "300.0", message = "Height must be at most 300 cm")
    private BigDecimal heightCm;

    @DecimalMin(value = "20.0", message = "Weight must be at least 20 kg")
    @DecimalMax(value = "500.0", message = "Weight must be at most 500 kg")
    private BigDecimal weightKg;

    @Size(max = 30, message = "Activity level must be at most 30 characters")
    private String activityLevel;

    @Size(max = 255, message = "Health goals must be at most 255 characters")
    private String healthGoals;

    @Size(max = 2, message = "Country code must be 2 characters (ISO 3166-1 alpha-2)")
    private String countryCode;

    @Size(max = 4, message = "Currency code must be at most 4 characters (ISO 4217)")
    private String currencyCode;

    @Size(max = 20, message = "Locale must be at most 20 characters")
    private String locale;

    @Size(max = 20, message = "Cooking skill must be at most 20 characters")
    private String cookingSkill;

    @Min(value = 1, message = "Household size must be at least 1")
    @Max(value = 20, message = "Household size must be at most 20")
    private Integer householdSize;
}
