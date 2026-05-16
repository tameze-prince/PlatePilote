package com.platepilote.platepilote.common.kernel;

/**
 * AUDITABLE ENTITY - EXTENDS BASE ENTITY WITH USER TRACKING
 * ==========================================================
 * 
 * WHAT IT IS:
 * Extends BaseEntity by adding createdBy and updatedBy fields.
 * These track WHICH USER created or last modified a record.
 * 
 * EXAMPLE USE CASE:
 * - User "john@email.com" creates a recipe -> createdBy = "john@email.com"
 * - User "admin@email.com" updates that recipe -> updatedBy = "admin@email.com"
 * 
 * This is useful for audit trails and debugging ("who changed this?")
 */

import jakarta.persistence.Column;
import jakarta.persistence.MappedSuperclass;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.springframework.data.annotation.CreatedBy;
import org.springframework.data.annotation.LastModifiedBy;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

@MappedSuperclass
@Getter
@Setter
@NoArgsConstructor
@jakarta.persistence.EntityListeners(AuditingEntityListener.class)
public abstract class AuditableEntity extends BaseEntity {

    /**
     * Email/ID of the user who created this record
     * Automatically filled by Spring Security when the record is first saved
     */
    @CreatedBy
    @Column(name = "created_by", updatable = false)
    private String createdBy;

    /**
     * Email/ID of the user who last modified this record
     * Automatically updated by Spring Security on every save
     */
    @LastModifiedBy
    @Column(name = "updated_by")
    private String updatedBy;
}
