package com.platepilote.platepilote.grocery.application.dto;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class GroceryItemRequest {

    @NotBlank(message = "Item name is required")
    private String name;

    private String category;

    @DecimalMin(value = "0.01", message = "Quantity must be greater than 0")
    private BigDecimal quantity;

    @NotBlank(message = "Unit is required")
    private String unit;

    private BigDecimal estimatedPrice;

    private String notes;

    @Builder.Default
    private Integer sortOrder = 0;
}
