package com.platepilote.platepilote.grocery.application.dto;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

/**
 * Requête pour créer ou mettre à jour un article de liste de courses.
 * <p>
 * Contient les informations nécessaires à l'ajout d'un article : nom, catégorie,
 * quantité, unité, prix estimé et note optionnelle.
 */
@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class GroceryItemRequest {

    /** Nom de l'article (obligatoire). */
    @NotBlank(message = "Item name is required")
    private String name;

    /** Catégorie de l'article (ex: "Produits laitiers", "Fruits et légumes"). */
    private String category;

    /** Quantité à acheter (obligatoire, doit être > 0). */
    @DecimalMin(value = "0.01", message = "Quantity must be greater than 0")
    private BigDecimal quantity;

    /** Unité de mesure (obligatoire, ex: "kg", "L", "pièce"). */
    @NotBlank(message = "Unit is required")
    private String unit;

    /** Prix estimé pour le suivi budgétaire. */
    private BigDecimal estimatedPrice;

    /** Note optionnelle (ex: "Prendre la marque bio"). */
    private String notes;

    /** Ordre d'affichage dans la liste. */
    @Builder.Default
    private Integer sortOrder = 0;
}
