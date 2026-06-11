package com.platepilote.platepilote.ai.provider.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.util.List;

/**
 * Request DTO for ingredient substitution suggestions.
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class SubstitutionRequest {

    private String originalIngredient;

    private BigDecimal quantity;

    private String unit;

    private List<String> dietaryRestrictions;  // Avoid ingredients with these

    private List<String> allergies;  // Must avoid these allergens

    private String substitutionGoal;  // "healthier", "cheaper", "lower_carb", etc.

    private boolean preserveFlavor;  // Prioritize taste similarity

    private boolean preserveTexture;  // For baking/cooking

    private List<String> cuisineContext;  // "Italian", "Mexican", etc.
}