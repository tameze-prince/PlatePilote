package com.platepilote.platepilote.userprofile.domain.entity;

/**
 * USER PROFILE ENTITY - DATABASE TABLE: user_profiles
 * =====================================================
 * 
 * WHAT IT IS:
 * Stores additional user information beyond basic authentication.
 * Contains physical attributes and health goals used for personalized recommendations.
 * 
 * RELATIONSHIP TO USER:
 * Each User has exactly one UserProfile (one-to-one relationship).
 * The userId field links this profile to the User entity.
 * 
 * FIELDS:
 * - userId: Links to the User entity (foreign key)
 * - dateOfBirth: Used to calculate age-based nutritional needs
 * - gender: Affects calorie and nutrient calculations
 * - heightCm: Height in centimeters (e.g., 175.5)
 * - weightKg: Weight in kilograms (e.g., 70.2)
 * - activityLevel: Sedentary, Light, Moderate, Active, Very Active
 * - healthGoals: Free text (e.g., "Lose weight", "Build muscle", "Maintain")
 */

import com.platepilote.platepilote.common.kernel.AuditableEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.UUID;

@Entity
@Table(name = "user_profiles")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UserProfile extends AuditableEntity {

    @Column(name = "user_id", nullable = false, unique = true)
    private UUID userId;

    @Column(name = "date_of_birth")
    private LocalDate dateOfBirth;

    @Column(name = "gender")
    private String gender;

    @Column(name = "height_cm")
    private BigDecimal heightCm;

    @Column(name = "weight_kg")
    private BigDecimal weightKg;

    @Column(name = "activity_level")
    private String activityLevel;

    @Column(name = "health_goals", columnDefinition = "TEXT")
    private String healthGoals;
}
