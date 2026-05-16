package com.platepilote.platepilote.ingredients.domain.entity;

import com.platepilote.platepilote.common.kernel.BaseEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;

@Entity
@Table(name = "ingredients")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Ingredient extends BaseEntity {

    @Column(name = "canonical_name", nullable = false, unique = true)
    private String canonicalName;

    @Column(nullable = false, unique = true)
    private String slug;

    @Column(nullable = false)
    private String category;

    @Column(columnDefinition = "TEXT")
    private String description;

    @Column(name = "default_unit", nullable = false)
    private String defaultUnit;

    @Column(name = "calories_per_100g")
    private Double caloriesPer100g;

    @Column(name = "protein_per_100g")
    private Double proteinPer100g;

    @Column(name = "carbohydrates_per_100g")
    private Double carbohydratesPer100g;

    @Column(name = "fat_per_100g")
    private Double fatPer100g;

    @Column(name = "fiber_per_100g")
    private Double fiberPer100g;

    @Column(name = "sugar_per_100g")
    private Double sugarPer100g;

    @Column(name = "sodium_mg_per_100g")
    private Double sodiumMgPer100g;

    @Column(name = "cholesterol_mg_per_100g")
    private Double cholesterolMgPer100g;

    @Column(name = "contains_gluten")
    private Boolean containsGluten;

    @Column(name = "contains_lactose")
    private Boolean containsLactose;

    @Column(name = "contains_nuts")
    private Boolean containsNuts;

    @Column(name = "contains_soy")
    private Boolean containsSoy;

    @Column(name = "contains_eggs")
    private Boolean containsEggs;

    @Column(name = "contains_fish")
    private Boolean containsFish;

    @Column(name = "contains_shellfish")
    private Boolean containsShellfish;

    private Boolean vegan;
    private Boolean vegetarian;

    @Column(name = "halal_friendly")
    private Boolean halalFriendly;

    @Column(name = "kosher_friendly")
    private Boolean kosherFriendly;

    @Column(name = "low_carb")
    private Boolean lowCarb;

    @Column(name = "keto_friendly")
    private Boolean ketoFriendly;

    @Column(name = "average_price_per_kg", precision = 10, scale = 2)
    private BigDecimal averagePricePerKg;

    @Column(name = "usda_fdc_id")
    private String usdaFdcId;

    @Column(name = "open_food_facts_code")
    private String openFoodFactsCode;

    @Column(name = "source_name")
    private String sourceName;

    @Column(name = "source_url")
    private String sourceUrl;
}
