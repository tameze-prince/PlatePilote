package com.platepilote.platepilote.authentication.domain.entity;

/**
 * USER ENTITY - DATABASE TABLE: our_user
 * =====================================
 * 
 * WHAT IT IS:
 * Represents a registered user in the system.
 * Maps to the "our_user" table in the PostgreSQL database.
 * 
 * FIELDS EXPLANATION:
 * - id: Unique identifier (UUID), inherited from BaseEntity
 * - email: User's email address (used for login), must be unique
 * - passwordHash: BCrypt-hashed password (NEVER store plain text passwords!)
 * - firstName, lastName: User's display name
 * - phone: Optional phone number for notifications
 * - avatarUrl: URL to user's profile picture (stored in Cloudinary/R2)
 * - provider: How the user registered ("local" = email/password, "google" = Google OAuth)
 * - providerId: ID from the OAuth provider (e.g., Google user ID)
 * - emailVerified: Whether the user clicked the email verification link
 * - enabled: Whether the account is active (can be disabled by admin)
 * - createdAt, updatedAt, deletedAt: Inherited from BaseEntity
 */

import com.platepilote.platepilote.common.kernel.BaseEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.JoinTable;
import jakarta.persistence.ManyToMany;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.HashSet;
import java.util.Set;

@Entity  // Tells JPA: "This class maps to a database table"
@Table(name = "our_user")  // Specifies the table name
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder  // Lombok: Enables builder pattern (User.builder().email("...").build())
public class OurUser extends BaseEntity {

    @Column(nullable = false, unique = true)  // Required and must be unique
    private String email;

    @Column(name = "password_hash")  // Column name in database (snake_case)
    private String passwordHash;

    @Column(name = "first_name", nullable = false)
    private String firstName;

    @Column(name = "last_name", nullable = false)
    private String lastName;

    private String phone;

    @Column(name = "avatar_url")
    private String avatarUrl;

    @Column(nullable = false)
    private String provider = "local";  // Default to email/password registration

    @Column(name = "provider_id")
    private String providerId;

    @Column(name = "email_verified")
    private Boolean emailVerified = false;

    @Column(nullable = false)
    private Boolean enabled = true;

    @Builder.Default
    @ManyToMany(fetch = FetchType.EAGER)
    @JoinTable(
            name = "user_roles",
            joinColumns = @JoinColumn(name = "user_id"),
            inverseJoinColumns = @JoinColumn(name = "role_id")
    )
    private Set<Role> roles = new HashSet<>();
}
