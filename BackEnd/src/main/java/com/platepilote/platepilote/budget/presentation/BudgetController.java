package com.platepilote.platepilote.budget.presentation;

import com.platepilote.platepilote.common.security.SecurityUtils;
import com.platepilote.platepilote.budget.application.dto.BudgetRequest;
import com.platepilote.platepilote.budget.application.service.BudgetService;
import com.platepilote.platepilote.budget.application.service.BudgetService.BudgetAnalyticsResponse;
import com.platepilote.platepilote.budget.application.service.BudgetService.BudgetResponse;
import com.platepilote.platepilote.budget.application.service.BudgetService.SavingsResponse;
import com.platepilote.platepilote.common.dto.ApiResponse;
import com.platepilote.platepilote.common.dto.PagedResponse;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.UUID;

@RestController
@RequestMapping("/api/v1/budgets")
@RequiredArgsConstructor
public class BudgetController {

    private final BudgetService budgetService;
    private final SecurityUtils securityUtils;

    @GetMapping
    public ResponseEntity<ApiResponse<PagedResponse<BudgetResponse>>> getMyBudgets(
            @AuthenticationPrincipal UserDetails userDetails,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        UUID userId = securityUtils.getCurrentUserId(userDetails);
        Pageable pageable = PageRequest.of(page, size, Sort.by("startDate").descending());
        PagedResponse<BudgetResponse> budgets = budgetService.getUserBudgets(userId, pageable);
        return ResponseEntity.ok(ApiResponse.success(budgets));
    }

    @PostMapping
    public ResponseEntity<ApiResponse<BudgetResponse>> createBudget(
            @AuthenticationPrincipal UserDetails userDetails,
            @Valid @RequestBody BudgetRequest request) {
        UUID userId = securityUtils.getCurrentUserId(userDetails);
        BudgetResponse budget = budgetService.createBudget(userId, request);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success("Budget created", budget));
    }

    @DeleteMapping("/{budgetId}")
    public ResponseEntity<ApiResponse<Void>> deleteBudget(
            @AuthenticationPrincipal UserDetails userDetails,
            @PathVariable UUID budgetId) {
        UUID userId = securityUtils.getCurrentUserId(userDetails);
        budgetService.deleteBudget(userId, budgetId);
        return ResponseEntity.ok(ApiResponse.success("Budget deleted", null));
    }

    @GetMapping("/analytics")
    public ResponseEntity<ApiResponse<BudgetAnalyticsResponse>> getBudgetAnalytics(
            @AuthenticationPrincipal UserDetails userDetails) {
        UUID userId = securityUtils.getCurrentUserId(userDetails);
        BudgetAnalyticsResponse analytics = budgetService.getBudgetAnalytics(userId);
        return ResponseEntity.ok(ApiResponse.success(analytics));
    }

    @GetMapping("/savings")
    public ResponseEntity<ApiResponse<SavingsResponse>> getSavings(
            @AuthenticationPrincipal UserDetails userDetails) {
        UUID userId = securityUtils.getCurrentUserId(userDetails);
        SavingsResponse savings = budgetService.getSavings(userId);
        return ResponseEntity.ok(ApiResponse.success(savings));
    }
}
