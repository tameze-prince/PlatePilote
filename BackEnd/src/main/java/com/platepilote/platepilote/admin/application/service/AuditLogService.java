package com.platepilote.platepilote.admin.application.service;

import com.platepilote.platepilote.admin.domain.entity.AuditLog;
import com.platepilote.platepilote.admin.domain.repository.AuditLogRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Map;
import java.util.UUID;

/**
 * Service de journalisation des actions d'audit.
 * <p>
 * Enregistre chaque action administrative (suspension, changement de rôle,
 * modification de paramètres, etc.) dans la table {@code audit_logs}.
 * </p>
 */
@Service
@RequiredArgsConstructor
public class AuditLogService {

    private final AuditLogRepository auditLogRepository;

    /**
     * Enregistre une action d'audit.
     *
     * @param actorUserId identifiant de l'utilisateur ayant réalisé l'action
     * @param actorEmail  email de l'utilisateur ayant réalisé l'action
     * @param action      type d'action (ex : USER_SUSPENDED, SYSTEM_SETTING_UPDATED)
     * @param targetType  type de cible (ex : User, SystemSetting)
     * @param targetId    identifiant de la cible
     * @param metadata    métadonnées supplémentaires de l'action
     */
    @SuppressWarnings("null")
    @Transactional
    public void log(UUID actorUserId, String actorEmail, String action, String targetType,
                    String targetId, Map<String, Object> metadata) {
        auditLogRepository.save(AuditLog.builder()
                .actorUserId(actorUserId)
                .actorEmail(actorEmail)
                .action(action)
                .targetType(targetType)
                .targetId(targetId)
                .metadata(metadata)
                .build());
    }
}
