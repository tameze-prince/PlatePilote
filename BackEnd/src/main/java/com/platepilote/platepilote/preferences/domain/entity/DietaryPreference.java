package com.platepilote.platepilote.preferences.domain.entity;

/**
 * DIETARY PREFERENCE ENTITY - DATABASE TABLE: dietary_preferences
 * =================================================================
 * 
 * WHAT IT IS:
 * Stores a user's dietary preferences (e.g., vegetarian, vegan, keto).
 * 
 * EXAMPLE DATA:
 * - userId: "user-123", dietType: "vegetarian"
 * - userId: "user-123", dietType: "gluten-free"
 * 
 * A user can have MULTIPLE dietary preferences (one-to-many relationship).
 * These are used by the RecommendationEngine to filter recipes.
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
@Table(name = "dietary_preferences")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class DietaryPreference extends BaseEntity {

    @Column(name = "user_id", nullable = false)
    private UUID userId;

    @Column(name = "diet_type", nullable = false)
    private String dietType;  // e.g., "vegetarian", "vegan", "keto", "paleo"
}
