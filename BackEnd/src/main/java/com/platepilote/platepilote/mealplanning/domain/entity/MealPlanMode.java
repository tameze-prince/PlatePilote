package com.platepilote.platepilote.mealplanning.domain.entity;

/**
 * Modes de fonctionnement d'un plan de repas.
 * <p>
 * Chaque mode adapte les recommandations de recettes et les contraintes
 * du plan (budget, temps, gaspillage alimentaire, etc.).
 * </p>
 */
public enum MealPlanMode {
    /** Mode standard : aucune contrainte particulière. */
    STANDARD,

    /** Mode anti-gaspillage : priorise l'utilisation des ingrédients existants. */
    WASTELESS,

    /** Mode fin de mois : optimise le budget restant. */
    ENDOFMONTH,

    /** Mode semaine chargée : privilégie les recettes rapides. */
    BUSYWEEK,

    /** Mode familial : adapté aux repas pour toute la famille. */
    FAMILY
}
