package com.platepilote.platepilote.preferences.domain.entity;

/**
 * Entité représentant une allergie alimentaire d'un utilisateur.
 * Table en base : {@code allergies}.
 * <p>
 * La sévérité détermine le comportement :
 * <ul>
 *   <li>{@code severe} → exclusion complète des recettes contenant l'allergène</li>
 *   <li>{@code moderate} → avertissement mais recette visible</li>
 *   <li>{@code mild} → simple note sur la recette</li>
 * </ul>
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

import java.util.UUID;

/**
 * Entité représentant une allergie alimentaire d'un utilisateur.
 * Table en base : {@code allergies}.
 */
@Entity
@Table(name = "allergies")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Allergy extends BaseEntity {

    /** Identifiant de l'utilisateur. */
    @Column(name = "user_id", nullable = false)
    private UUID userId;

    /** Nom de l'allergène (ex. arachides, crustacés, lactose). */
    @Column(name = "allergen", nullable = false)
    private String allergen;

    /** Niveau de sévérité : mild, moderate, severe. */
    @Column(name = "severity")
    private String severity;
}
