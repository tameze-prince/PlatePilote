package com.platepilote.platepilote.mealplanning.domain.entity;

import com.platepilote.platepilote.common.kernel.BaseEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDate;
import java.util.UUID;

/**
 * Entité représentant un plan de repas (ex : "Semaine du 15 au 21 janvier").
 * <p>
 * Un plan contient plusieurs {@link MealPlanEntry} et peut avoir différents
 * statuts (DRAFT, ACTIVE, COMPLETED, CANCELLED) et modes de fonctionnement.
 * </p>
 */
@Entity
@Table(name = "meal_plans")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class MealPlan extends BaseEntity {

    /** Identifiant de l'utilisateur propriétaire du plan. */
    @Column(name = "user_id", nullable = false)
    private UUID userId;

    /** Nom du plan (ex : "Semaine 3 Janvier", "Low Carb Week"). */
    @Column(nullable = false)
    private String name;

    /** Date de début du plan de repas. */
    @Column(name = "start_date", nullable = false)
    private LocalDate startDate;

    /** Date de fin du plan de repas. */
    @Column(name = "end_date", nullable = false)
    private LocalDate endDate;

    /** Statut du plan : DRAFT, ACTIVE, COMPLETED, CANCELLED. */
    @Column(nullable = false)
    private String status = "DRAFT";

    /** Mode de fonctionnement : STANDARD, WASTELESS, ENDOFMONTH, BUSYWEEK, FAMILY. */
    @Column(nullable = false)
    @Builder.Default
    private String mode = "STANDARD";
}
