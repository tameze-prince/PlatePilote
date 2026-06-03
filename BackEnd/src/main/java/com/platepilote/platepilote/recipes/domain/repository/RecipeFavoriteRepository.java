package com.platepilote.platepilote.recipes.domain.repository;

/**
 * Repository JPA pour l'entité {@link RecipeFavorite}.
 * <p>
 * Fournit l'accès aux favoris des utilisateurs : recherche, pagination,
 * existence, suppression et comptage.
 */
import com.platepilote.platepilote.recipes.domain.entity.RecipeFavorite;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface RecipeFavoriteRepository extends JpaRepository<RecipeFavorite, UUID> {

    /**
     * Recherche un favori par recette et utilisateur.
     *
     * @param recipeId l'identifiant de la recette
     * @param userId   l'identifiant de l'utilisateur
     * @return le favori s'il existe
     */
    Optional<RecipeFavorite> findByRecipeIdAndUserId(UUID recipeId, UUID userId);

    /**
     * Récupère tous les favoris d'un utilisateur, triés du plus récent au plus ancien.
     *
     * @param userId   l'identifiant de l'utilisateur
     * @param pageable les paramètres de pagination
     * @return une page de favoris
     */
    Page<RecipeFavorite> findByUserIdOrderByCreatedAtDesc(UUID userId, Pageable pageable);

    /**
     * Vérifie si une recette est déjà favorite pour un utilisateur.
     *
     * @param recipeId l'identifiant de la recette
     * @param userId   l'identifiant de l'utilisateur
     * @return true si le favori existe
     */
    boolean existsByRecipeIdAndUserId(UUID recipeId, UUID userId);

    /**
     * Supprime un favori par recette et utilisateur.
     *
     * @param recipeId l'identifiant de la recette
     * @param userId   l'identifiant de l'utilisateur
     */
    void deleteByRecipeIdAndUserId(UUID recipeId, UUID userId);

    /**
     * Compte le nombre de favoris d'un utilisateur.
     *
     * @param userId l'identifiant de l'utilisateur
     * @return le nombre de favoris
     */
    long countByUserId(UUID userId);
}
