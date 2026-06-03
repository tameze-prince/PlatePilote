package com.platepilote.platepilote.preferences.domain.entity;

import com.platepilote.platepilote.common.kernel.BaseEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.UUID;

/**
 * Entité représentant une préférence culinaire d'un utilisateur.
 * Table en base : {@code cuisine_preferences}.
 */
@Entity
@Table(name = "cuisine_preferences")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CuisinePreference extends BaseEntity {

    /** Identifiant de l'utilisateur. */
    @Column(name = "user_id", nullable = false)
    private UUID userId;

    /** Type de cuisine (ex. italienne, japonaise, mexicaine). */
    @Column(name = "cuisine_type", nullable = false)
    private String cuisineType;

    /** Niveau de préférence (LIKE, DISLIKE). */
    @Column(name = "preference_level")
    private String preferenceLevel;
}
