package com.plateplate.ingestion.infrastructure.repository;

import com.plateplate.ingestion.domain.model.ImportJob;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface ImportJobRepository extends JpaRepository<ImportJob, String> {
}
