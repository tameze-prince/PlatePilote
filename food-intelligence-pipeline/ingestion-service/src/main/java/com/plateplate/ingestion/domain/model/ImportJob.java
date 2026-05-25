package com.plateplate.ingestion.domain.model;

import jakarta.persistence.*;
import java.time.Instant;

@Entity
@Table(name = "import_jobs")
public class ImportJob {

    public enum Status {
        PENDING, RUNNING, COMPLETED, PARTIAL_FAILURE, FAILED
    }

    @Id
    private String id;

    @Column(nullable = false)
    private String source;

    @Enumerated(EnumType.STRING)
    private Status status;

    @Column(name = "started_at")
    private Instant startedAt;

    @Column(name = "completed_at")
    private Instant completedAt;

    @Column(name = "records_processed")
    private Long recordsProcessed;

    @Column(name = "records_failed")
    private Long recordsFailed;

    @Column(name = "error_message")
    private String errorMessage;

    public ImportJob() {}

    public ImportJob(String id, String source) {
        this.id = id;
        this.source = source;
        this.status = Status.PENDING;
    }

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }
    public String getSource() { return source; }
    public void setSource(String source) { this.source = source; }
    public Status getStatus() { return status; }
    public void setStatus(Status status) { this.status = status; }
    public Instant getStartedAt() { return startedAt; }
    public void setStartedAt(Instant startedAt) { this.startedAt = startedAt; }
    public Instant getCompletedAt() { return completedAt; }
    public void setCompletedAt(Instant completedAt) { this.completedAt = completedAt; }
    public Long getRecordsProcessed() { return recordsProcessed; }
    public void setRecordsProcessed(Long recordsProcessed) { this.recordsProcessed = recordsProcessed; }
    public Long getRecordsFailed() { return recordsFailed; }
    public void setRecordsFailed(Long recordsFailed) { this.recordsFailed = recordsFailed; }
    public String getErrorMessage() { return errorMessage; }
    public void setErrorMessage(String errorMessage) { this.errorMessage = errorMessage; }
}
