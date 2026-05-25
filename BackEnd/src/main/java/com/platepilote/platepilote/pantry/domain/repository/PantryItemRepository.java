package com.platepilote.platepilote.pantry.domain.repository;

/**
 * PANTRY ITEM REPOSITORY - DATABASE ACCESS FOR PANTRY ITEMS
 * ===========================================================
 * 
 * METHODS:
 * 
 * 1. findByUserIdAndDeletedAtIsNull(userId, pageable)
 *    -> Get all active pantry items for a user (paginated)
 *    SQL: SELECT * FROM pantry_items WHERE ouruser_id = ? AND deleted_at IS NULL LIMIT ? OFFSET ?
 * 
 * 2. findByUserIdAndCategoryAndDeletedAtIsNull(userId, category)
 *    -> Get pantry items filtered by category
 *    SQL: SELECT * FROM pantry_items WHERE ouruser_id = ? AND category = ? AND deleted_at IS NULL
 * 
 * 3. findExpiringItems(userId, date)
 *    -> Get items expiring on or before a specific date
 *    SQL: SELECT * FROM pantry_items WHERE ouruser_id = ? AND deleted_at IS NULL AND expiration_date <= ?
 *    Used to send "item expiring soon" notifications
 * 
 * 4. searchByUserIdAndQuery(userId, query)
 *    -> Search pantry items by name (case-insensitive partial match)
 *    SQL: SELECT * FROM pantry_items WHERE ouruser_id = ? AND deleted_at IS NULL AND LOWER(name) LIKE '%query%'
 */

import com.platepilote.platepilote.pantry.domain.entity.PantryItem;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.Collection;
import java.util.List;
import java.util.Set;
import java.util.UUID;

@Repository
public interface PantryItemRepository extends JpaRepository<PantryItem, UUID> {

    /**
     * Get all active (non-deleted) pantry items for a user with pagination.
     */
    Page<PantryItem> findByUserIdAndDeletedAtIsNull(UUID userId, Pageable pageable);

    /**
     * Get pantry items filtered by category (e.g., all dairy items).
     */
    List<PantryItem> findByUserIdAndCategoryAndDeletedAtIsNull(UUID userId, String category);

    /**
     * Find items that are expiring soon (on or before the given date).
     * Used to trigger expiration notifications.
     */
    @Query("SELECT p FROM PantryItem p WHERE p.userId = :userId AND p.deletedAt IS NULL AND p.expirationDate <= :date")
    List<PantryItem> findExpiringItems(@Param("userId") UUID userId, @Param("date") LocalDate date);

    /**
     * Search pantry items by name (partial, case-insensitive match).
     */
    @Query("SELECT p FROM PantryItem p WHERE p.userId = :userId AND p.deletedAt IS NULL AND LOWER(p.name) LIKE LOWER(CONCAT('%', :query, '%'))")
    List<PantryItem> searchByUserIdAndQuery(@Param("userId") UUID userId, @Param("query") String query);

    @Query("SELECT p FROM PantryItem p WHERE p.userId = :userId AND p.deletedAt IS NULL AND p.ingredientId IN :ingredientIds")
    List<PantryItem> findByUserIdAndIngredientIdIn(@Param("userId") UUID userId, @Param("ingredientIds") Collection<UUID> ingredientIds);
}
