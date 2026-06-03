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
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.time.Instant;
import java.util.Map;
import java.util.UUID;

/**
 * Entité représentant un log d'audit des actions administratives.
 * <p>
 * Enregistre chaque action sensible (suspension, changement de rôle,
 * modification de paramètres, etc.) avec les métadonnées associées.
 * </p>
 */
@Entity
@Table(name = "audit_logs")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class AuditLog {

    /** Identifiant unique du log d'audit. */
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    /** Identifiant de l'utilisateur ayant réalisé l'action. */
    @Column(name = "actor_user_id")
    private UUID actorUserId;

    /** Email de l'utilisateur ayant réalisé l'action. */
    @Column(name = "actor_email")
    private String actorEmail;

    /** Type d'action réalisée (ex : USER_SUSPENDED, SYSTEM_SETTING_UPDATED). */
    @Column(nullable = false)
    private String action;

    /** Type de cible (ex : User, SystemSetting). */
    @Column(name = "target_type")
    private String targetType;

    /** Identifiant de la cible. */
    @Column(name = "target_id")
    private String targetId;

    /** Métadonnées JSON de l'action (contient les valeurs avant/après). */
    @JdbcTypeCode(SqlTypes.JSON)
    @Column(columnDefinition = "jsonb")
    private Map<String, Object> metadata;

    /** Date de création du log d'audit. */
    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;
}
