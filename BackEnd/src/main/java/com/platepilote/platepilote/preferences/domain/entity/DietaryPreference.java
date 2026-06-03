package com.platepilote.platepilote.preferences.domain.entity;

/**
 * Entité représentant une préférence alimentaire (régime) d'un utilisateur.
 * Table en base : {@code dietary_preferences}.
 * <p>
 * Un utilisateur peut avoir plusieurs régimes (ex. végétarien ET sans gluten).
 * Utilisé par le moteur de recommandation pour filtrer les recettes.
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
 * Entité représentant une préférence alimentaire (régime) d'un utilisateur.
 * Table en base : {@code dietary_preferences}.
 */
@Entity
@Table(name = "dietary_preferences")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class DietaryPreference extends BaseEntity {

    /** Identifiant de l'utilisateur. */
    @Column(name = "user_id", nullable = false)
    private UUID userId;

    /** Type de régime (végétarien, végan, keto, paléo, etc.). */
    @Column(name = "diet_type", nullable = false)
    private String dietType;
}
