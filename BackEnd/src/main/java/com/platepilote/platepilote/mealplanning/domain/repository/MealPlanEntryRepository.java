package com.platepilote.platepilote.mealplanning.domain.repository;

/**
 * MEAL PLAN ENTRY REPOSITORY - DATABASE ACCESS FOR MEAL PLAN ENTRIES
 * ====================================================================
 * 
 * METHODS:
 * 
 * 1. findByMealPlanId(mealPlanId)
 *    -> Get all entries in a meal plan
 *    SQL: SELECT * FROM meal_plan_entries WHERE meal_plan_id = ?
 * 
 * 2. findByMealPlanIdAndMealDate(mealPlanId, mealDate)
 *    -> Get all meals planned for a specific day
 *    SQL: SELECT * FROM meal_plan_entries WHERE meal_plan_id = ? AND meal_date = ?
 *    Example: Get all meals for Monday (Breakfast, Lunch, Dinner)
 */

import com.platepilote.platepilote.mealplanning.domain.entity.MealPlanEntry;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

@Repository
public interface MealPlanEntryRepository extends JpaRepository<MealPlanEntry, UUID> {

    /**
     * Get all entries (meals) in a specific meal plan.
     */
    List<MealPlanEntry> findByMealPlanId(UUID mealPlanId);

    /**
     * Get all meals planned for a specific date within a meal plan.
     * Returns Breakfast, Lunch, Dinner, etc. for that day.
     */
    List<MealPlanEntry> findByMealPlanIdAndMealDate(UUID mealPlanId, LocalDate mealDate);
}
