package com.platepilote.platepilote.mealplanning.domain.entity;

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

import java.time.Instant;
import java.util.UUID;

/**
 * Entité de suivi des échanges (swaps) de recettes effectués par un utilisateur.
 * <p>
 * Permet de compter le nombre d'échanges sur une période donnée
 * afin d'appliquer les limitations du palier gratuit.
 * </p>
 */
@Entity
@Table(name = "swap_tracking")
@Getter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class SwapTracking {

    /** Identifiant unique de l'enregistrement de suivi. */
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    /** Identifiant de l'utilisateur ayant effectué l'échange. */
    @Column(name = "user_id", nullable = false)
    private UUID userId;

    /** Date et heure de l'échange. */
    @Column(name = "swapped_at", nullable = false)
    private Instant swappedAt;
}
