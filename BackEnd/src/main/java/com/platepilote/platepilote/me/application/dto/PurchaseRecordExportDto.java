package com.platepilote.platepilote.me.application.dto;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

public record PurchaseRecordExportDto(
        UUID id,
        UUID groceryListId,
        String itemName,
        String category,
        BigDecimal quantity,
        String unit,
        BigDecimal unitPrice,
        BigDecimal totalPrice,
        UUID ingredientId,
        Instant purchasedAt
) {}
