package com.platepilote.platepilote.recipes.domain.repository;

import com.platepilote.platepilote.recipes.domain.entity.RecipeFavorite;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface RecipeFavoriteRepository extends JpaRepository<RecipeFavorite, UUID> {
    Optional<RecipeFavorite> findByRecipeIdAndUserId(UUID recipeId, UUID userId);
    Page<RecipeFavorite> findByUserIdOrderByCreatedAtDesc(UUID userId, Pageable pageable);
    boolean existsByRecipeIdAndUserId(UUID recipeId, UUID userId);
    void deleteByRecipeIdAndUserId(UUID recipeId, UUID userId);
    long countByUserId(UUID userId);
}
