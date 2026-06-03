package com.platepilote.platepilote.recipes.domain.repository;

/**
 * Repository JPA pour l'entité {@link Recipe}.
 * <p>
 * Fournit l'accès aux recettes publiques et personnelles avec des méthodes
 * de recherche, de filtrage par type de cuisine / repas, et de requêtes
 * spécialisées (tableau de bord, repas rapides, recommandations).
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
     * Récupère toutes les recettes publiques (visibles par tout le monde), de manière paginée.
     *
     * @param pageable les paramètres de pagination
     * @return une page de recettes publiques
     */
    Page<Recipe> findByIsPublicTrueAndDeletedAtIsNull(Pageable pageable);

    /**
     * Récupère les recettes pour le tableau de bord (filtrées et triées par pertinence).
     *
     * @param pageable les paramètres de pagination
     * @return une page de recettes pour le tableau de bord
     */
    @Query("SELECT r FROM Recipe r WHERE r.isPublic = true AND r.deletedAt IS NULL " +
           "AND r.enabled = true AND r.imageUrl IS NOT NULL " +
           "AND (r.caloriesPerServing IS NULL OR r.caloriesPerServing > 0) " +
           "ORDER BY r.verified DESC, r.confidenceScore DESC, r.updatedAt DESC")
    Page<Recipe> findDashboardRecipes(Pageable pageable);

    /**
     * Récupère les recettes personnelles d'un utilisateur.
     *
     * @param userId   l'identifiant de l'utilisateur
     * @param pageable les paramètres de pagination
     * @return une page de recettes de l'utilisateur
     */
    Page<Recipe> findByUserIdAndDeletedAtIsNull(UUID userId, Pageable pageable);

    /**
     * Filtre les recettes publiques par type de cuisine (ex: "Italienne", "Mexicaine").
     *
     * @param cuisineType le type de cuisine
     * @param pageable    les paramètres de pagination
     * @return une page de recettes correspondant au type de cuisine
     */
    Page<Recipe> findByCuisineTypeAndIsPublicTrueAndDeletedAtIsNull(String cuisineType, Pageable pageable);

    /**
     * Filtre les recettes publiques par type de repas (ex: "Petit-déjeuner", "Dîner").
     *
     * @param mealType le type de repas
     * @param pageable les paramètres de pagination
     * @return une page de recettes correspondant au type de repas
     */
    Page<Recipe> findByMealTypeAndIsPublicTrueAndDeletedAtIsNull(String mealType, Pageable pageable);

    /**
     * Recherche les recettes publiques par nom ou description (insensible à la casse).
     *
     * @param query    le terme de recherche
     * @param pageable les paramètres de pagination
     * @return une page de recettes correspondant à la recherche
     */
    @Query("SELECT r FROM Recipe r WHERE r.isPublic = true AND r.deletedAt IS NULL AND " +
           "LOWER(r.name) LIKE LOWER(CONCAT('%', :query, '%')) OR " +
           "LOWER(r.description) LIKE LOWER(CONCAT('%', :query, '%'))")
    Page<Recipe> searchPublicRecipes(@Param("query") String query, Pageable pageable);

    /**
     * Récupère les recettes par une liste d'identifiants.
     * Utilisé par le moteur de recommandation.
     *
     * @param ids la liste des identifiants de recettes
     * @return la liste des recettes correspondantes
     */
    @Query("SELECT r FROM Recipe r WHERE r.id IN :ids AND r.deletedAt IS NULL")
    List<Recipe> findByIds(@Param("ids") List<UUID> ids);

    /**
     * Récupère les recettes publiques dont le temps total est inférieur ou égal à une limite.
     *
     * @param maxTime  le temps maximum en minutes
     * @param pageable les paramètres de pagination
     * @return une page de recettes rapides
     */
    @Query("SELECT r FROM Recipe r WHERE r.isPublic = true AND r.deletedAt IS NULL AND r.totalTimeMinutes <= :maxTime")
    Page<Recipe> findQuickMeals(@Param("maxTime") Integer maxTime, Pageable pageable);

    /**
     * Récupère les recettes publiques filtrées par cuisine et coût maximum estimé.
     *
     * @param cuisine le type de cuisine (peut être null)
     * @param maxCost le coût maximum estimé
     * @param pageable les paramètres de pagination
     * @return une liste de recettes correspondant aux filtres
     */
    @Query("SELECT r FROM Recipe r WHERE r.isPublic = true AND r.deletedAt IS NULL AND " +
           "(:cuisine IS NULL OR r.cuisineType = :cuisine) AND " +
           "(r.estimatedCost IS NULL OR r.estimatedCost <= :maxCost)")
    List<Recipe> findByFilters(@Param("cuisine") String cuisine, @Param("maxCost") java.math.BigDecimal maxCost, Pageable pageable);
}
