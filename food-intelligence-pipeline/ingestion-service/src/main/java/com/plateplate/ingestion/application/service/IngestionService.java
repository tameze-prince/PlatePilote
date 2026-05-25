package com.plateplate.ingestion.application.service;

import com.plateplate.ingestion.domain.model.ImportJob;
import com.plateplate.ingestion.domain.model.RawData;
import com.plateplate.ingestion.infrastructure.repository.ImportJobRepository;
import com.plateplate.ingestion.infrastructure.repository.RawDataRepository;
import org.springframework.amqp.rabbit.core.RabbitTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.UUID;

@Service
public class IngestionService {

    private final ImportJobRepository importJobRepository;
    private final RawDataRepository rawDataRepository;
    private final RabbitTemplate rabbitTemplate;

    public IngestionService(ImportJobRepository importJobRepository,
                            RawDataRepository rawDataRepository,
                            RabbitTemplate rabbitTemplate) {
        this.importJobRepository = importJobRepository;
        this.rawDataRepository = rawDataRepository;
        this.rabbitTemplate = rabbitTemplate;
    }

    @Transactional
    public ImportJob createImportJob(String source) {
        ImportJob job = new ImportJob(UUID.randomUUID().toString(), source);
        job.setStatus(ImportJob.Status.RUNNING);
        job.setStartedAt(Instant.now());
        return importJobRepository.save(job);
    }

    @Transactional
    public void storeRawData(String importJobId, String source, String entityType, String payload, String externalId) {
        RawData rawData = new RawData();
        rawData.setId(UUID.randomUUID().toString());
        rawData.setImportJobId(importJobId);
        rawData.setSource(source);
        rawData.setEntityType(entityType);
        rawData.setPayload(payload);
        rawData.setExternalId(externalId);
        rawDataRepository.save(rawData);
        rabbitTemplate.convertAndSend("food-pipeline", "normalization." + entityType.toLowerCase(), rawData);
    }

    @Transactional
    public ImportJob completeImportJob(String jobId, Long processed, Long failed) {
        ImportJob job = importJobRepository.findById(jobId)
                .orElseThrow(() -> new IllegalArgumentException("Job not found: " + jobId));
        job.setCompletedAt(Instant.now());
        job.setRecordsProcessed(processed);
        job.setRecordsFailed(failed);
        if (failed > 0) {
            job.setStatus(ImportJob.Status.PARTIAL_FAILURE);
        } else {
            job.setStatus(ImportJob.Status.COMPLETED);
        }
        return importJobRepository.save(job);
    }

    @Transactional
    public ImportJob failImportJob(String jobId, String errorMessage) {
        ImportJob job = importJobRepository.findById(jobId)
                .orElseThrow(() -> new IllegalArgumentException("Job not found: " + jobId));
        job.setStatus(ImportJob.Status.FAILED);
        job.setErrorMessage(errorMessage);
        job.setCompletedAt(Instant.now());
        return importJobRepository.save(job);
    }
}
