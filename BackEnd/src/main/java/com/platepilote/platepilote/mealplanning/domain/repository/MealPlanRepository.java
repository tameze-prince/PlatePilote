package com.platepilote.platepilote.mealplanning.domain.repository;

import com.platepilote.platepilote.mealplanning.domain.entity.MealPlan;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.UUID;

/**
 * Repository d'accès aux données des plans de repas.
 * <p>
 * Table associée : {@code meal_plans}.
 * </p>
 */
public interface MealPlanRepository extends JpaRepository<MealPlan, UUID> {

    /**
     * Récupère les plans de repas actifs (non supprimés) d'un utilisateur,
     * avec pagination et tri.
     *
     * @param userId   identifiant de l'utilisateur
     * @param pageable paramètres de pagination et de tri
     * @return page de plans de repas
     */
    Page<MealPlan> findByUserIdAndDeletedAtIsNull(UUID userId, Pageable pageable);
}
