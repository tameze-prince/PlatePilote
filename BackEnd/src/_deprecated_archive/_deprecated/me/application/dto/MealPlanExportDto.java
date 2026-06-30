package com.platepilote.platepilote.me.application.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.Instant;
import java.time.LocalDate;
import java.util.UUID;

/**
 * Vue exportable (RGPD) d'un plan de repas.
 * <p>Données figées à l'instant de l'export — n'évolue pas avec l'API publique.</p>
 */
@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MealPlanExportDto {

    /** Identifiant du plan. */
    private UUID id;

    /** Nom du plan. */
    private String name;

    /** Date de début. */
    private LocalDate startDate;

    /** Date de fin. */
    private LocalDate endDate;

    /** Statut : DRAFT, ACTIVE, COMPLETED, CANCELLED. */
    private String status;

    /** Mode : STANDARD, WASTELESS, ENDOFMONTH, BUSYWEEK, FAMILY. */
    private String mode;

    /** Date de création. */
    private Instant createdAt;

    /** Date de dernière modification. */
    private Instant updatedAt;
}
