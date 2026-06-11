package com.platepilote.platepilote.ai.provider.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

/**
 * Response DTO for ingredient substitution suggestions.
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class SubstitutionResponse {

    private String suggestedIngredient;

    private BigDecimal suggestedQuantity;

    private String suggestedUnit;

    private BigDecimal estimatedCostDifference;  // Positive = more expensive

    private double similarityScore;  // 0.0 to 1.0, how similar to original

    private String reason;  // Why this substitution works

    private List<String> useCases;  // Where this substitution works best

    private Map<String, Object> nutritionComparison;  // Compare macros

    private List<String> precautions;  // Cooking tips, allergies, etc.

    private int ranking;  // Preference ranking (1 = best match)
}