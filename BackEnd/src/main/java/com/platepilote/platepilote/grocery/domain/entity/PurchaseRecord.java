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

/**
 * Entité représentant un enregistrement d'achat effectué.
 * <p>
 * Conservé pour l'historique des dépenses et le suivi budgétaire.
 * Chaque enregistrement correspond à un article acheté lors d'un passage en caisse.
 */
@Entity
@Table(name = "purchase_records")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class PurchaseRecord extends BaseEntity {

    /** Identifiant de l'utilisateur ayant effectué l'achat. */
    @Column(name = "user_id", nullable = false)
    private UUID userId;

    /** Identifiant de la liste de courses associée. */
    @Column(name = "grocery_list_id")
    private UUID groceryListId;

    /** Nom de l'article acheté. */
    @Column(name = "item_name", nullable = false)
    private String itemName;

    /** Catégorie de l'article. */
    private String category;

    /** Quantité achetée. */
    @Column(precision = 10, scale = 3)
    private BigDecimal quantity;

    /** Unité de mesure. */
    @Column(length = 50)
    private String unit;

    /** Prix unitaire de l'article. */
    @Column(name = "unit_price", precision = 10, scale = 2)
    private BigDecimal unitPrice;

    /** Prix total payé (quantité × prix unitaire). */
    @Column(name = "total_price", nullable = false, precision = 10, scale = 2)
    private BigDecimal totalPrice;

    /** Identifiant de l'ingrédient canonique associé (optionnel). */
    @Column(name = "ingredient_id")
    private UUID ingredientId;

    /** Date et heure de l'achat. */
    @Column(name = "purchased_at", nullable = false)
    private Instant purchasedAt;
}
