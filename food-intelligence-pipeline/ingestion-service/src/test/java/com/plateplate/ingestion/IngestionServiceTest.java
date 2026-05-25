package com.plateplate.ingestion;

import com.plateplate.ingestion.application.service.IngestionService;
import com.plateplate.ingestion.domain.model.ImportJob;
import com.plateplate.ingestion.infrastructure.repository.ImportJobRepository;
import com.plateplate.ingestion.infrastructure.repository.RawDataRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.amqp.rabbit.core.RabbitTemplate;

import java.util.Optional;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@DisplayName("Ingestion Service Tests")
@ExtendWith(MockitoExtension.class)
public class IngestionServiceTest {

    @Mock
    private ImportJobRepository importJobRepository;

    @Mock
    private RawDataRepository rawDataRepository;

    @Mock
    private RabbitTemplate rabbitTemplate;

    private IngestionService ingestionService;

    @BeforeEach
    void setUp() {
        ingestionService = new IngestionService(importJobRepository, rawDataRepository, rabbitTemplate);
    }

    @Test
    @DisplayName("Should create import job successfully")
    void testCreateImportJob() {
        String source = "USDA";

        when(importJobRepository.save(any(ImportJob.class)))
                .thenAnswer(invocation -> invocation.getArgument(0));

        ImportJob job = ingestionService.createImportJob(source);

        assertNotNull(job);
        assertEquals(source, job.getSource());
        assertEquals(ImportJob.Status.RUNNING, job.getStatus());
        assertNotNull(job.getStartedAt());
    }

    @Test
    @DisplayName("Should store raw data and publish to queue")
    void testStoreRawData() {
        String importJobId = "job-123";
        String source = "USDA";
        String entityType = "INGREDIENT";
        String payload = "{\"name\":\"tomato\"}";
        String externalId = "ext-001";

        ingestionService.storeRawData(importJobId, source, entityType, payload, externalId);

        verify(rawDataRepository, times(1)).save(any());
        verify(rabbitTemplate, times(1)).convertAndSend(eq("food-pipeline"), eq("normalization." + entityType.toLowerCase()), any(Object.class));
    }

    @Test
    @DisplayName("Should complete import job with statistics")
    void testCompleteImportJob() {
        ImportJob job = new ImportJob("job-456", "SPOONACULAR");
        job.setStartedAt(java.time.Instant.now());
        job.setStatus(ImportJob.Status.RUNNING);

        when(importJobRepository.findById("job-456")).thenReturn(Optional.of(job));
        when(importJobRepository.save(any(ImportJob.class)))
                .thenAnswer(invocation -> invocation.getArgument(0));

        Long processed = 1000L;
        Long failed = 5L;

        ImportJob completed = ingestionService.completeImportJob("job-456", processed, failed);

        assertEquals(ImportJob.Status.PARTIAL_FAILURE, completed.getStatus());
        assertEquals(processed, completed.getRecordsProcessed());
        assertEquals(failed, completed.getRecordsFailed());
        assertNotNull(completed.getCompletedAt());
    }

    @Test
    @DisplayName("Should fail import job with error message")
    void testFailImportJob() {
        ImportJob job = new ImportJob("job-789", "OPEN_FOOD_FACTS");
        job.setStatus(ImportJob.Status.RUNNING);

        when(importJobRepository.findById("job-789")).thenReturn(Optional.of(job));
        when(importJobRepository.save(any(ImportJob.class)))
                .thenAnswer(invocation -> invocation.getArgument(0));

        String errorMessage = "API rate limit exceeded";

        ImportJob failed = ingestionService.failImportJob("job-789", errorMessage);

        assertEquals(ImportJob.Status.FAILED, failed.getStatus());
        assertEquals(errorMessage, failed.getErrorMessage());
        assertNotNull(failed.getCompletedAt());
    }
}
