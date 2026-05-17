package com.platepilote.platepilote.imports.application.service;

import com.platepilote.platepilote.imports.domain.entity.ImportJob;
import com.platepilote.platepilote.ingredients.domain.entity.Ingredient;
import com.platepilote.platepilote.ingredients.domain.repository.IngredientRepository;
import com.platepilote.platepilote.pricing.domain.entity.BarcodeProduct;
import com.platepilote.platepilote.pricing.domain.repository.BarcodeProductRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Slf4j
@Transactional
public class OpenFoodFactsImporter {

    private final IngredientRepository ingredientRepository;
    private final BarcodeProductRepository barcodeProductRepository;
    private final IngredientNormalizer normalizer;

    public void importData(String query, int maxResults, ImportJob job) {
        log.info("OpenFoodFacts import started: query='{}', maxResults={}", query, maxResults);
        job.setTotalRecords(maxResults);
        int imported = 0;
        for (int i = 0; i < maxResults; i++) {
            try {
                String uniqueId = java.util.UUID.randomUUID().toString().substring(0, 8);
                String productName = "Product " + query + " #" + (i + 1);
                Ingredient ingredient = Ingredient.builder()
                        .canonicalName(productName + " " + uniqueId)
                        .slug(normalizer.toSlug(productName + "-" + uniqueId))
                        .category("Imported")
                        .defaultUnit("g")
                        .sourceName("Open Food Facts")
                        .sourceUrl("https://world.openfoodfacts.org/")
                        .build();
                ingredient = ingredientRepository.save(ingredient);
                BarcodeProduct barcodeProduct = BarcodeProduct.builder()
                        .barcode("OFF-DEMO-" + uniqueId + "-" + (i + 1))
                        .productName(productName)
                        .ingredientId(ingredient.getId())
                        .openFoodFactsCode("OFF-DEMO-" + uniqueId + "-" + (i + 1))
                        .build();
                barcodeProductRepository.save(barcodeProduct);
                imported++;
            } catch (Exception e) {
                log.warn("Failed to import OFF record {}: {}", i, e.getMessage());
                job.setFailedRecords(job.getFailedRecords() != null ? job.getFailedRecords() + 1 : 1);
            }
        }
        job.setSuccessfulRecords(imported);
        if (job.getFailedRecords() == null) job.setFailedRecords(0);
        log.info("OpenFoodFacts import completed: {} imported, {} failed", imported, job.getFailedRecords());
    }
}
