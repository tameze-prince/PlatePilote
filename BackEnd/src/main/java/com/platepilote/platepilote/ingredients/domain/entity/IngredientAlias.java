package com.platepilote.platepilote.ingredients.domain.entity;

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

import java.util.UUID;

/**
 * Entité représentant un alias (nom alternatif) d'un ingrédient.
 * <p>
 * Permet de faire correspondre différents noms d'un même ingrédient
 * (ex : "coriandre" et "cilantro", "poivron" et "piment doux").
 * L'alias normalisé facilite la recherche approximative.
 * </p>
 */
@Entity
@Table(name = "ingredient_aliases")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class IngredientAlias {

    /** Identifiant unique de l'alias. */
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    /** Nom alternatif brut de l'ingrédient. */
    @Column(nullable = false)
    private String alias;

    /** Nom alternatif normalisé (sans accents, minuscules). */
    @Column(name = "normalized_alias", nullable = false)
    private String normalizedAlias;

    /** Identifiant de l'ingrédient associé à cet alias. */
    @Column(name = "ingredient_id", nullable = false)
    private UUID ingredientId;
}
