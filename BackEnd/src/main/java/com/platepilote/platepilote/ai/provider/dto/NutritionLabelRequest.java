package com.platepilote.platepilote.ai.provider.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Request DTO for nutrition label parsing.
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class NutritionLabelRequest {

    private String imageUrl;  // URL to nutrition label image

    private String rawText;  // OCR text from nutrition label

    private String productName;  // Optional product name for context

    private String brand;  // Optional brand name

    private String servingSize;  // Serving size description

    private int servingsPerContainer;  // If available
}