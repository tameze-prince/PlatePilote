package com.platepilote.platepilote.ingredients.domain.repository;

import com.platepilote.platepilote.ingredients.domain.entity.IngredientAllergen;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Set;
import java.util.UUID;

public interface IngredientAllergenRepository extends JpaRepository<IngredientAllergen, UUID> {

    boolean existsByIngredientIdAndAllergenGroupIgnoreCase(UUID ingredientId, String allergenGroup);

    @Query("SELECT ia FROM IngredientAllergen ia WHERE ia.ingredientId IN :ingredientIds")
    List<IngredientAllergen> findByIngredientIdIn(@Param("ingredientIds") Set<UUID> ingredientIds);
}
