package com.platepilote.platepilote.ingredients.domain.repository;

import com.platepilote.platepilote.ingredients.domain.entity.IngredientAllergen;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Set;
import java.util.UUID;

/**
 * Repository d'accès aux données des allergènes d'ingrédients.
 * <p>
 * Table associée : {@code ingredient_allergens}.
 * </p>
 */
@Repository
public interface IngredientAllergenRepository extends JpaRepository<IngredientAllergen, UUID> {

    /**
     * Vérifie si un ingrédient possède un groupe d'allergènes donné (insensible à la casse).
     *
     * @param ingredientId  identifiant de l'ingrédient
     * @param allergenGroup groupe d'allergènes à vérifier
     * @return true si l'association existe
     */
    boolean existsByIngredientIdAndAllergenGroupIgnoreCase(UUID ingredientId, String allergenGroup);

    /**
     * Récupère tous les allergènes associés à un ensemble d'ingrédients.
     *
     * @param ingredientIds identifiants des ingrédients
     * @return liste des allergènes correspondants
     */
    @Query("SELECT ia FROM IngredientAllergen ia WHERE ia.ingredientId IN :ingredientIds")
    List<IngredientAllergen> findByIngredientIdIn(@Param("ingredientIds") Set<UUID> ingredientIds);
}
