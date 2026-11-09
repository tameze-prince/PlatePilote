package com.platepilote.platepilote.grocery.domain.entity;

/**
 * Entité représentant un article dans une liste de courses.
 * <p>
 * Chaque article appartient à une liste (via {@code groceryListId}) et contient
 * les informations nécessaires à l'achat : nom, quantité, prix estimé, etc.
 * L'attribut {@code checked} indique si l'article a été acheté.
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
    @Column(nullable = false, length = 200)
    private String name;

    @Column(length = 100)
    private String category;  // Store section: "dairy", "produce", "meat", "bakery", etc.

    @Column(nullable = false, precision = 10, scale = 2)
    private BigDecimal quantity;

    @Column(nullable = false, length = 50)
    private String unit;

    @Column(name = "estimated_price", precision = 10, scale = 2)
    private BigDecimal estimatedPrice;  // Expected cost for budget tracking

    @Column(name = "price_confidence", precision = 4, scale = 3)
    private BigDecimal priceConfidence;

    @Column(nullable = false)
    private Boolean checked = false;  // true = item has been purchased

    @Column(columnDefinition = "TEXT")
    private String notes;

    @Column(name = "sort_order")
    private Integer sortOrder = 0;  // Display order in the list

    @Column(name = "ingredient_id")
    private UUID ingredientId;
}
