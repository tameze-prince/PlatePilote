package com.platepilote.platepilote.authentication.domain.entity;

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

/**
 * Entité représentant un rôle utilisateur.
 * <p>
 * Stockée dans la table {@code roles}.
 * Les rôles sont attribués aux utilisateurs via la table de jointure {@code user_roles}.
 * Spring Security utilise les rôles pour contrôler l'accès aux endpoints.
 * </p>
 *
 * <p>Rôles disponibles :</p>
 * <ul>
 *   <li>{@code ROLE_USER} — Utilisateur standard (garde-manger, recettes, plans repas)</li>
 *   <li>{@code ROLE_ADMIN} — Administrateur (gestion des utilisateurs, analytics)</li>
 *   <li>{@code ROLE_PREMIUM_USER} — Abonné premium (fonctionnalités avancées)</li>
 * </ul>
 */
@Entity
@Table(name = "roles")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class Role {

    /** Identifiant unique du rôle. */
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    /** Nom du rôle (ex: {@code ROLE_USER}, {@code ROLE_ADMIN}). */
    @Column(nullable = false, unique = true)
    private String name;

    /** Description lisible du rôle. */
    private String description;
}
