package com.plateplate.normalization.infrastructure.repository;

import com.plateplate.normalization.domain.model.Ingredient;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface IngredientRepository extends JpaRepository<Ingredient, String> {
    Optional<Ingredient> findBySlug(String slug);
    Optional<Ingredient> findByCanonicalName(String canonicalName);
}
