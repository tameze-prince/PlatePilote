package com.platepilote.platepilote.authentication.domain.entity;

/**
 * ROLE ENTITY - DATABASE TABLE: roles
 * =====================================
 * 
 * WHAT IT IS:
 * Represents a user role/permission level.
 * 
 * ROLES IN THIS APP:
 * - ROLE_USER: Standard user (can manage pantry, recipes, meal plans)
 * - ROLE_ADMIN: Administrator (can manage all users, view analytics)
 * - ROLE_PREMIUM: Premium subscriber (access to advanced features)
 * 
 * HOW ROLES WORK:
 * A user can have multiple roles through the user_roles join table.
 * Spring Security uses roles to control access to endpoints.
 * Example: @PreAuthorize("hasRole('ADMIN')") restricts endpoint to admins only.
 */

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.UUID;

@Entity
@Table(name = "roles")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class Role {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(nullable = false, unique = true)
    private String name;  // e.g., "ROLE_USER", "ROLE_ADMIN"

    private String description;  // Human-readable description of the role
}
