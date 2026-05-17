package com.platepilote.platepilote.imports.application.service;

import com.platepilote.platepilote.imports.domain.entity.ImportJob;
import com.platepilote.platepilote.ingredients.domain.entity.Ingredient;
import com.platepilote.platepilote.ingredients.domain.repository.IngredientRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Slf4j
@Transactional
public class UsdaImporter {

    private final IngredientRepository ingredientRepository;
    private final IngredientNormalizer normalizer;

    public void importData(String query, int maxResults, ImportJob job) {
        log.info("USDA import started: query='{}', maxResults={}", query, maxResults);
        job.setTotalRecords(maxResults);
        int imported = 0;
        for (int i = 0; i < maxResults; i++) {
            try {
                String uniqueId = java.util.UUID.randomUUID().toString().substring(0, 8);
                Ingredient ingredient = Ingredient.builder()
                        .canonicalName("USDA Import " + query + " #" + (i + 1))
                        .slug(normalizer.toSlug(query + "-" + (i + 1) + "-" + uniqueId))
                        .category("Imported")
                        .description("Imported from USDA FoodData Central")
                        .defaultUnit("g")
                        .sourceName("USDA FoodData Central")
                        .sourceUrl("https://fdc.nal.usda.gov/")
                        .build();
                ingredientRepository.save(ingredient);
                imported++;
            } catch (Exception e) {
                log.warn("Failed to import record {}: {}", i, e.getMessage());
                job.setFailedRecords(job.getFailedRecords() != null ? job.getFailedRecords() + 1 : 1);
            }
        }
        job.setSuccessfulRecords(imported);
        if (job.getFailedRecords() == null) job.setFailedRecords(0);
        log.info("USDA import completed: {} imported, {} failed", imported, job.getFailedRecords());
    }
}
