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

@Service
@RequiredArgsConstructor
@Transactional
public class BudgetService {

    private final BudgetRepository budgetRepository;
    private final SecurityUtils securityUtils;

    @Transactional(readOnly = true)
    public PagedResponse<BudgetResponse> getUserBudgets(UUID userId, Pageable pageable) {
        Page<Budget> page = budgetRepository.findByUserIdAndDeletedAtIsNull(userId, pageable);
        List<BudgetResponse> content = page.getContent()
                .stream()
                .map(this::toResponse)
                .collect(Collectors.toList());

        return PagedResponse.of(content, page.getNumber(), page.getSize(), page.getTotalElements());
    }

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

    public record BudgetAnalyticsResponse(
            BigDecimal totalBudget,
            BigDecimal totalSpent,
            BigDecimal remaining,
            BigDecimal percentUsed,
            List<BigDecimal> weeklyHistory,
            List<String> weekLabels,
            List<CategorySpend> categoryBreakdown
    ) {}

    public record CategorySpend(
            String name,
            BigDecimal amount
    ) {}

    public record SavingsResponse(
            BigDecimal totalSaved,
            BigDecimal monthlyGoal,
            BigDecimal averageMonthly,
            List<SavingsSource> sources
    ) {}

    public record SavingsSource(
            String source,
            BigDecimal amount
    ) {}

    public record BudgetResponse(
            UUID id,
            java.math.BigDecimal amount,
            String currency,
            String period,
            java.time.LocalDate startDate,
            java.time.LocalDate endDate,
            java.time.Instant createdAt,
            java.time.Instant updatedAt
    ) {}
}
