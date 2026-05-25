package com.plateplate.nutrition.infrastructure.repository;

import com.plateplate.nutrition.domain.model.NutritionFact;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface NutritionFactRepository extends JpaRepository<NutritionFact, String> {
    Optional<NutritionFact> findByIngredientId(String ingredientId);
}
