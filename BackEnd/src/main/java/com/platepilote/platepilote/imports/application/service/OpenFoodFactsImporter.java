package com.platepilote.platepilote.imports.application.service;

import com.platepilote.platepilote.imports.domain.entity.ImportJob;
import com.platepilote.platepilote.ingredients.domain.entity.Ingredient;
import com.platepilote.platepilote.ingredients.domain.repository.IngredientRepository;
import com.platepilote.platepilote.pricing.domain.entity.BarcodeProduct;
import com.platepilote.platepilote.pricing.domain.repository.BarcodeProductRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestClientException;
import org.springframework.web.client.RestTemplate;

import java.util.List;
import java.util.Map;

/**
 * Importateur de produits via l'API Open Food Facts.
 * <p>
 * Récupère des produits alimentaires avec leurs informations nutritionnelles
 * et codes-barres depuis la base Open Food Facts. Les données sont importées
 * dans les entités Ingredient et BarcodeProduct.
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class OpenFoodFactsImporter {

    /** Repository des ingrédients. */
    private final IngredientRepository ingredientRepository;

    /** Repository des produits par code-barres. */
    private final BarcodeProductRepository barcodeProductRepository;

    /** Normaliseur d'ingrédients. */
    private final IngredientNormalizer normalizer;

    /** Client HTTP RestTemplate. */
    private final RestTemplate restTemplate;

    /**
     * Lance l'import des produits depuis Open Food Facts.
     *
     * @param query      terme de recherche
     * @param maxResults nombre maximum de résultats
     * @param job        job d'importation en cours
     */
    @SuppressWarnings("unchecked")
    public void importData(String query, int maxResults, ImportJob job) {
        log.info("OpenFoodFacts import started: query='{}', maxResults={}", query, maxResults);
        job.setTotalRecords(maxResults);

        List<Map<String, Object>> products = null;
        try {
            String url = "https://world.openfoodfacts.org/cgi/search.pl?search_terms={query}&json=1&page_size={size}";
            Map<String, Object> response = restTemplate.getForObject(url, Map.class, query, maxResults);
            if (response != null && response.containsKey("products")) {
                products = (List<Map<String, Object>>) response.get("products");
            }
        } catch (RestClientException e) {
            log.warn("OpenFoodFacts API call failed: {}", e.getMessage());
        }

        if (products == null || products.isEmpty()) {
            log.warn("OpenFoodFacts API returned no data. Skipping import.");
            job.setSuccessfulRecords(0);
            job.setFailedRecords(0);
            return;
        }

        int imported = 0;
        for (Map<String, Object> product : products) {
            try {
                String productName = (String) product.get("product_name");
                if (productName == null || productName.isBlank()) continue;

                String code = (String) product.get("code");
                String slug = normalizer.toSlug(productName + "-" + (code != null ? code : java.util.UUID.randomUUID().toString().substring(0, 8)));

                if (ingredientRepository.findBySlug(slug).isPresent()) continue;

                Map<String, Object> nutriments = (Map<String, Object>) product.get("nutriments");
                Double calories = null, protein = null, carbs = null, fat = null;
                Double fiber = null, sugar = null, sodium = null;

                if (nutriments != null) {
                    calories = getDouble(nutriments, "energy-kcal_100g");
                    protein = getDouble(nutriments, "proteins_100g");
                    carbs = getDouble(nutriments, "carbohydrates_100g");
                    fat = getDouble(nutriments, "fat_100g");
                    fiber = getDouble(nutriments, "fiber_100g");
                    sugar = getDouble(nutriments, "sugars_100g");
                    sodium = getDouble(nutriments, "sodium_100g");
                }

                String categories = (String) product.get("categories");
                String firstCategory = categories != null ? categories.split(",")[0].trim() : "Imported";

                Ingredient ingredient = Ingredient.builder()
                        .canonicalName(productName).slug(slug).category(firstCategory).defaultUnit("g")
                        .caloriesPer100g(calories).proteinPer100g(protein)
                        .carbohydratesPer100g(carbs).fatPer100g(fat)
                        .fiberPer100g(fiber).sugarPer100g(sugar).sodiumMgPer100g(sodium)
                        .sourceName("Open Food Facts")
                        .sourceUrl("https://world.openfoodfacts.org/product/" + code)
                        .openFoodFactsCode(code).build();

                ingredient = ingredientRepository.save(ingredient);

                barcodeProductRepository.save(BarcodeProduct.builder()
                        .barcode(code != null ? code : "OFF-" + java.util.UUID.randomUUID().toString().substring(0, 8))
                        .productName(productName).ingredientId(ingredient.getId()).openFoodFactsCode(code).build());

                imported++;
            } catch (Exception e) {
                log.warn("Failed to import OFF record: {}", e.getMessage());
                job.setFailedRecords(job.getFailedRecords() != null ? job.getFailedRecords() + 1 : 1);
            }
        }

        job.setSuccessfulRecords(imported);
        if (job.getFailedRecords() == null) job.setFailedRecords(0);
        log.info("OpenFoodFacts import completed: {} imported, {} failed", imported, job.getFailedRecords());
    }

    private Double getDouble(Map<String, Object> map, String key) {
        Object val = map.get(key);
        if (val instanceof Number n) return n.doubleValue();
        return null;
    }
}
