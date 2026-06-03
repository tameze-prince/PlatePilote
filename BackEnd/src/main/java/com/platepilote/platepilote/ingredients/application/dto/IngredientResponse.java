package com.platepilote.platepilote.ingredients.application.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

/**
 * Réponse contenant les informations détaillées d'un ingrédient.
 * <p>
 * Inclut les métadonnées (nom, catégorie, unité), les valeurs nutritionnelles
 * pour 100 g, les indicateurs alimentaires (végétalien, sans gluten, etc.)
 * et les informations de source (USDA, Open Food Facts).
 * </p>
 */
@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class IngredientResponse implements Serializable {

    private static final long serialVersionUID = 1L;

    /** Identifiant unique de l'ingrédient. */
    private UUID id;

    /** Nom canonique normalisé de l'ingrédient. */
    private String canonicalName;

    /** Slug unique pour l'URL. */
    private String slug;

    /** Catégorie de l'ingrédient (ex : "Légume", "Épice"). */
    private String category;

    /** Description textuelle de l'ingrédient. */
    private String description;

    /** Unité de mesure par défaut (ex : "g", "ml", "pièce"). */
    private String defaultUnit;

    /** Calories pour 100 g. */
    private Double caloriesPer100g;

    /** Protéines pour 100 g. */
    private Double proteinPer100g;

    /** Glucides pour 100 g. */
    private Double carbohydratesPer100g;

    /** Lipides pour 100 g. */
    private Double fatPer100g;

    /** Fibres pour 100 g. */
    private Double fiberPer100g;

    /** Sucres pour 100 g. */
    private Double sugarPer100g;

    /** Sodium en mg pour 100 g. */
    private Double sodiumMgPer100g;

    /** Cholestérol en mg pour 100 g. */
    private Double cholesterolMgPer100g;

    /** Contient du gluten. */
    private Boolean containsGluten;

    /** Contient du lactose. */
    private Boolean containsLactose;

    /** Contient des fruits à coque. */
    private Boolean containsNuts;

    /** Contient du soja. */
    private Boolean containsSoy;

    /** Contient des œufs. */
    private Boolean containsEggs;

    /** Contient du poisson. */
    private Boolean containsFish;

    /** Contient des crustacés. */
    private Boolean containsShellfish;

    /** Adapté aux régimes végétaliens. */
    private Boolean vegan;

    /** Adapté aux régimes végétariens. */
    private Boolean vegetarian;

    /** Compatible avec l'alimentation halal. */
    private Boolean halalFriendly;

    /** Compatible avec l'alimentation kasher. */
    private Boolean kosherFriendly;

    /** Faible en glucides. */
    private Boolean lowCarb;

    /** Compatible avec le régime cétogène. */
    private Boolean ketoFriendly;

    /** Prix moyen au kilogramme. */
    private BigDecimal averagePricePerKg;

    /** Identifiant USDA FDC (Food Data Central). */
    private String usdaFdcId;

    /** Code Open Food Facts. */
    private String openFoodFactsCode;

    /** Nom de la source des données. */
    private String sourceName;

    /** URL de la source des données. */
    private String sourceUrl;

    /** Date de création de l'enregistrement. */
    private Instant createdAt;

    /** Date de dernière modification. */
    private Instant updatedAt;
}
