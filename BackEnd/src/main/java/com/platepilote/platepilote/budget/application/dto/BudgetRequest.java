package com.platepilote.platepilote.budget.application.dto;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDate;

/**
 * Requête de création/mise à jour d'un budget.
 */
@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class BudgetRequest {

    /** Montant du budget (obligatoire, doit être > 0). */
    @NotNull(message = "Amount is required")
    @DecimalMin(value = "0.01", message = "Amount must be greater than 0")
    private BigDecimal amount;

    /** Devise du budget (défaut USD). */
    private String currency = "USD";

    /** Période du budget (ex. mensuel, hebdomadaire) — obligatoire. */
    @NotBlank(message = "Period is required")
    private String period;

    /** Date de début du budget (obligatoire). */
    @NotNull(message = "Start date is required")
    private LocalDate startDate;

    /** Date de fin du budget. */
    private LocalDate endDate;
}
