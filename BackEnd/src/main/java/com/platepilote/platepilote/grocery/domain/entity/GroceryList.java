package com.platepilote.platepilote.grocery.domain.entity;

/**
 * Entité représentant une liste de courses.
 * <p>
 * Une liste appartient à un utilisateur et peut avoir plusieurs statuts :
 * <ul>
 *   <li>{@code ACTIVE} — en cours d'utilisation</li>
 *   <li>{@code COMPLETED} — achat terminé</li>
 *   <li>{@code ARCHIVED} — conservée pour référence</li>
 * </ul>
 * Elle peut être liée à un plan de repas pour génération automatique.
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

@Entity
@Table(name = "grocery_lists")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class GroceryList extends BaseEntity {

    @Column(name = "user_id", nullable = false)
    private UUID userId;

    @Column(nullable = false)
    private String name;  // e.g., "Weekly Shopping", "BBQ Party List"

    @Column(nullable = false)
    private String status = "ACTIVE";  // "ACTIVE", "COMPLETED", "ARCHIVED"

    @Column(name = "meal_plan_id")
    private UUID mealPlanId;
}
