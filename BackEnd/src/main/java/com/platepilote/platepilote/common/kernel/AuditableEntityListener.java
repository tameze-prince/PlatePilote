package com.platepilote.platepilote.common.kernel;

/**
 * Auditeur JPA qui met automatiquement à jour les horodatages {@code createdAt} et {@code updatedAt}.
 * <p>
 * <ul>
 *   <li>Avant INSERT ({@code PrePersist}) : initialise {@code createdAt} et {@code updatedAt} à maintenant</li>
 *   <li>Avant UPDATE ({@code PreUpdate}) : met à jour {@code updatedAt} à maintenant</li>
 * </ul>
 * </p>
 */
import jakarta.persistence.PrePersist;
import jakarta.persistence.PreUpdate;

import java.time.Instant;

public class AuditableEntityListener {

    /**
     * Initialise les horodatages {@code createdAt} et {@code updatedAt} avant la persistance.
     *
     * @param entity entité à auditer
     */
    @PrePersist
    public void prePersist(BaseEntity entity) {
        Instant now = Instant.now();
        if (entity.getCreatedAt() == null) {
            entity.setCreatedAt(now);
        }
        if (entity.getUpdatedAt() == null) {
            entity.setUpdatedAt(now);
        }
    }

    /**
     * Met à jour l'horodatage {@code updatedAt} avant la mise à jour.
     *
     * @param entity entité à auditer
     */
    @PreUpdate
    public void preUpdate(BaseEntity entity) {
        entity.setUpdatedAt(Instant.now());
    }
}
