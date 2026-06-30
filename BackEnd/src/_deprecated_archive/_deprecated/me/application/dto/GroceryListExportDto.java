package com.platepilote.platepilote.me.application.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.Instant;
import java.util.UUID;

/**
 * Vue exportable (RGPD) d'une liste de courses.
 * <p>Données figées à l'instant de l'export.</p>
 */
@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class GroceryListExportDto {

    /** Identifiant de la liste. */
    private UUID id;

    /** Nom de la liste. */
    private String name;

    /** Statut : ACTIVE, COMPLETED, ARCHIVED. */
    private String status;

    /** Identifiant du plan de repas associé (peut être null). */
    private UUID mealPlanId;

    /** Date de création. */
    private Instant createdAt;
}
