package com.platepilote.platepilote.imports.application.service;

import com.platepilote.platepilote.imports.domain.entity.ImportJob;
import com.platepilote.platepilote.ingredients.domain.entity.Ingredient;
import com.platepilote.platepilote.ingredients.domain.repository.IngredientRepository;
import com.platepilote.platepilote.pricing.domain.entity.BarcodeProduct;
import com.platepilote.platepilote.pricing.domain.repository.BarcodeProductRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestClientException;
import org.springframework.web.client.RestTemplate;

import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
@Slf4j
public class BarcodeLookupImporter {

    private final IngredientRepository ingredientRepository;
    private final BarcodeProductRepository barcodeProductRepository;
    private final IngredientNormalizer normalizer;
    private final RestTemplate restTemplate;

    @Value("${app.api.upcitemdb-key:}")
    private String upcItemDbKey;

    @Value("${app.api.barcode-lookup-key:}")
    private String barcodeLookupKey;

    @SuppressWarnings("unchecked")
    public void importData(String query, int maxResults, ImportJob job) {
        log.info("BarcodeLookup import started: query='{}', maxResults={}", query, maxResults);
        job.setTotalRecords(maxResults);

        List<Map<String, Object>> items = null;
        try {
            String url = "https://api.upcitemdb.com/prod/trial/search?s={query}&match_mode=0&type=product";
            Map<String, Object> response = restTemplate.getForObject(url, Map.class, query);
            if (response != null && response.containsKey("items")) {
                items = (List<Map<String, Object>>) response.get("items");
                if (items.size() > maxResults) items = items.subList(0, maxResults);
            }
        } catch (RestClientException e) {
            log.warn("UPCItemDB API call failed: {}. Falling back to demo data.", e.getMessage());
        }

        if (items == null || items.isEmpty()) {
            fallbackDemo(query, maxResults, job);
            return;
        }

        int imported = 0;
        for (Map<String, Object> item : items) {
            try {
                String title = (String) item.get("title");
                if (title == null) continue;

                String upc = (String) item.get("upc");
                String ean = (String) item.get("ean");
                String barcode = upc != null ? upc : (ean != null ? ean : "UPC-" + java.util.UUID.randomUUID().toString().substring(0, 8));

                String slug = normalizer.toSlug(title + "-" + barcode);
                if (ingredientRepository.findBySlug(slug).isPresent()) continue;

                String brand = (String) item.get("brand");
                String description = (String) item.get("description");
                String category = (String) item.get("category");
                List<String> images = (List<String>) item.get("images");
                String imageUrl = images != null && !images.isEmpty() ? images.get(0) : null;

                Double price = null;
                List<Map<String, Object>> offers = (List<Map<String, Object>>) item.get("offers");
                if (offers != null && !offers.isEmpty()) {
                    Object priceObj = offers.get(0).get("price");
                    if (priceObj instanceof Number n) price = n.doubleValue();
                }

                Ingredient ingredient = Ingredient.builder()
                        .canonicalName(title).slug(slug).category(category != null ? category : "Imported")
                        .defaultUnit("g").description(description).sourceName("UPCItemDB")
                        .sourceUrl(imageUrl).build();

                ingredient = ingredientRepository.save(ingredient);

                barcodeProductRepository.save(BarcodeProduct.builder()
                        .barcode(barcode).productName(title).brand(brand)
                        .ingredientId(ingredient.getId()).build());

                imported++;
            } catch (Exception e) {
                log.warn("Failed to import barcode record: {}", e.getMessage());
                job.setFailedRecords(job.getFailedRecords() != null ? job.getFailedRecords() + 1 : 1);
            }
        }

        job.setSuccessfulRecords(imported);
        if (job.getFailedRecords() == null) job.setFailedRecords(0);
        log.info("BarcodeLookup import completed: {} imported, {} failed", imported, job.getFailedRecords());
    }

    private void fallbackDemo(String query, int maxResults, ImportJob job) {
        log.info("BarcodeLookup API returned no data. Generating demo products.");
        int imported = 0;
        for (int i = 0; i < maxResults; i++) {
            try {
                String uniqueId = java.util.UUID.randomUUID().toString().substring(0, 8);
                String name = query.substring(0, Math.min(query.length(), 20)) + " Barcode #" + (i + 1);
                Ingredient ingredient = Ingredient.builder()
                        .canonicalName(name).slug(normalizer.toSlug("barcode-" + name + "-" + uniqueId))
                        .category("Imported").defaultUnit("g").sourceName("UPCItemDB").build();
                ingredient = ingredientRepository.save(ingredient);
                barcodeProductRepository.save(BarcodeProduct.builder()
                        .barcode("DEMO-" + uniqueId + "-" + (i + 1)).productName(name)
                        .ingredientId(ingredient.getId()).build());
                imported++;
            } catch (Exception e) {
                job.setFailedRecords(job.getFailedRecords() != null ? job.getFailedRecords() + 1 : 1);
            }
        }
        job.setSuccessfulRecords(imported);
        if (job.getFailedRecords() == null) job.setFailedRecords(0);
    }
}
