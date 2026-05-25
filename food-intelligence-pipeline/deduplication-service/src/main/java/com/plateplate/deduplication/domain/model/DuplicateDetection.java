package com.plateplate.deduplication.domain.model;

import jakarta.persistence.*;

@Entity
@Table(name = "duplicate_detections")
public class DuplicateDetection {

    public enum Status {
        PENDING, AUTO_MERGED, MANUAL_REVIEW, REJECTED
    }

    @Id
    private String id;

    @Column(name = "entity_type")
    private String entityType;

    @Column(name = "primary_id")
    private String primaryId;

    @Column(name = "duplicate_id")
    private String duplicateId;

    @Column(name = "confidence_score")
    private double confidenceScore;

    @Enumerated(EnumType.STRING)
    private Status status;

    public DuplicateDetection() {}

    public DuplicateDetection(String id, String entityType, String primaryId, String duplicateId, double confidenceScore) {
        this.id = id;
        this.entityType = entityType;
        this.primaryId = primaryId;
        this.duplicateId = duplicateId;
        this.confidenceScore = confidenceScore;
        this.status = Status.PENDING;
    }

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }
    public String getEntityType() { return entityType; }
    public void setEntityType(String entityType) { this.entityType = entityType; }
    public String getPrimaryId() { return primaryId; }
    public void setPrimaryId(String primaryId) { this.primaryId = primaryId; }
    public String getDuplicateId() { return duplicateId; }
    public void setDuplicateId(String duplicateId) { this.duplicateId = duplicateId; }
    public double getConfidenceScore() { return confidenceScore; }
    public void setConfidenceScore(double confidenceScore) { this.confidenceScore = confidenceScore; }
    public Status getStatus() { return status; }
    public void setStatus(Status status) { this.status = status; }
}
