package com.platepilote.platepilote.recipes.domain.entity;

/**
 * RECIPE STEP ENTITY - DATABASE TABLE: recipe_steps
 * ====================================================
 * 
 * WHAT IT IS:
 * Represents one step/instruction in a recipe.
 * 
 * RELATIONSHIP:
 * Many-to-one with Recipe (each step belongs to one recipe).
 * 
 * EXAMPLE DATA:
 * - recipeId: "recipe-123", stepNumber: 1, instruction: "Heat oil in a large pan", durationMinutes: 2
 * - recipeId: "recipe-123", stepNumber: 2, instruction: "Add chicken and cook until golden", durationMinutes: 10
 * 
 * FIELDS:
 * - recipe: The recipe this step belongs to (foreign key)
 * - stepNumber: Order of the step (1, 2, 3, ...)
 * - instruction: The actual cooking instruction
 * - durationMinutes: How long this step takes (optional)
 */

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.UUID;

@Entity
@Table(name = "recipe_steps")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class RecipeStep {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "recipe_id", nullable = false)
    private Recipe recipe;

    @Column(name = "step_number", nullable = false)
    private Integer stepNumber;  // 1, 2, 3, ... (order of steps)

    @Column(name = "instruction", nullable = false, columnDefinition = "TEXT")
    private String instruction;  // The actual cooking instruction

    @Column(name = "duration_minutes")
    private Integer durationMinutes;  // How long this step takes (optional)
}
