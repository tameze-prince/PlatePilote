package com.platepilote.platepilote.admin.application.service;

import com.platepilote.platepilote.admin.domain.entity.AuditLog;
import com.platepilote.platepilote.admin.domain.repository.AuditLogRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Map;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class AuditLogService {

    private final AuditLogRepository auditLogRepository;

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
