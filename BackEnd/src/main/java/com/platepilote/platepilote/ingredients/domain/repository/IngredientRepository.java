package com.platepilote.platepilote.ingredients.domain.repository;

import com.platepilote.platepilote.ingredients.domain.entity.Ingredient;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface IngredientRepository extends JpaRepository<Ingredient, UUID> {

    Optional<Ingredient> findBySlug(String slug);

    Optional<Ingredient> findByCanonicalName(String canonicalName);

    Page<Ingredient> findByCategoryAndDeletedAtIsNull(String category, Pageable pageable);

    @Query("SELECT i FROM Ingredient i WHERE i.deletedAt IS NULL AND " +
           "(LOWER(i.canonicalName) LIKE LOWER(CONCAT('%', :query, '%')) OR " +
           "LOWER(i.category) LIKE LOWER(CONCAT('%', :query, '%')))")
    Page<Ingredient> search(@Param("query") String query, Pageable pageable);

    @Query("SELECT i FROM Ingredient i WHERE i.deletedAt IS NULL AND " +
           "LOWER(i.canonicalName) IN :names")
    Page<Ingredient> findByCanonicalNameInIgnoreCase(@Param("names") java.util.List<String> names, Pageable pageable);
}
