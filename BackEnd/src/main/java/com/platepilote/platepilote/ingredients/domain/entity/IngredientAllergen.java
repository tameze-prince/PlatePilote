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
import org.hibernate.annotations.CreationTimestamp;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

/**
 * Entité représentant un groupe d'allergènes associé à un ingrédient.
 * <p>
 * Chaque enregistrement lie un ingrédient à un groupe d'allergènes
 * (ex : "gluten", "lactose", "fruits à coque") avec un score de confiance
 * et une source d'information.
 * </p>
 */
@Entity
@Table(name = "ingredient_allergens")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class IngredientAllergen {

    /** Identifiant unique de l'association allergène-ingrédient. */
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    /** Identifiant de l'ingrédient concerné. */
    @Column(name = "ingredient_id", nullable = false)
    private UUID ingredientId;

    /** Groupe d'allergènes (ex : "gluten", "lactose", "fruits à coque"). */
    @Column(name = "allergen_group", nullable = false)
    private String allergenGroup;

    /** Score de confiance de l'association (entre 0 et 1, défaut : 1). */
    @Column(name = "confidence_score", nullable = false)
    private BigDecimal confidenceScore = BigDecimal.ONE;

    /** Source de l'information sur l'allergène. */
    private String source;

    /** Date de création de l'enregistrement (générée automatiquement). */
    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;
}
