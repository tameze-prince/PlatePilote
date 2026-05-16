package com.platepilote.platepilote.grocery.domain.repository;

/**
 * GROCERY ITEM REPOSITORY - DATABASE ACCESS FOR GROCERY ITEMS
 * =============================================================
 * 
 * METHODS:
 * 
 * 1. findByGroceryListIdOrderBySortOrderAsc(groceryListId)
 *    -> Get all items in a grocery list, ordered by display order
 *    SQL: SELECT * FROM grocery_items WHERE grocery_list_id = ? ORDER BY sort_order ASC
 * 
 * 2. deleteByGroceryListId(groceryListId)
 *    -> Delete all items in a grocery list (used when deleting a list)
 */

import com.platepilote.platepilote.grocery.domain.entity.GroceryItem;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface GroceryItemRepository extends JpaRepository<GroceryItem, UUID> {

    /**
     * Get all items in a grocery list, sorted by display order.
     * Items are grouped by category (produce, dairy, meat, etc.) for easier shopping.
     */
    List<GroceryItem> findByGroceryListIdOrderBySortOrderAsc(UUID groceryListId);

    /**
     * Delete all items in a grocery list.
     * Called when a grocery list is deleted to clean up orphaned items.
     */
    void deleteByGroceryListId(UUID groceryListId);
}
