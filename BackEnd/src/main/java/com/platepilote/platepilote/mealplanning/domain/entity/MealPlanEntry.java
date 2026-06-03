package com.platepilote.platepilote.mealplanning.domain.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDate;
import java.util.UUID;

/**
 * Entité représentant un repas individuel dans un plan de repas.
 * <p>
 * Chaque entrée correspond à un repas planifié à une date donnée
 * (ex : "Lundi Dîner : Poulet stir-fry"). Elle référence une recette
 * et précise le type de repas, le nombre de portions et des notes optionnelles.
 * </p>
 */
@Entity
@Table(name = "meal_plan_entries")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class MealPlanEntry {

    /** Identifiant unique de l'entrée. */
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    /** Identifiant du plan de repas auquel cette entrée appartient. */
    @Column(name = "meal_plan_id", nullable = false)
    private UUID mealPlanId;

    /** Identifiant de la recette utilisée pour ce repas. */
    @Column(name = "recipe_id", nullable = false)
    private UUID recipeId;

    /** Date à laquelle ce repas est planifié. */
    @Column(name = "meal_date", nullable = false)
    private LocalDate mealDate;

    /** Type de repas : Breakfast, Lunch, Dinner, Snack. */
    @Column(name = "meal_type", nullable = false)
    private String mealType;

    /** Nombre de portions à préparer (défaut : 1). */
    @Column(nullable = false)
    private Integer servings = 1;

    /** Notes optionnelles (ex : "Doubler la recette pour les restes"). */
    @Column(columnDefinition = "TEXT")
    private String notes;
}
