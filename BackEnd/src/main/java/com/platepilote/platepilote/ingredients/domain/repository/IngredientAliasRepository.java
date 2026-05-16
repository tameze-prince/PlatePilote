package com.platepilote.platepilote.ingredients.domain.repository;

import com.platepilote.platepilote.ingredients.domain.entity.IngredientAlias;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface IngredientAliasRepository extends JpaRepository<IngredientAlias, UUID> {

    List<IngredientAlias> findByIngredientId(UUID ingredientId);

    List<IngredientAlias> findByNormalizedAlias(String normalizedAlias);
}
