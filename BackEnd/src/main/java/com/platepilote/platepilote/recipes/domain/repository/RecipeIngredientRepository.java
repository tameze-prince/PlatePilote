package com.platepilote.platepilote.recipes.domain.repository;

/**
 * Repository JPA pour l'entité {@link RecipeIngredient}.
 * <p>
 * Fournit l'accès aux ingrédients d'une recette avec tri par ordre d'affichage,
 * ainsi que la suppression en masse et la recherche par liste d'identifiants.
 */

import com.platepilote.platepilote.recipes.domain.entity.RecipeIngredient;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import java.util.List;
import java.util.UUID;

public interface RecipeIngredientRepository extends JpaRepository<RecipeIngredient, UUID> {

    /**
     * Récupère tous les ingrédients d'une recette, triés par ordre d'affichage.
     *
     * @param recipeId l'identifiant de la recette
     * @return la liste des ingrédients triés par {@code sortOrder} croissant
     */
    List<RecipeIngredient> findByRecipeIdOrderBySortOrderAsc(UUID recipeId);

    /**
     * Supprime tous les ingrédients d'une recette.
     * Utilisé lors de la mise à jour ou de la suppression d'une recette.
     *
     * @param recipeId l'identifiant de la recette
     */
    void deleteByRecipeId(UUID recipeId);

    /**
     * Récupère les ingrédients pour plusieurs recettes à la fois.
     *
     * @param recipeIds la liste des identifiants de recettes
     * @return la liste des ingrédients correspondants
     */
    @Query("SELECT ri FROM RecipeIngredient ri WHERE ri.recipe.id IN :recipeIds")
    List<RecipeIngredient> findByRecipeIdIn(@Param("recipeIds") List<UUID> recipeIds);
}
