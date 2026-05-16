package com.platepilote.platepilote.common.kernel;

/**
 * BASE ENTITY - PARENT CLASS FOR ALL DATABASE ENTITIES
 * =====================================================
 * 
 * WHAT IT IS:
 * This is the parent class that ALL database entities extend from.
 * It provides common fields that every table needs:
 *   - id: Unique identifier (UUID)
 *   - createdAt: When the record was created
 *   - updatedAt: When the record was last modified
 *   - deletedAt: For soft deletion (hiding records without actually deleting them)
 * 
 * WHY IT EXISTS:
 * Instead of repeating these 4 fields in every entity (User, Recipe, PantryItem, etc.),
 * we define them once here and all entities inherit them.
 * 
 * SOFT DELETE EXPLANATION:
 * Instead of permanently deleting records, we set deletedAt to the current timestamp.
 * This allows us to:
 *   - Recover accidentally deleted data
 *   - Keep audit trails
 *   - Filter out "deleted" records in queries by checking WHERE deletedAt IS NULL
 * 
 * HOW TO USE:
 * Every entity class extends this: public class User extends BaseEntity { ... }
 */

import jakarta.persistence.Column;
import jakarta.persistence.EntityListeners;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.MappedSuperclass;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.Instant;
import java.util.UUID;

@MappedSuperclass  // Tells JPA: "This class provides fields for child entities, but has no table itself"
@Getter            // Lombok: Auto-generates getter methods for all fields
@Setter            // Lombok: Auto-generates setter methods for all fields
@NoArgsConstructor // Lombok: Auto-generates no-argument constructor
@AllArgsConstructor// Lombok: Auto-generates constructor with all fields
@EntityListeners(AuditableEntityListener.class) // Auto-updates createdAt/updatedAt timestamps
public abstract class BaseEntity {

    /**
     * Primary key - Unique identifier for every record
     * Uses UUID (e.g., "550e8400-e29b-41d4-a716-446655440000") instead of auto-increment numbers
     * UUID is better for distributed systems and security (can't guess IDs)
     */
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    /**
     * Timestamp when this record was first created
     * Automatically set by JPA, cannot be changed later (updatable = false)
     */
    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;

    /**
     * Timestamp when this record was last updated
     * Automatically updated every time the record is modified
     */
    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false)
    private Instant updatedAt;

    /**
     * Timestamp when this record was soft-deleted
     * NULL = record is active, NOT NULL = record is deleted
     */
    @Column(name = "deleted_at")
    private Instant deletedAt;

    /**
     * Check if this record has been soft-deleted
     * @return true if deletedAt is set, false otherwise
     */
    public boolean isDeleted() {
        return deletedAt != null;
    }

    /**
     * Soft-delete this record (hide it without permanently removing from database)
     * Sets deletedAt to current timestamp
     */
    public void softDelete() {
        this.deletedAt = Instant.now();
    }

    /**
     * Restore a soft-deleted record
     * Sets deletedAt back to null, making the record visible again
     */
    public void restore() {
        this.deletedAt = null;
    }
}
