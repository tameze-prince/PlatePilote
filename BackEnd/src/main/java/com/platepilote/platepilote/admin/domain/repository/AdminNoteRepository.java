package com.platepilote.platepilote.admin.domain.repository;

import com.platepilote.platepilote.admin.domain.entity.AdminNote;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.UUID;

public interface AdminNoteRepository extends JpaRepository<AdminNote, UUID> {
}
