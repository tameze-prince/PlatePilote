package com.platepilote.platepilote.recipes.domain.entity;

/**
 * RECIPE INGREDIENT ENTITY - DATABASE TABLE: recipe_ingredients
 * ===============================================================
 * 
 * WHAT IT IS:
 * Represents one ingredient in a recipe.
 * 
 * RELATIONSHIP:
 * Many-to-one with Recipe (each ingredient belongs to one recipe).
 * 
 * EXAMPLE DATA:
 * - recipeId: "recipe-123", name: "Chicken Breast", quantity: 500, unit: "g", sortOrder: 1
 * - recipeId: "recipe-123", name: "Soy Sauce", quantity: 2, unit: "tbsp", sortOrder: 2
 * 
 * FIELDS:
 * - recipe: The recipe this ingredient belongs to (foreign key)
 * - name: Ingredient name
 * - quantity: Amount needed (e.g., 500, 2, 1.5)
 * - unit: Unit of measurement (g, kg, ml, tbsp, cup, piece, etc.)
 * - notes: Optional note (e.g., "diced", "room temperature")
 * - sortOrder: Display order in the ingredient list
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

import java.math.BigDecimal;
import java.util.UUID;

@Entity
@Table(name = "recipe_ingredients")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class RecipeIngredient {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)  // Lazy load: don't fetch the recipe until needed
    @JoinColumn(name = "recipe_id", nullable = false)
    private Recipe recipe;

    @Column(nullable = false)
    private String name;

    @Column(nullable = false)
    private BigDecimal quantity;

    @Column(nullable = false)
    private String unit;

    @Column(columnDefinition = "TEXT")
    private String notes;  // e.g., "diced", "finely chopped", "room temperature"

    @Column(name = "sort_order")
    private Integer sortOrder = 0;  // Order in which ingredients are displayed

    @Column(name = "ingredient_id")
    private UUID ingredientId;
}
