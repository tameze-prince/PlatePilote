package com.platepilote.platepilote.budget.application.service;

import com.platepilote.platepilote.budget.application.dto.BudgetRequest;
import com.platepilote.platepilote.budget.domain.entity.Budget;
import com.platepilote.platepilote.budget.domain.repository.BudgetRepository;
import com.platepilote.platepilote.common.dto.PagedResponse;
import com.platepilote.platepilote.common.kernel.ResourceNotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional
public class BudgetService {

    private final BudgetRepository budgetRepository;

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

        if (!budget.getUserId().equals(userId)) {
            throw new ResourceNotFoundException("Budget", "id", budgetId.toString());
        }

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
