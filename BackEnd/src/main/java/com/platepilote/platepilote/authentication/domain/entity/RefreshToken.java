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
 * Entité représentant un token de rafraîchissement JWT.
 * <p>
 * Stocké dans la table {@code refresh_tokens}.
 * Permet de générer un nouveau token d'accès sans demander le mot de passe.
 * Le token est haché avec SHA-256 avant d'être persistance.
 * </p>
 */
@Entity
@Table(name = "refresh_tokens")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class RefreshToken {

    /** Identifiant unique du token. */
    @Id
    @Builder.Default
    private UUID id = UUID.randomUUID();

    /** Identifiant de l'utilisateur propriétaire du token. */
    @Column(name = "user_id", nullable = false)
    private UUID userId;

    /** Valeur du token (hachée avec SHA-256). */
    @Column(nullable = false, unique = true, length = 500)
    private String token;

    /** Date d'expiration du token. */
    @Column(name = "expires_at", nullable = false)
    private Instant expiresAt;

    /** Indique si le token a été révoqué. */
    @Column(nullable = false)
    private Boolean revoked = false;

    /** Date de création du token. */
    @Column(name = "created_at", nullable = false)
    @Builder.Default
    private Instant createdAt = Instant.now();
}
