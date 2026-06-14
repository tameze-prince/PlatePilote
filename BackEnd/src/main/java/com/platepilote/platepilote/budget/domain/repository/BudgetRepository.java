package com.platepilote.platepilote.budget.domain.repository;

import com.platepilote.platepilote.budget.domain.entity.Budget;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.UUID;

/**
 * Repository pour l'accès aux données des budgets.
 */
public interface BudgetRepository extends JpaRepository<Budget, UUID> {

    /**
     * Récupère les budgets actifs d'un utilisateur avec pagination.
     *
     * @param userId   identifiant de l'utilisateur
     * @param pageable paramètres de pagination
     * @return page des budgets
     */
    Page<Budget> findByUserIdAndDeletedAtIsNull(UUID userId, Pageable pageable);

    /**
     * Récupère tous les budgets actifs d'un utilisateur.
     *
     * @param userId identifiant de l'utilisateur
     * @return liste des budgets
     */
    List<Budget> findByUserIdAndDeletedAtIsNull(UUID userId);
}
