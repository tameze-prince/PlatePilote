package com.platepilote.platepilote.admin.domain.repository;

import com.platepilote.platepilote.admin.domain.entity.AdminNote;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.UUID;

/**
 * Repository pour l'entité {@link AdminNote}.
 */
@Repository
public interface AdminNoteRepository extends JpaRepository<AdminNote, UUID> {
}
