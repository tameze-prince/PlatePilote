package com.platepilote.platepilote.pantry.domain.entity;

/**
 * Entité représentant un article dans le garde-manger d'un utilisateur.
 * Table en base : {@code pantry_items}.
 * <p>
 * Un article peut être un aliment, une boisson ou tout produit stocké
 * dans le garde-manger, le réfrigérateur ou le congélateur.
 * La date de péremption permet de déclencher des notifications.
 */

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
import java.time.LocalDate;
import java.util.UUID;

/**
 * Entité représentant un article dans le garde-manger d'un utilisateur.
 * Table en base : {@code pantry_items}.
 */
@Entity
@Table(name = "pantry_items")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PantryItem extends BaseEntity {

    /** Identifiant de l'utilisateur propriétaire. */
    @Column(name = "user_id", nullable = false)
    private UUID userId;

    /** Nom de l'article. */
    @Column(nullable = false)
    private String name;

    /** Catégorie (ex. fruits, légumes, viande, produits laitiers). */
    private String category;

    /** Quantité de l'article. */
    @Column(nullable = false)
    private BigDecimal quantity;

    /** Unité de mesure (g, kg, ml, litre, pièce). */
    @Column(nullable = false)
    private String unit;

    /** Date de péremption de l'article. */
    @Column(name = "expiration_date")
    private LocalDate expirationDate;

    /** Identifiant de l'ingrédient associé (résolution automatique). */
    @Column(name = "ingredient_id")
    private UUID ingredientId;
}
