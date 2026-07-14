package com.platepilote.platepilote.authentication.domain.entity;

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

/**
 * Entité représentant un utilisateur enregistré.
 * <p>
 * Mappée à la table {@code our_user} dans PostgreSQL.
 * Étend {@link BaseEntity} qui fournit les champs {@code id}, {@code createdAt},
 * {@code updatedAt} et {@code deletedAt}.
 * </p>
 */
@Entity
@Table(name = "our_user")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class OurUser extends BaseEntity {

    /** Email de l'utilisateur (utilisé pour la connexion, doit être unique). */
    @Column(nullable = false, unique = true)
    private String email;

    /** Mot de passe haché avec BCrypt (ne jamais stocker en clair). */
    @Column(name = "password_hash")
    private String passwordHash;

    /** Prénom de l'utilisateur. */
    @Column(name = "first_name", nullable = false)
    private String firstName;

    /** Nom de famille de l'utilisateur. */
    @Column(name = "last_name", nullable = false)
    private String lastName;

    /** Numéro de téléphone optionnel. */
    private String phone;

    /** URL de la photo de profil (stockée dans Cloudinary/R2). */
    @Column(name = "avatar_url")
    private String avatarUrl;

    /** Mode d'inscription ({@code "local"} = email/password, {@code "google"} = OAuth Google). */
    @Column(nullable = false)
    private String provider = "local";

    /** Identifiant chez le fournisseur OAuth. */
    @Column(name = "provider_id")
    private String providerId;

    /** Indique si l'email a été vérifié. */
    @Column(name = "email_verified")
    private Boolean emailVerified = false;

    /** Indique si le compte est actif. */
    @Column(nullable = false)
    private Boolean enabled = true;

    /** Indique si l'utilisateur s'est opposé aux analytics. */
    @Column(name = "analytics_opt_out", nullable = false)
    private Boolean analyticsOptOut = false;

    /** Indique si l'utilisateur a demandé une limitation du traitement. */
    @Column(name = "processing_restricted", nullable = false)
    private Boolean processingRestricted = false;

    /** Rôles de l'utilisateur (relation ManyToMany avec {@link Role}). */
    @Builder.Default
    @ManyToMany(fetch = FetchType.EAGER)
    @JoinTable(
            name = "user_roles",
            joinColumns = @JoinColumn(name = "user_id"),
            inverseJoinColumns = @JoinColumn(name = "role_id")
    )
    private Set<Role> roles = new HashSet<>();
}
