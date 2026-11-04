package com.platepilote.platepilote.me.application.dto;

import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDate;
import java.util.UUID;

public record BudgetExportDto(
        UUID id,
        BigDecimal amount,
        String currency,
        String period,
        LocalDate startDate,
        LocalDate endDate,
        BigDecimal spent,
        Instant createdAt,
        Instant updatedAt
) {}
