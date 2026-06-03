package com.platepilote.platepilote.pantry.domain.repository;

/**
 * Repository pour l'accès aux données des articles du garde-manger.
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

/**
 * Repository pour l'accès aux données des articles du garde-manger.
 */
@Repository
public interface PantryItemRepository extends JpaRepository<PantryItem, UUID> {

    /**
     * Récupère tous les articles actifs d'un utilisateur avec pagination.
     *
     * @param userId   identifiant de l'utilisateur
     * @param pageable paramètres de pagination
     * @return page des articles actifs
     */
    Page<PantryItem> findByUserIdAndDeletedAtIsNull(UUID userId, Pageable pageable);

    /**
     * Récupère les articles d'un utilisateur filtrés par catégorie.
     *
     * @param userId   identifiant de l'utilisateur
     * @param category catégorie souhaitée
     * @return liste des articles de la catégorie
     */
    List<PantryItem> findByUserIdAndCategoryAndDeletedAtIsNull(UUID userId, String category);

    /**
     * Recherche les articles dont la date de péremption est antérieure ou égale à une date donnée.
     *
     * @param userId identifiant de l'utilisateur
     * @param date   date seuil
     * @return liste des articles proches de la péremption
     */
    @Query("SELECT p FROM PantryItem p WHERE p.userId = :userId AND p.deletedAt IS NULL AND p.expirationDate <= :date")
    List<PantryItem> findExpiringItems(@Param("userId") UUID userId, @Param("date") LocalDate date);

    /**
     * Recherche des articles par nom (correspondance partielle, insensible à la casse).
     *
     * @param userId identifiant de l'utilisateur
     * @param query  terme de recherche
     * @return liste des articles correspondants
     */
    @Query("SELECT p FROM PantryItem p WHERE p.userId = :userId AND p.deletedAt IS NULL AND LOWER(p.name) LIKE LOWER(CONCAT('%', :query, '%'))")
    List<PantryItem> searchByUserIdAndQuery(@Param("userId") UUID userId, @Param("query") String query);

    /**
     * Recherche les articles dont l'identifiant d'ingrédient est dans une liste donnée.
     *
     * @param userId        identifiant de l'utilisateur
     * @param ingredientIds collection d'identifiants d'ingrédients
     * @return liste des articles correspondants
     */
    @Query("SELECT p FROM PantryItem p WHERE p.userId = :userId AND p.deletedAt IS NULL AND p.ingredientId IN :ingredientIds")
    List<PantryItem> findByUserIdAndIngredientIdIn(@Param("userId") UUID userId, @Param("ingredientIds") Collection<UUID> ingredientIds);
}
