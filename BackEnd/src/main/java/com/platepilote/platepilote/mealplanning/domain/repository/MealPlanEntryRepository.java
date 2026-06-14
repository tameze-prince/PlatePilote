package com.platepilote.platepilote.mealplanning.domain.repository;

import com.platepilote.platepilote.mealplanning.domain.entity.MealPlanEntry;
import org.springframework.data.jpa.repository.JpaRepository;
import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

/**
 * Repository d'accès aux données des entrées de plan de repas.
 * <p>
 * Table associée : {@code meal_plan_entries}.
 * </p>
 */
public interface MealPlanEntryRepository extends JpaRepository<MealPlanEntry, UUID> {

    /**
     * Récupère toutes les entrées (repas) d'un plan de repas donné.
     *
     * @param mealPlanId identifiant du plan de repas
     * @return liste des entrées du plan
     */
    List<MealPlanEntry> findByMealPlanId(UUID mealPlanId);

    /**
     * Compte le nombre d'entrées dans un plan de repas.
     *
     * @param mealPlanId identifiant du plan de repas
     * @return nombre d'entrées
     */
    long countByMealPlanId(UUID mealPlanId);

    /**
     * Récupère tous les repas planifiés pour une date spécifique dans un plan donné.
     *
     * @param mealPlanId identifiant du plan de repas
     * @param mealDate   date ciblée
     * @return liste des entrées pour cette date (Petit-déjeuner, Déjeuner, Dîner, etc.)
     */
    List<MealPlanEntry> findByMealPlanIdAndMealDate(UUID mealPlanId, LocalDate mealDate);
}
