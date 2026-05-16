package com.platepilote.platepilote.imports.domain.repository;

import com.platepilote.platepilote.imports.domain.entity.ImportJob;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.UUID;

@Repository
public interface ImportJobRepository extends JpaRepository<ImportJob, UUID> {

    Page<ImportJob> findByDeletedAtIsNullOrderByCreatedAtDesc(Pageable pageable);
}
