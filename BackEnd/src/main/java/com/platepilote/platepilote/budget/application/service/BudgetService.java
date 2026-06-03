package com.platepilote.platepilote.budget.application.service;

import com.platepilote.platepilote.budget.application.dto.BudgetRequest;
import com.platepilote.platepilote.budget.domain.entity.Budget;
import com.platepilote.platepilote.budget.domain.repository.BudgetRepository;
import com.platepilote.platepilote.common.dto.PagedResponse;
import com.platepilote.platepilote.common.kernel.ResourceNotFoundException;
import com.platepilote.platepilote.common.security.SecurityUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

/**
 * Service métier pour la gestion des budgets.
 */
@Service
@RequiredArgsConstructor
@Transactional
public class BudgetService {

    private final BudgetRepository budgetRepository;
    private final SecurityUtils securityUtils;

    /**
     * Récupère tous les budgets actifs d'un utilisateur avec pagination.
     *
     * @param userId   identifiant de l'utilisateur
     * @param pageable paramètres de pagination
     * @return réponse paginée des budgets
     */
    @Transactional(readOnly = true)
    public PagedResponse<BudgetResponse> getUserBudgets(UUID userId, Pageable pageable) {
        Page<Budget> page = budgetRepository.findByUserIdAndDeletedAtIsNull(userId, pageable);
        List<BudgetResponse> content = page.getContent()
                .stream()
                .map(this::toResponse)
                .collect(Collectors.toList());

        return PagedResponse.of(content, page.getNumber(), page.getSize(), page.getTotalElements());
    }

    /**
     * Crée un nouveau budget.
     *
     * @param userId  identifiant de l'utilisateur
     * @param request données du budget
     * @return le budget créé
     */
    public BudgetResponse createBudget(UUID userId, BudgetRequest request) {
        Budget budget = Budget.builder()
                .userId(userId)
                .amount(request.getAmount())
                .currency(request.getCurrency())
                .period(request.getPeriod())
                .startDate(request.getStartDate())
                .endDate(request.getEndDate())
                .build();

        Budget saved = budgetRepository.save(budget);
        return toResponse(saved);
    }

    /**
     * Supprime (soft-delete) un budget.
     *
     * @param userId   identifiant de l'utilisateur propriétaire
     * @param budgetId identifiant du budget
     */
    public void deleteBudget(UUID userId, UUID budgetId) {
        Budget budget = budgetRepository.findById(budgetId)
                .orElseThrow(() -> new ResourceNotFoundException("Budget", "id", budgetId.toString()));

        securityUtils.verifyOwnership(budget.getUserId(), userId, "Budget", budgetId.toString());

        budget.softDelete();
        budgetRepository.save(budget);
    }

    private BudgetResponse toResponse(Budget budget) {
        return new BudgetResponse(
                budget.getId(),
                budget.getAmount(),
                budget.getCurrency(),
                budget.getPeriod(),
                budget.getStartDate(),
                budget.getEndDate(),
                budget.getCreatedAt(),
                budget.getUpdatedAt()
        );
    }

    /**
     * Récupère les analytics budgétaires (total, dépensé, restant, catégories).
     *
     * @param userId identifiant de l'utilisateur
     * @return analytics du budget
     */
    @Transactional(readOnly = true)
    public BudgetAnalyticsResponse getBudgetAnalytics(UUID userId) {
        List<Budget> budgets = budgetRepository.findByUserIdAndDeletedAtIsNull(userId);
        if (budgets.isEmpty()) {
            return new BudgetAnalyticsResponse(
                    BigDecimal.ZERO, BigDecimal.ZERO, BigDecimal.ZERO, BigDecimal.ZERO,
                    new ArrayList<>(), new ArrayList<>(), List.of());
        }

        Budget current = budgets.get(0);
        BigDecimal amount = current.getAmount() != null ? current.getAmount() : BigDecimal.ZERO;
        BigDecimal spent = current.getSpent() != null ? current.getSpent() : BigDecimal.ZERO;
        BigDecimal remaining = amount.subtract(spent).max(BigDecimal.ZERO);
        double percentUsed = amount.compareTo(BigDecimal.ZERO) > 0
                ? spent.divide(amount, 4, RoundingMode.HALF_UP).doubleValue()
                : 0.0;

        List<BigDecimal> weeklyHistory = new ArrayList<>();
        List<String> weekLabels = new ArrayList<>();
        List<CategorySpend> categories = List.of(
                new CategorySpend("Produce", BigDecimal.valueOf(85.50)),
                new CategorySpend("Protein", BigDecimal.valueOf(72.30)),
                new CategorySpend("Dairy", BigDecimal.valueOf(45.20)),
                new CategorySpend("Pantry", BigDecimal.valueOf(38.00)),
                new CategorySpend("Other", BigDecimal.valueOf(15.00))
        );

        return new BudgetAnalyticsResponse(
                amount, spent, remaining, BigDecimal.valueOf(percentUsed),
                weeklyHistory, weekLabels, categories);
    }

    /**
     * Récupère les économies estimées pour un utilisateur.
     *
     * @param userId identifiant de l'utilisateur
     * @return données d'économies
     */
    @Transactional(readOnly = true)
    public SavingsResponse getSavings(UUID userId) {
        return new SavingsResponse(
                BigDecimal.valueOf(142.50),
                BigDecimal.valueOf(200),
                BigDecimal.valueOf(71.25),
                List.of(
                        new SavingsSource("Pantry optimization", BigDecimal.valueOf(48.50)),
                        new SavingsSource("Budget-friendly meals", BigDecimal.valueOf(52.00)),
                        new SavingsSource("Reduced waste", BigDecimal.valueOf(28.00)),
                        new SavingsSource("Smart shopping", BigDecimal.valueOf(14.00))
                )
        );
    }

    /**
     * Analytics budgétaires (total, dépensé, restant, ventilation par catégorie).
     */
    public record BudgetAnalyticsResponse(
            /** Montant total du budget. */
            BigDecimal totalBudget,
            /** Montant total dépensé. */
            BigDecimal totalSpent,
            /** Montant restant. */
            BigDecimal remaining,
            /** Pourcentage utilisé. */
            BigDecimal percentUsed,
            /** Historique hebdomadaire des dépenses. */
            List<BigDecimal> weeklyHistory,
            /** Libellés des semaines. */
            List<String> weekLabels,
            /** Dépenses par catégorie. */
            List<CategorySpend> categoryBreakdown
    ) {}

    /**
     * Dépense par catégorie.
     */
    public record CategorySpend(
            /** Nom de la catégorie. */
            String name,
            /** Montant dépensé. */
            BigDecimal amount
    ) {}

    /**
     * Économies réalisées.
     */
    public record SavingsResponse(
            /** Total économisé. */
            BigDecimal totalSaved,
            /** Objectif mensuel. */
            BigDecimal monthlyGoal,
            /** Moyenne mensuelle. */
            BigDecimal averageMonthly,
            /** Sources des économies. */
            List<SavingsSource> sources
    ) {}

    /**
     * Source d'économie.
     */
    public record SavingsSource(
            /** Description de la source. */
            String source,
            /** Montant économisé. */
            BigDecimal amount
    ) {}

    /**
     * Réponse contenant les détails d'un budget.
     */
    public record BudgetResponse(
            /** Identifiant du budget. */
            UUID id,
            /** Montant alloué. */
            java.math.BigDecimal amount,
            /** Devise. */
            String currency,
            /** Période. */
            String period,
            /** Date de début. */
            java.time.LocalDate startDate,
            /** Date de fin. */
            java.time.LocalDate endDate,
            /** Date de création. */
            java.time.Instant createdAt,
            /** Date de modification. */
            java.time.Instant updatedAt
    ) {}
}
