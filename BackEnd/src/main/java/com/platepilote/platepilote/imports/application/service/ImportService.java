package com.platepilote.platepilote.imports.application.service;

import com.platepilote.platepilote.common.dto.ApiResponse;
import com.platepilote.platepilote.imports.domain.entity.ImportJob;
import com.platepilote.platepilote.imports.domain.repository.ImportJobRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Async;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;

@Slf4j

@Service
@RequiredArgsConstructor
@Transactional
public class ImportService {

    private final ImportJobRepository importJobRepository;
    private final UsdaImporter usdaImporter;
    private final OpenFoodFactsImporter openFoodFactsImporter;
    private final MealDbImporter mealDbImporter;

    @Async
    public ImportJob importFromUsda(String query, int maxResults) {
        ImportJob job = createJob("USDA_FOOD_DATA_CENTRAL");
        try {
            usdaImporter.importData(query, maxResults, job);
            markCompleted(job);
        } catch (Exception e) {
            markFailed(job, e.getMessage());
        }
        return job;
    }

    @Async
    public ImportJob importFromOpenFoodFacts(String query, int maxResults) {
        ImportJob job = createJob("OPEN_FOOD_FACTS");
        try {
            openFoodFactsImporter.importData(query, maxResults, job);
            markCompleted(job);
        } catch (Exception e) {
            markFailed(job, e.getMessage());
        }
        return job;
    }

    @Async
    public ImportJob importFromMealDb(String query, int maxResults) {
        ImportJob job = createJob("THE_MEAL_DB");
        try {
            mealDbImporter.importData(query, maxResults, job);
            markCompleted(job);
        } catch (Exception e) {
            markFailed(job, e.getMessage());
        }
        return job;
    }

    @Scheduled(cron = "0 0 2 * * ?") // Run at 2:00 AM daily
    public void scheduledNightlyImport() {
        log.info("Starting scheduled nightly import");
        importFromUsda("chicken,rice,beans,tomato,onion", 20);
        importFromOpenFoodFacts("rice,pasta,sauce,oil", 20);
        importFromMealDb("chicken,beef,pasta,curry,salad", 10);
    }

    private ImportJob createJob(String source) {
        ImportJob job = ImportJob.builder()
                .source(source)
                .status("RUNNING")
                .startedAt(Instant.now())
                .build();
        return importJobRepository.save(job);
    }

    private void markCompleted(ImportJob job) {
        job.setStatus("COMPLETED");
        job.setCompletedAt(Instant.now());
        importJobRepository.save(job);
    }

    private void markFailed(ImportJob job, String error) {
        job.setStatus("FAILED");
        job.setErrorMessage(error);
        job.setCompletedAt(Instant.now());
        importJobRepository.save(job);
    }
}
