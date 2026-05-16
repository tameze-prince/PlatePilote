package com.platepilote.platepilote.preferences.domain.entity;

/**
 * ALLERGY ENTITY - DATABASE TABLE: allergies
 * =============================================
 * 
 * WHAT IT IS:
 * Stores a user's food allergies.
 * 
 * EXAMPLE DATA:
 * - userId: "user-123", allergen: "peanuts", severity: "severe"
 * - userId: "user-123", allergen: "shellfish", severity: "moderate"
 * 
 * WHY SEVERITY MATTERS:
 * - "severe" -> Completely exclude recipes containing this allergen
 * - "moderate" -> Warn the user but allow them to see the recipe
 * - "mild" -> Just show a note on the recipe
 */

import com.platepilote.platepilote.common.kernel.BaseEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.UUID;

@Entity
@Table(name = "allergies")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Allergy extends BaseEntity {

    @Column(name = "user_id", nullable = false)
    private UUID userId;

    @Column(name = "allergen", nullable = false)
    private String allergen;  // e.g., "peanuts", "shellfish", "dairy"

    @Column(name = "severity")
    private String severity;  // "mild", "moderate", "severe"
}
