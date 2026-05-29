package com.platepilote.platepilote.recipes.domain.repository;

/**
 * RECIPE REPOSITORY - DATABASE ACCESS FOR RECIPES
 * ==================================================
 * 
 * METHODS:
 * 
 * 1. findByIsPublicTrueAndDeletedAtIsNull(pageable)
 *    -> Get all public recipes (for browsing)
 *    SQL: SELECT * FROM recipes WHERE is_public = true AND deleted_at IS NULL
 * 
 * 2. findByUserIdAndDeletedAtIsNull(userId, pageable)
 *    -> Get a user's personal recipes
 *    SQL: SELECT * FROM recipes WHERE user_id = ? AND deleted_at IS NULL
 * 
 * 3. findByCuisineTypeAndIsPublicTrueAndDeletedAtIsNull(cuisineType, pageable)
 *    -> Filter public recipes by cuisine type (e.g., "Italian")
 * 
 * 4. findByMealTypeAndIsPublicTrueAndDeletedAtIsNull(mealType, pageable)
 *    -> Filter public recipes by meal type (e.g., "Breakfast")
 * 
 * 5. searchPublicRecipes(query, pageable)
 *    -> Search recipes by name or description (case-insensitive)
 *    SQL: SELECT * FROM recipes WHERE is_public = true AND deleted_at IS NULL 
 *         AND (LOWER(name) LIKE '%query%' OR LOWER(description) LIKE '%query%')
 * 
 * 6. findByIds(ids)
 *    -> Get recipes by a list of IDs (used by recommendation engine)
 */

import com.platepilote.platepilote.recipes.domain.entity.Recipe;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface RecipeRepository extends JpaRepository<Recipe, UUID> {

    /**
     * Get all public recipes (visible to everyone) with pagination.
     */
    Page<Recipe> findByIsPublicTrueAndDeletedAtIsNull(Pageable pageable);

    @Query("SELECT r FROM Recipe r WHERE r.isPublic = true AND r.deletedAt IS NULL " +
           "AND r.enabled = true AND r.imageUrl IS NOT NULL " +
           "AND (r.caloriesPerServing IS NULL OR r.caloriesPerServing > 0) " +
           "ORDER BY r.verified DESC, r.confidenceScore DESC, r.updatedAt DESC")
    Page<Recipe> findDashboardRecipes(Pageable pageable);

    /**
     * Get a specific user's personal recipes.
     */
    Page<Recipe> findByUserIdAndDeletedAtIsNull(UUID userId, Pageable pageable);

    /**
     * Filter public recipes by cuisine type (e.g., "Italian", "Mexican").
     */
    Page<Recipe> findByCuisineTypeAndIsPublicTrueAndDeletedAtIsNull(String cuisineType, Pageable pageable);

    /**
     * Filter public recipes by meal type (e.g., "Breakfast", "Dinner").
     */
    Page<Recipe> findByMealTypeAndIsPublicTrueAndDeletedAtIsNull(String mealType, Pageable pageable);

    /**
     * Search public recipes by name or description.
     * Uses LIKE for partial matching (e.g., "chicken" matches "Chicken Stir Fry").
     */
    @Query("SELECT r FROM Recipe r WHERE r.isPublic = true AND r.deletedAt IS NULL AND " +
           "LOWER(r.name) LIKE LOWER(CONCAT('%', :query, '%')) OR " +
           "LOWER(r.description) LIKE LOWER(CONCAT('%', :query, '%'))")
    Page<Recipe> searchPublicRecipes(@Param("query") String query, Pageable pageable);

    /**
     * Get recipes by a list of IDs.
     * Used by the recommendation engine to fetch recommended recipes.
     */
    @Query("SELECT r FROM Recipe r WHERE r.id IN :ids AND r.deletedAt IS NULL")
    List<Recipe> findByIds(@Param("ids") List<UUID> ids);

    @Query("SELECT r FROM Recipe r WHERE r.isPublic = true AND r.deletedAt IS NULL AND r.totalTimeMinutes <= :maxTime")
    Page<Recipe> findQuickMeals(@Param("maxTime") Integer maxTime, Pageable pageable);

    @Query("SELECT r FROM Recipe r WHERE r.isPublic = true AND r.deletedAt IS NULL AND " +
           "(:cuisine IS NULL OR r.cuisineType = :cuisine) AND " +
           "(r.estimatedCost IS NULL OR r.estimatedCost <= :maxCost)")
    List<Recipe> findByFilters(@Param("cuisine") String cuisine, @Param("maxCost") java.math.BigDecimal maxCost, Pageable pageable);
}
