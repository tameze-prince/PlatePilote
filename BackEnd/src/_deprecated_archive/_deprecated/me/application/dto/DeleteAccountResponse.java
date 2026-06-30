package com.platepilote.platepilote.me.application.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.Instant;
import java.util.UUID;

/**
 * Réponse de l'endpoint {@code DELETE /api/v1/me/account}.
 * <p>
 * Conformité RGPD : droit à l'effacement (art. 17).
 * Le compte est marqué soft-delete immédiatement ; les données personnelles sont
 * hard-purgées après une fenêtre de grâce de 30 jours (cf. BR-008 PRD §9.2).
 * </p>
 */
@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class DeleteAccountResponse {

    /** Identifiant de l'utilisateur dont le compte est programmé pour suppression. */
    private UUID userId;

    /** Date/heure du soft-delete immédiat (UTC). */
    private Instant deletionDateAt;

    /** Date à laquelle le hard-purge est planifié (30 jours après le soft-delete). */
    private Instant scheduledPurgeAt;

    /** Nombre de jours avant le hard-purge. */
    private Integer gracePeriodDays;

    /** Message lisible par l'utilisateur. */
    private String message;
}
