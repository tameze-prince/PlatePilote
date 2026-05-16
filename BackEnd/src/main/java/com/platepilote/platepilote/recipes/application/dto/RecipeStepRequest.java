package com.platepilote.platepilote.recipes.application.dto;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class RecipeStepRequest {

    @NotNull(message = "Step number is required")
    @Min(value = 1, message = "Step number must be at least 1")
    private Integer stepNumber;

    @NotBlank(message = "Instruction is required")
    private String instruction;

    private Integer durationMinutes;
}
