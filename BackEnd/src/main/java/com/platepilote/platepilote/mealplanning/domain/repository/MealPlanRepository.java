package com.platepilote.platepilote.mealplanning.domain.repository;

/**
 * MEAL PLAN REPOSITORY - DATABASE ACCESS FOR MEAL PLANS
 * =======================================================
 * 
 * METHOD:
 * - findByUserIdAndDeletedAtIsNull(userId, pageable)
 *   -> Get all meal plans for a user (paginated)
 */

import com.platepilote.platepilote.mealplanning.domain.entity.MealPlan;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.UUID;

@Repository
public interface MealPlanRepository extends JpaRepository<MealPlan, UUID> {

    /**
     * Get all active (non-deleted) meal plans for a user with pagination.
     */
    Page<MealPlan> findByUserIdAndDeletedAtIsNull(UUID userId, Pageable pageable);
}
