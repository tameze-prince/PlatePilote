package com.plateplate.deduplication.application.service;

import com.plateplate.common.util.StringNormalizer;
import com.plateplate.deduplication.domain.model.DuplicateDetection;
import com.plateplate.deduplication.infrastructure.repository.DuplicateDetectionRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

@Service
public class DeduplicationService {

    private final DuplicateDetectionRepository repository;

    public DeduplicationService(DuplicateDetectionRepository repository) {
        this.repository = repository;
    }

    public double calculateSimilarity(String str1, String str2) {
        String norm1 = StringNormalizer.normalize(str1);
        String norm2 = StringNormalizer.normalize(str2);
        if (norm1.equals(norm2)) return 1.0;
        int maxLen = Math.max(norm1.length(), norm2.length());
        if (maxLen == 0) return 1.0;
        int dist = StringNormalizer.levenshtein(norm1, norm2);
        return 1.0 - (double) dist / maxLen;
    }

    @Transactional
    public DuplicateDetection detectDuplicate(String entityType, String primaryId, String duplicateId, double confidenceScore) {
        DuplicateDetection detection = new DuplicateDetection(
                UUID.randomUUID().toString(),
                entityType,
                primaryId,
                duplicateId,
                confidenceScore
        );
        if (confidenceScore >= 0.95) {
            detection.setStatus(DuplicateDetection.Status.AUTO_MERGED);
        } else if (confidenceScore >= 0.75) {
            detection.setStatus(DuplicateDetection.Status.PENDING);
        } else {
            detection.setStatus(DuplicateDetection.Status.REJECTED);
        }
        return repository.save(detection);
    }
}
