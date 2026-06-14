package com.platepilote.platepilote.grocery.domain.repository;

/**
 * Repository JPA pour l'entité {@link GroceryList}.
 * <p>
 * Fournit l'accès paginé aux listes de courses d'un utilisateur,
 * avec filtrage par statut et lien vers un plan de repas.
 */

import com.platepilote.platepilote.grocery.domain.entity.GroceryList;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;
import java.util.UUID;

public interface GroceryListRepository extends JpaRepository<GroceryList, UUID> {

    /**
     * Récupère les listes de courses actives (non supprimées) d'un utilisateur, de manière paginée.
     *
     * @param userId   l'identifiant de l'utilisateur
     * @param pageable les paramètres de pagination et de tri
     * @return une page de listes de courses
     */
    Page<GroceryList> findByUserIdAndDeletedAtIsNull(UUID userId, Pageable pageable);

    /**
     * Récupère les listes de courses d'un utilisateur filtrées par statut.
     *
     * @param userId   l'identifiant de l'utilisateur
     * @param status   le statut recherché ("ACTIVE", "COMPLETED", "ARCHIVED")
     * @param pageable les paramètres de pagination
     * @return une page de listes de courses correspondant au statut
     */
    Page<GroceryList> findByUserIdAndStatusAndDeletedAtIsNull(UUID userId, String status, Pageable pageable);

    /**
     * Récupère une liste de courses active associée à un plan de repas pour un utilisateur donné.
     *
     * @param userId     l'identifiant de l'utilisateur
     * @param mealPlanId l'identifiant du plan de repas
     * @param status     le statut recherché
     * @return la liste de courses correspondante, ou vide si introuvable
     */
    Optional<GroceryList> findByUserIdAndMealPlanIdAndStatusAndDeletedAtIsNull(
            UUID userId, UUID mealPlanId, String status);
}
