package com.platepilote.platepilote.ingredients.domain.repository;

import com.platepilote.platepilote.ingredients.domain.entity.IngredientAllergen;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.UUID;

public interface IngredientAllergenRepository extends JpaRepository<IngredientAllergen, UUID> {

    boolean existsByIngredientIdAndAllergenGroupIgnoreCase(UUID ingredientId, String allergenGroup);
}
