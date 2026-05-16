package com.platepilote.platepilote.pantry.application.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDate;
import java.util.UUID;

@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PantryItemResponse {

    private UUID id;
    private String name;
    private String category;
    private BigDecimal quantity;
    private String unit;
    private LocalDate expirationDate;
    private boolean isExpired;
    private Instant createdAt;
    private Instant updatedAt;
}
