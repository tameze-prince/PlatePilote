package com.platepilote.platepilote.recipes.domain.entity;

/**
 * Entité représentant un ingrédient d'une recette.
 * <p>
 * Chaque ingrédient appartient à une recette (relation many-to-one) et contient
 * le nom, la quantité, l'unité de mesure et un ordre d'affichage.
 * L'identifiant {@code ingredientId} permet de lier l'ingrédient à un ingrédient
 * canonique pour la résolution des prix et des substitutions.
 */

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;
import java.util.UUID;

@Entity
@Table(name = "recipe_ingredients")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class RecipeIngredient {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)  // Lazy load: don't fetch the recipe until needed
    @JoinColumn(name = "recipe_id", nullable = false)
    private Recipe recipe;

    @Column(nullable = false)
    private String name;

    @Column(nullable = false)
    private BigDecimal quantity;

    @Column(nullable = false)
    private String unit;

    @Column(columnDefinition = "TEXT")
    private String notes;  // e.g., "diced", "finely chopped", "room temperature"

    @Column(name = "sort_order")
    private Integer sortOrder = 0;  // Order in which ingredients are displayed

    @Column(name = "ingredient_id")
    private UUID ingredientId;
}
