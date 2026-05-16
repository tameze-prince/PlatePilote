package com.platepilote.platepilote.pricing.domain.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.UUID;

@Entity
@Table(name = "ingredient_prices")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class IngredientPrice {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(name = "ingredient_id", nullable = false)
    private UUID ingredientId;

    @Column(name = "country_code", length = 2)
    private String countryCode;

    @Column(name = "currency_code", length = 3, nullable = false)
    private String currencyCode;

    @Column(name = "average_price_per_unit", nullable = false, precision = 10, scale = 2)
    private BigDecimal averagePricePerUnit;

    @Column(nullable = false)
    private String unit;

    @Column(nullable = false)
    private String source;

    @Column(name = "effective_date", nullable = false)
    private LocalDate effectiveDate;
}
