package com.platepilote.platepilote.ingredients.domain.repository;

import com.platepilote.platepilote.ingredients.domain.entity.IngredientAlias;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.UUID;

/**
 * Repository d'accès aux données des alias d'ingrédients.
 * <p>
 * Table associée : {@code ingredient_aliases}.
 * </p>
 */
public interface IngredientAliasRepository extends JpaRepository<IngredientAlias, UUID> {

    /**
     * Récupère tous les alias associés à un ingrédient donné.
     *
     * @param ingredientId identifiant de l'ingrédient
     * @return liste des alias de l'ingrédient
     */
    List<IngredientAlias> findByIngredientId(UUID ingredientId);

    /**
     * Récupère les alias correspondant à un nom normalisé donné.
     *
     * @param normalizedAlias alias normalisé recherché
     * @return liste des alias correspondant
     */
    List<IngredientAlias> findByNormalizedAlias(String normalizedAlias);
}
