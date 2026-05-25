package com.platepilote.platepilote.grocery.domain.repository;

/**
 * GROCERY LIST REPOSITORY - DATABASE ACCESS FOR GROCERY LISTS
 * ==============================================================
 * 
 * METHOD:
 * - findByUserIdAndDeletedAtIsNull(userId, pageable)
 *   -> Get all grocery lists for a user (paginated)
 */

import com.platepilote.platepilote.grocery.domain.entity.GroceryList;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.UUID;

@Repository
public interface GroceryListRepository extends JpaRepository<GroceryList, UUID> {

    /**
     * Get all active (non-deleted) grocery lists for a user with pagination.
     */
    Page<GroceryList> findByUserIdAndDeletedAtIsNull(UUID userId, Pageable pageable);

    Page<GroceryList> findByUserIdAndStatusAndDeletedAtIsNull(UUID userId, String status, Pageable pageable);
}
