package com.platepilote.platepilote.mealplanning.domain.entity;

/**
 * MEAL PLAN ENTRY ENTITY - DATABASE TABLE: meal_plan_entries
 * =============================================================
 * 
 * WHAT IT IS:
 * Represents one meal in a meal plan (e.g., "Monday Dinner: Chicken Stir Fry").
 * 
 * RELATIONSHIP:
 * Many-to-one with MealPlan (each entry belongs to one meal plan).
 * 
 * EXAMPLE DATA:
 * - mealPlanId: "plan-123", recipeId: "recipe-456", mealDate: "2024-01-15", mealType: "Dinner", servings: 2
 * 
 * FIELDS:
 * - mealPlanId: Which meal plan this entry belongs to
 * - recipeId: Which recipe is being served
 * - mealDate: What day this meal is planned for
 * - mealType: "Breakfast", "Lunch", "Dinner", "Snack"
 * - servings: How many servings to prepare
 * - notes: Optional notes (e.g., "Double the recipe for leftovers")
 */

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

@Entity
@Table(name = "meal_plan_entries")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class MealPlanEntry {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(name = "meal_plan_id", nullable = false)
    private UUID mealPlanId;

    @Column(name = "recipe_id", nullable = false)
    private UUID recipeId;

    @Column(name = "meal_date", nullable = false)
    private LocalDate mealDate;  // Which day this meal is planned for

    @Column(name = "meal_type", nullable = false)
    private String mealType;  // "Breakfast", "Lunch", "Dinner", "Snack"

    @Column(nullable = false)
    private Integer servings = 1;  // How many servings to prepare

    @Column(columnDefinition = "TEXT")
    private String notes;  // Optional notes
}
