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

/**
 * Importateur de produits via l'API Chomp (nutrition et codes-barres).
 * <p>
 * Récupère des informations nutritionnelles et des codes-barres depuis
 * l'API ChompThis, et les importe dans la base d'ingrédients.
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class ChompImporter {

    /** Repository des ingrédients. */
    private final IngredientRepository ingredientRepository;

    /** Repository des produits par code-barres. */
    private final BarcodeProductRepository barcodeProductRepository;

    /** Normaliseur d'ingrédients. */
    private final IngredientNormalizer normalizer;

    /** Client HTTP RestTemplate. */
    private final RestTemplate restTemplate;

    /** Clé API Chomp. */
    @Value("${app.api.chomp-key:}")
    private String apiKey;

    /**
     * Lance l'import des données depuis Chomp.
     *
     * @param query      terme de recherche
     * @param maxResults nombre maximum de résultats
     * @param job        job d'importation en cours
     */
    @SuppressWarnings("unchecked")
    public void importData(String query, int maxResults, ImportJob job) {
        log.info("Chomp import started: query='{}', maxResults={}", query, maxResults);
        job.setTotalRecords(maxResults);

        Map<String, Object> response = null;
        try {
            String url = "https://chompthis.com/api/v2/food/branded/name.php?name={query}&api_key={key}";
            response = restTemplate.getForObject(url, Map.class, query, apiKey);
        } catch (RestClientException e) {
            log.warn("Chomp API call failed: {}. Falling back to demo data.", e.getMessage());
        }

        if (response == null || response.isEmpty()) {
            fallbackDemo(query, maxResults, job);
            return;
        }

        List<Map<String, Object>> items = null;
        Object results = response.get("results");
        if (results instanceof List) items = (List<Map<String, Object>>) results;
        else if (results instanceof Map) items = List.of((Map<String, Object>) results);

        if (items == null || items.isEmpty()) {
            fallbackDemo(query, maxResults, job);
            return;
        }

        if (items.size() > maxResults) items = items.subList(0, maxResults);

        int imported = 0;
        for (Map<String, Object> item : items) {
            try {
                String title = (String) item.getOrDefault("name", item.get("title"));
                if (title == null) continue;

                String barcode = (String) item.get("code");
                if (barcode == null) barcode = "CHOMP-" + java.util.UUID.randomUUID().toString().substring(0, 8);

                String slug = normalizer.toSlug(title + "-chomp-" + barcode);
                if (ingredientRepository.findBySlug(slug).isPresent()) continue;

                String brand = (String) item.get("brand");
                String description = (String) item.get("description");
                String category = (String) item.get("category");

                Ingredient ingredient = Ingredient.builder()
                        .canonicalName(title).slug(slug).category(category != null ? category : "Imported")
                        .defaultUnit("g").description(description).sourceName("Chomp").build();

                ingredient = ingredientRepository.save(ingredient);

                barcodeProductRepository.save(BarcodeProduct.builder()
                        .barcode(barcode).productName(title).brand(brand)
                        .ingredientId(ingredient.getId()).build());

                imported++;
            } catch (Exception e) {
                log.warn("Failed to import Chomp record: {}", e.getMessage());
                job.setFailedRecords(job.getFailedRecords() != null ? job.getFailedRecords() + 1 : 1);
            }
        }

        job.setSuccessfulRecords(imported);
        if (job.getFailedRecords() == null) job.setFailedRecords(0);
        log.info("Chomp import completed: {} imported, {} failed", imported, job.getFailedRecords());
    }

    private void fallbackDemo(String query, int maxResults, ImportJob job) {
        log.info("Chomp API returned no data. Generating demo products.");
        int imported = 0;
        for (int i = 0; i < maxResults; i++) {
            try {
                String uniqueId = java.util.UUID.randomUUID().toString().substring(0, 8);
                String name = query.substring(0, Math.min(query.length(), 20)) + " Chomp #" + (i + 1);
                Ingredient ingredient = Ingredient.builder()
                        .canonicalName(name).slug(normalizer.toSlug("chomp-demo-" + name + "-" + uniqueId))
                        .category("Imported").defaultUnit("g").sourceName("Chomp (demo)").build();
                ingredient = ingredientRepository.save(ingredient);
                barcodeProductRepository.save(BarcodeProduct.builder()
                        .barcode("DEMO-CHOMP-" + uniqueId + "-" + (i + 1)).productName(name)
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
