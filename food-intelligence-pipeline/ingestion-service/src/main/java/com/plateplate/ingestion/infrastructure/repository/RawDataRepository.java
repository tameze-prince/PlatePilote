package com.plateplate.ingestion.infrastructure.repository;

import com.plateplate.ingestion.domain.model.RawData;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface RawDataRepository extends JpaRepository<RawData, String> {
}
