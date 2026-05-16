package com.platepilote.platepilote.grocery.application.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class GroceryListRequest {

    @NotBlank(message = "List name is required")
    private String name;
}
