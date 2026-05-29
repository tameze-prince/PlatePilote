package com.platepilote.platepilote.grocery.domain.entity;

import com.platepilote.platepilote.common.kernel.BaseEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "purchase_records")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class PurchaseRecord extends BaseEntity {

    @Column(name = "user_id", nullable = false)
    private UUID userId;

    @Column(name = "grocery_list_id")
    private UUID groceryListId;

    @Column(name = "item_name", nullable = false)
    private String itemName;

    private String category;

    @Column(precision = 10, scale = 3)
    private BigDecimal quantity;

    @Column(length = 50)
    private String unit;

    @Column(name = "unit_price", precision = 10, scale = 2)
    private BigDecimal unitPrice;

    @Column(name = "total_price", nullable = false, precision = 10, scale = 2)
    private BigDecimal totalPrice;

    @Column(name = "ingredient_id")
    private UUID ingredientId;

    @Column(name = "purchased_at", nullable = false)
    private Instant purchasedAt;
}
