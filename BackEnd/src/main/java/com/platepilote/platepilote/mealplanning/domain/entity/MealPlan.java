package com.platepilote.platepilote.mealplanning.domain.entity;

/**
 * MEAL PLAN ENTITY - DATABASE TABLE: meal_plans
 * ================================================
 * 
 * WHAT IT IS:
 * Represents a meal plan (e.g., "Week of Jan 15-21").
 * A meal plan contains multiple MealPlanEntries (one meal per day).
 * 
 * EXAMPLE DATA:
 * - userId: "user-123", name: "Week 3 January", startDate: "2024-01-15", endDate: "2024-01-21", status: "ACTIVE"
 * 
 * STATUS VALUES:
 * - "DRAFT": Plan is being created, not yet finalized
 * - "ACTIVE": Plan is currently in use
 * - "COMPLETED": Plan period has passed
 * - "CANCELLED": Plan was abandoned
 */

import com.platepilote.platepilote.common.kernel.BaseEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDate;
import java.util.UUID;

@Entity
@Table(name = "meal_plans")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class MealPlan extends BaseEntity {

    @Column(name = "user_id", nullable = false)
    private UUID userId;

    @Column(nullable = false)
    private String name;  // e.g., "Week 3 January", "Low Carb Week"

    @Column(name = "start_date", nullable = false)
    private LocalDate startDate;  // First day of the meal plan

    @Column(name = "end_date", nullable = false)
    private LocalDate endDate;  // Last day of the meal plan

    @Column(nullable = false)
    private String status = "DRAFT";  // "DRAFT", "ACTIVE", "COMPLETED", "CANCELLED"

    @Column(nullable = false)
    @Builder.Default
    private String mode = "STANDARD";  // "STANDARD", "WASTELESS", "ENDOFMONTH", "BUSYWEEK", "FAMILY"
}
