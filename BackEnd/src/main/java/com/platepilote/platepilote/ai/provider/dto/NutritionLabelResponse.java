package com.platepilote.platepilote.ai.provider.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

/**
 * Response DTO for nutrition label parsing.
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class NutritionLabelResponse {

    private String productName;

    private String brand;

    private String servingSize;

    private int servingsPerContainer;

    private BigDecimal servingSizeGrams;  // Numeric serving size

    // Per serving values
    private int calories;

    private BigDecimal totalFat;  // grams

    private BigDecimal saturatedFat;

    private BigDecimal transFat;

    private BigDecimal cholesterol;  // mg

    private BigDecimal sodium;  // mg

    private BigDecimal totalCarbohydrates;  // grams

    private BigDecimal dietaryFiber;

    private BigDecimal totalSugars;

    private BigDecimal addedSugars;

    private BigDecimal protein;  // grams

    // Vitamins and minerals (% daily value)
    private BigDecimal vitaminD;  // % DV
    private BigDecimal calcium;
    private BigDecimal iron;
    private BigDecimal potassium;

    private boolean isVerified;  // Cross-referenced with known database

    private String dataSource;  // "parsed", "verified_db", etc.

    private String providerUsed;
}