package com.platepilote.platepilote.authentication.domain.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.Instant;
import java.util.UUID;

/**
 * Entité représentant un token de vérification d'email.
 * <p>
 * Stocké dans la table {@code email_verification_tokens}.
 * Utilisé pour confirmer l'adresse email d'un utilisateur lors de l'inscription.
 * </p>
 */
@Entity
@Table(name = "email_verification_tokens")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class EmailVerificationToken {

    /** Identifiant unique du token. */
    @Id
    @Builder.Default
    private UUID id = UUID.randomUUID();

    /** Identifiant de l'utilisateur associé. */
    @Column(name = "user_id", nullable = false)
    private UUID userId;

    /** Valeur du token (unique). */
    @Column(nullable = false, unique = true)
    private String token;

    /** Date d'expiration du token. */
    @Column(name = "expires_at", nullable = false)
    private Instant expiresAt;

    /** Indique si le token a déjà été utilisé. */
    @Column(nullable = false)
    @Builder.Default
    private Boolean used = false;

    /** Date de création du token. */
    @Column(name = "created_at", nullable = false)
    @Builder.Default
    private Instant createdAt = Instant.now();
}
