package com.plateplate.ingestion.domain.model;

import jakarta.persistence.*;

@Entity
@Table(name = "raw_data")
public class RawData {

    @Id
    private String id;

    @Column(name = "import_job_id")
    private String importJobId;

    @Column(nullable = false)
    private String source;

    @Column(name = "entity_type")
    private String entityType;

    @Column(columnDefinition = "TEXT")
    private String payload;

    @Column(name = "external_id")
    private String externalId;

    public RawData() {}

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }
    public String getImportJobId() { return importJobId; }
    public void setImportJobId(String importJobId) { this.importJobId = importJobId; }
    public String getSource() { return source; }
    public void setSource(String source) { this.source = source; }
    public String getEntityType() { return entityType; }
    public void setEntityType(String entityType) { this.entityType = entityType; }
    public String getPayload() { return payload; }
    public void setPayload(String payload) { this.payload = payload; }
    public String getExternalId() { return externalId; }
    public void setExternalId(String externalId) { this.externalId = externalId; }
}
