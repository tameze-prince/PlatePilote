package com.platepilote.platepilote.common.kernel;

/**
 * AUDITABLE ENTITY LISTENER - AUTO TIMESTAMP UPDATER
 * ====================================================
 * 
 * WHAT IT IS:
 * A JPA listener that automatically sets createdAt and updatedAt timestamps.
 * 
 * HOW IT WORKS:
 * - Before INSERT (PrePersist): Sets both createdAt and updatedAt to now
 * - Before UPDATE (PreUpdate): Sets updatedAt to now
 * 
 * WHY IT EXISTS:
 * So developers don't have to manually set timestamps every time they save an entity.
 * Spring handles this automatically.
 */

import jakarta.persistence.PrePersist;
import jakarta.persistence.PreUpdate;

import java.time.Instant;

public class AuditableEntityListener {

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

    @PreUpdate
    public void preUpdate(BaseEntity entity) {
        entity.setUpdatedAt(Instant.now());
    }
}
