package com.platepilote.platepilote.me.application.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.Instant;
import java.util.UUID;

@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class GroceryListExportDto {
    private UUID id;
    private String name;
    private String status;
    private UUID mealPlanId;
    private Instant createdAt;
}
