package com.platepilote.platepilote.admin.domain.repository;

import com.platepilote.platepilote.admin.domain.entity.AuditLog;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.Instant;
import java.util.UUID;

/**
 * Repository pour l'entité {@link AuditLog}.
 */
public interface AuditLogRepository extends JpaRepository<AuditLog, UUID> {

    /**
     * Retourne les logs d'audit triés par date de création décroissante.
     *
     * @param pageable paramètres de pagination
     * @return page de logs d'audit
     */
    Page<AuditLog> findAllByOrderByCreatedAtDesc(Pageable pageable);

    /**
     * Compte le nombre de logs créés après une date donnée.
     *
     * @param createdAt date limite
     * @return nombre de logs
     */
    long countByCreatedAtAfter(Instant createdAt);
}
