package com.platepilote.platepilote.notification.domain.entity;

import com.platepilote.platepilote.common.kernel.BaseEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.time.Instant;
import java.util.UUID;

/**
 * Entité représentant une notification destinée à un utilisateur.
 * <p>
 * Les notifications peuvent être de différents types (PANTRY_ALERT,
 * MEAL_PLAN_REMINDER, RECIPE_RECOMMENDATION, etc.) et contiennent
 * un titre, un corps de message et des données JSON optionnelles.
 * Hérite de BaseEntity pour le suivi des dates et le soft-delete.
 */
@Entity
@Table(name = "notifications")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Notification extends BaseEntity {

    /** Identifiant de l'utilisateur destinataire. */
    @Column(name = "user_id", nullable = false)
    private UUID userId;

    /** Type de notification (PANTRY_ALERT, MEAL_PLAN_REMINDER, etc.). */
    @Column(nullable = false)
    private String type;

    /** Titre de la notification. */
    @Column(nullable = false)
    private String title;

    /** Corps du message de la notification. */
    @Column(columnDefinition = "TEXT")
    private String body;

    /** Données JSON additionnelles associées à la notification. */
    @Column(columnDefinition = "jsonb")
    @JdbcTypeCode(SqlTypes.JSON)
    private String data;

    /** Indique si la notification a été lue. */
    @Column(nullable = false)
    @Builder.Default
    private Boolean read = false;

    /** Date à laquelle la notification a été lue. */
    @Column(name = "read_at")
    private Instant readAt;
}
