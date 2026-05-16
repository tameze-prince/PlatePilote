package com.platepilote.platepilote.grocery.domain.entity;

/**
 * GROCERY LIST ENTITY - DATABASE TABLE: grocery_lists
 * ======================================================
 * 
 * WHAT IT IS:
 * Represents a shopping list (e.g., "Weekly Shopping", "BBQ Party List").
 * 
 * EXAMPLE DATA:
 * - userId: "user-123", name: "Weekly Shopping", status: "ACTIVE"
 * 
 * STATUS VALUES:
 * - "ACTIVE": Currently being used for shopping
 * - "COMPLETED": Shopping trip is done
 * - "ARCHIVED": Old list kept for reference
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

import java.util.UUID;

@Entity
@Table(name = "grocery_lists")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class GroceryList extends BaseEntity {

    @Column(name = "user_id", nullable = false)
    private UUID userId;

    @Column(nullable = false)
    private String name;  // e.g., "Weekly Shopping", "BBQ Party List"

    @Column(nullable = false)
    private String status = "ACTIVE";  // "ACTIVE", "COMPLETED", "ARCHIVED"
}
