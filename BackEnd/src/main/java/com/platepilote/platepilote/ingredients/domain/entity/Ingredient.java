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

/**
 * Entité représentant un ingrédient alimentaire.
 * <p>
 * Chaque ingrédient possède un nom canonique unique, un slug,
 * des valeurs nutritionnelles pour 100 g, des indicateurs alimentaires
 * (allergènes, régimes) et des informations de source (USDA, Open Food Facts).
 * </p>
 */
@Entity
@Table(name = "ingredients")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Ingredient extends BaseEntity {

    /** Nom canonique normalisé unique de l'ingrédient. */
    @Column(name = "canonical_name", nullable = false, unique = true)
    private String canonicalName;

    /** Slug unique pour l'identification dans les URL. */
    @Column(nullable = false, unique = true)
    private String slug;

    /** Catégorie de l'ingrédient (ex : "Légume", "Épice", "Fruit"). */
    @Column(nullable = false)
    private String category;

    /** Description textuelle de l'ingrédient. */
    @Column(columnDefinition = "TEXT")
    private String description;

    /** Unité de mesure par défaut (ex : "g", "ml", "pièce"). */
    @Column(name = "default_unit", nullable = false)
    private String defaultUnit;

    /** Calories pour 100 grammes. */
    @Column(name = "calories_per_100g")
    private Double caloriesPer100g;

    /** Protéines pour 100 grammes. */
    @Column(name = "protein_per_100g")
    private Double proteinPer100g;

    /** Glucides pour 100 grammes. */
    @Column(name = "carbohydrates_per_100g")
    private Double carbohydratesPer100g;

    /** Lipides pour 100 grammes. */
    @Column(name = "fat_per_100g")
    private Double fatPer100g;

    /** Fibres alimentaires pour 100 grammes. */
    @Column(name = "fiber_per_100g")
    private Double fiberPer100g;

    /** Sucres pour 100 grammes. */
    @Column(name = "sugar_per_100g")
    private Double sugarPer100g;

    /** Sodium en milligrammes pour 100 grammes. */
    @Column(name = "sodium_mg_per_100g")
    private Double sodiumMgPer100g;

    /** Cholestérol en milligrammes pour 100 grammes. */
    @Column(name = "cholesterol_mg_per_100g")
    private Double cholesterolMgPer100g;

    /** Indique si l'ingrédient contient du gluten. */
    @Column(name = "contains_gluten")
    private Boolean containsGluten;

    /** Indique si l'ingrédient contient du lactose. */
    @Column(name = "contains_lactose")
    private Boolean containsLactose;

    /** Indique si l'ingrédient contient des fruits à coque. */
    @Column(name = "contains_nuts")
    private Boolean containsNuts;

    /** Indique si l'ingrédient contient du soja. */
    @Column(name = "contains_soy")
    private Boolean containsSoy;

    /** Indique si l'ingrédient contient des œufs. */
    @Column(name = "contains_eggs")
    private Boolean containsEggs;

    /** Indique si l'ingrédient contient du poisson. */
    @Column(name = "contains_fish")
    private Boolean containsFish;

    /** Indique si l'ingrédient contient des crustacés. */
    @Column(name = "contains_shellfish")
    private Boolean containsShellfish;

    /** Indique si l'ingrédient est adapté aux régimes végétaliens. */
    private Boolean vegan;

    /** Indique si l'ingrédient est adapté aux régimes végétariens. */
    private Boolean vegetarian;

    /** Indique si l'ingrédient est compatible avec l'alimentation halal. */
    @Column(name = "halal_friendly")
    private Boolean halalFriendly;

    /** Indique si l'ingrédient est compatible avec l'alimentation kasher. */
    @Column(name = "kosher_friendly")
    private Boolean kosherFriendly;

    /** Indique si l'ingrédient est faible en glucides. */
    @Column(name = "low_carb")
    private Boolean lowCarb;

    /** Indique si l'ingrédient est compatible avec le régime cétogène. */
    @Column(name = "keto_friendly")
    private Boolean ketoFriendly;

    /** Prix moyen au kilogramme. */
    @Column(name = "average_price_per_kg", precision = 10, scale = 2)
    private BigDecimal averagePricePerKg;

    /** Identifiant USDA FDC (Food Data Central). */
    @Column(name = "usda_fdc_id")
    private String usdaFdcId;

    /** Code Open Food Facts. */
    @Column(name = "open_food_facts_code")
    private String openFoodFactsCode;

    /** Nom de la source des données (ex : "USDA", "Open Food Facts"). */
    @Column(name = "source_name")
    private String sourceName;

    /** URL de la source des données. */
    @Column(name = "source_url")
    private String sourceUrl;
}
