package com.platepilote.platepilote.grocery.domain.entity;

/**
 * GROCERY ITEM ENTITY - DATABASE TABLE: grocery_items
 * ======================================================
 * 
 * WHAT IT IS:
 * Represents one item on a shopping list (e.g., "Milk - 2 liters").
 * 
 * EXAMPLE DATA:
 * - groceryListId: "list-123", name: "Milk", category: "dairy", quantity: 2, unit: "liter", estimatedPrice: 3.50, checked: false
 * 
 * FIELDS:
 * - groceryListId: Which shopping list this item belongs to
 * - name: Item name
 * - category: Store section (e.g., "dairy", "produce", "meat") for organizing the list
 * - quantity: How much to buy
 * - unit: Unit of measurement
 * - estimatedPrice: Expected cost (for budget tracking)
 * - checked: Whether the item has been purchased (ticked off in the app)
 * - notes: Optional note (e.g., "Get the organic brand")
 * - sortOrder: Display order in the list (grouped by category)
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

import java.math.BigDecimal;
import java.util.UUID;

@Entity
@Table(name = "grocery_items")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class GroceryItem {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(name = "grocery_list_id", nullable = false)
    private UUID groceryListId;

    @Column(nullable = false)
    private String name;

    private String category;  // Store section: "dairy", "produce", "meat", "bakery", etc.

    @Column(nullable = false)
    private BigDecimal quantity;

    @Column(nullable = false)
    private String unit;

    @Column(name = "estimated_price")
    private BigDecimal estimatedPrice;  // Expected cost for budget tracking

    @Column(nullable = false)
    private Boolean checked = false;  // true = item has been purchased

    @Column(columnDefinition = "TEXT")
    private String notes;

    @Column(name = "sort_order")
    private Integer sortOrder = 0;  // Display order in the list
}
