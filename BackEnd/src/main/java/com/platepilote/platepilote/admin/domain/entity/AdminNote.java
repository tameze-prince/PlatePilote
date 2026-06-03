package com.platepilote.platepilote.admin.domain.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.hibernate.annotations.CreationTimestamp;

import java.time.Instant;
import java.util.UUID;

/**
 * Entité représentant une note interne laissée par un administrateur sur un utilisateur.
 */
@Entity
@Table(name = "admin_notes")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class AdminNote {

    /** Identifiant unique de la note. */
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    /** Identifiant de l'utilisateur concerné par la note. */
    @Column(name = "user_id")
    private UUID userId;

    /** Identifiant de l'administrateur ayant rédigé la note. */
    @Column(name = "admin_user_id")
    private UUID adminUserId;

    /** Contenu textuel de la note. */
    @Column(nullable = false, columnDefinition = "TEXT")
    private String note;

    /** Date de création de la note. */
    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;
}
