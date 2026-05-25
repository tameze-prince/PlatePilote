package com.plateplate.deduplication.infrastructure.repository;

import com.plateplate.deduplication.domain.model.DuplicateDetection;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface DuplicateDetectionRepository extends JpaRepository<DuplicateDetection, String> {
}
