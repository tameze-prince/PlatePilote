package com.platepilote.platepilote.recipes.domain.repository;

/**
 * Repository JPA pour l'entité {@link RecipeStep}.
 * <p>
 * Fournit l'accès aux étapes d'une recette avec tri par numéro d'étape,
 * ainsi que la suppression en masse pour nettoyage lors des mises à jour.
 */

import com.platepilote.platepilote.recipes.domain.entity.RecipeStep;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.UUID;

public interface RecipeStepRepository extends JpaRepository<RecipeStep, UUID> {

    /**
     * Récupère toutes les étapes d'une recette, triées par numéro d'étape.
     *
     * @param recipeId l'identifiant de la recette
     * @return la liste des étapes triées par {@code stepNumber} croissant
     */
    List<RecipeStep> findByRecipeIdOrderByStepNumberAsc(UUID recipeId);

    /**
     * Supprime toutes les étapes d'une recette.
     * Utilisé lors de la mise à jour ou de la suppression d'une recette.
     *
     * @param recipeId l'identifiant de la recette
     */
    void deleteByRecipeId(UUID recipeId);
}
