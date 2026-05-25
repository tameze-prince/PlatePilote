package com.plateplate.ingestion;

import com.plateplate.ingestion.application.service.IngestionService;
import com.plateplate.ingestion.domain.model.ImportJob;
import com.plateplate.ingestion.infrastructure.repository.ImportJobRepository;
import com.plateplate.ingestion.infrastructure.repository.RawDataRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.DisplayName;
import org.springframework.amqp.rabbit.core.RabbitTemplate;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.context.annotation.Import;
import org.springframework.test.context.ActiveProfiles;

import static org.junit.jupiter.api.Assertions.*;

@DisplayName("Ingestion Service Tests")
@SpringBootTest
@ActiveProfiles("test")
public class IngestionServiceTest {

    private IngestionService ingestionService;
    private MockRabbitTemplate mockRabbitTemplate;
    private ImportJobRepository importJobRepository;
    private RawDataRepository rawDataRepository;

    @BeforeEach
    void setUp() {
        mockRabbitTemplate = new MockRabbitTemplate();
        this.ingestionService = new IngestionService(importJobRepository, rawDataRepository, mockRabbitTemplate);
    }

    @Test
    @DisplayName("Should create import job successfully")
    void testCreateImportJob() {
        // Arrange
        String source = "USDA";

        // Act
        ImportJob job = ingestionService.createImportJob(source);

        // Assert
        assertNotNull(job);
        assertEquals(source, job.getSource());
        assertEquals(ImportJob.Status.RUNNING, job.getStatus());
        assertNotNull(job.getStartedAt());
    }

    @Test
    @DisplayName("Should store raw data and publish to queue")
    void testStoreRawData() {
        // Arrange
        String importJobId = "job-123";
        String source = "USDA";
        String entityType = "INGREDIENT";
        String payload = "{\"name\":\"tomato\"}";
        String externalId = "ext-001";

        // Act
        ingestionService.storeRawData(importJobId, source, entityType, payload, externalId);

        // Assert
        assertTrue(mockRabbitTemplate.wasMessagePublished());
        assertEquals(1, mockRabbitTemplate.getPublishedMessageCount());
    }

    @Test
    @DisplayName("Should complete import job with statistics")
    void testCompleteImportJob() {
        // Arrange
        ImportJob job = new ImportJob("job-456", "SPOONACULAR");
        job.setStartedAt(java.time.Instant.now());
        job.setStatus(ImportJob.Status.RUNNING);
        importJobRepository.save(job);

        Long processed = 1000L;
        Long failed = 5L;

        // Act
        ingestionService.completeImportJob("job-456", processed, failed);

        // Assert
        ImportJob completed = importJobRepository.findById("job-456").orElseThrow();
        assertEquals(ImportJob.Status.PARTIAL_FAILURE, completed.getStatus());
        assertEquals(processed, completed.getRecordsProcessed());
        assertEquals(failed, completed.getRecordsFailed());
        assertNotNull(completed.getCompletedAt());
    }

    @Test
    @DisplayName("Should fail import job with error message")
    void testFailImportJob() {
        // Arrange
        ImportJob job = new ImportJob("job-789", "OPEN_FOOD_FACTS");
        job.setStatus(ImportJob.Status.RUNNING);
        importJobRepository.save(job);

        String errorMessage = "API rate limit exceeded";

        // Act
        ingestionService.failImportJob("job-789", errorMessage);

        // Assert
        ImportJob failed = importJobRepository.findById("job-789").orElseThrow();
        assertEquals(ImportJob.Status.FAILED, failed.getStatus());
        assertEquals(errorMessage, failed.getErrorMessage());
        assertNotNull(failed.getCompletedAt());
    }

    private static class MockRabbitTemplate extends RabbitTemplate {
        private int publishCount = 0;

        public void convertAndSend(String queue, Object message) {
            publishCount++;
        }

        public boolean wasMessagePublished() {
            return publishCount > 0;
        }

        public int getPublishedMessageCount() {
            return publishCount;
        }
    }
}
