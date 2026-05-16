package com.platepilote.platepilote.pricing.domain.entity;

import com.platepilote.platepilote.common.kernel.BaseEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.UUID;

@Entity
@Table(name = "barcode_products")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class BarcodeProduct extends BaseEntity {

    @Column(nullable = false, unique = true)
    private String barcode;

    @Column(name = "product_name", nullable = false)
    private String productName;

    private String brand;

    @Column(name = "ingredient_id")
    private UUID ingredientId;

    @Column(name = "open_food_facts_code")
    private String openFoodFactsCode;
}
