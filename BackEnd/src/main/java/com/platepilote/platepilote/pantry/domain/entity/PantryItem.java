package com.platepilote.platepilote.pantry.domain.entity;

/**
 * PANTRY ITEM ENTITY - DATABASE TABLE: pantry_items
 * ====================================================
 * 
 * WHAT IT IS:
 * Represents a food item in the user's pantry/fridge/freezer.
 * 
 * EXAMPLE DATA:
 * - name: "Chicken Breast", category: "meat", quantity: 500, unit: "g", expirationDate: "2024-01-20"
 * - name: "Milk", category: "dairy", quantity: 1, unit: "liter", expirationDate: "2024-01-18"
 * 
 * FIELDS:
 * - userId: Which user owns this pantry item
 * - name: Food item name
 * - category: Food category (fruits, vegetables, dairy, meat, etc.)
 * - quantity: Amount (e.g., 500, 1.5, 2)
 * - unit: Unit of measurement (g, kg, ml, liter, piece, etc.)
 * - expirationDate: When the item expires (used for notifications)
 * - deletedAt: Soft delete timestamp (inherited from BaseEntity)
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

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.UUID;

@Entity
@Table(name = "pantry_items")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PantryItem extends BaseEntity {

    @Column(name = "user_id", nullable = false)
    private UUID userId;

    @Column(nullable = false)
    private String name;

    private String category;  // e.g., "fruits", "dairy", "meat", "grains"

    @Column(nullable = false)
    private BigDecimal quantity;

    @Column(nullable = false)
    private String unit;  // e.g., "g", "kg", "ml", "liter", "piece"

    @Column(name = "expiration_date")
    private LocalDate expirationDate;

    @Column(name = "ingredient_id")
    private UUID ingredientId;
}
