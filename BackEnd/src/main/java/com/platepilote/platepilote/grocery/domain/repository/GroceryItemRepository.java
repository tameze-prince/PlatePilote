package com.platepilote.platepilote.grocery.domain.repository;

/**
 * Repository JPA pour l'entité {@link GroceryItem}.
 * <p>
 * Fournit l'accès aux articles d'une liste de courses avec tri par ordre d'affichage,
 * ainsi que la suppression en masse des articles d'une liste.
 */

import com.platepilote.platepilote.grocery.domain.entity.GroceryItem;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.UUID;

public interface GroceryItemRepository extends JpaRepository<GroceryItem, UUID> {

    /**
     * Récupère tous les articles d'une liste de courses, triés par ordre d'affichage.
     *
     * @param groceryListId l'identifiant de la liste de courses
     * @return la liste des articles triés par {@code sortOrder} croissant
     */
    List<GroceryItem> findByGroceryListIdOrderBySortOrderAsc(UUID groceryListId);

    /**
     * Supprime tous les articles d'une liste de courses.
     * Utilisé lors de la suppression d'une liste pour nettoyer les articles orphelins.
     *
     * @param groceryListId l'identifiant de la liste de courses
     */
    void deleteByGroceryListId(UUID groceryListId);
}
