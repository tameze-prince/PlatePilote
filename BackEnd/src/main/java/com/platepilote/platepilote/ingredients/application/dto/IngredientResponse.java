package com.platepilote.platepilote.ingredients.application.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class IngredientResponse {

    private UUID id;
    private String canonicalName;
    private String slug;
    private String category;
    private String description;
    private String defaultUnit;

    private Double caloriesPer100g;
    private Double proteinPer100g;
    private Double carbohydratesPer100g;
    private Double fatPer100g;
    private Double fiberPer100g;
    private Double sugarPer100g;
    private Double sodiumMgPer100g;
    private Double cholesterolMgPer100g;

    private Boolean containsGluten;
    private Boolean containsLactose;
    private Boolean containsNuts;
    private Boolean containsSoy;
    private Boolean containsEggs;
    private Boolean containsFish;
    private Boolean containsShellfish;
    private Boolean vegan;
    private Boolean vegetarian;
    private Boolean halalFriendly;
    private Boolean kosherFriendly;
    private Boolean lowCarb;
    private Boolean ketoFriendly;

    private BigDecimal averagePricePerKg;
    private String usdaFdcId;
    private String openFoodFactsCode;
    private String sourceName;
    private String sourceUrl;

    private Instant createdAt;
    private Instant updatedAt;
}
