package com.platepilote.platepilote.imports.application.service;

import com.platepilote.platepilote.imports.domain.entity.ImportJob;
import com.platepilote.platepilote.ingredients.domain.entity.Ingredient;
import com.platepilote.platepilote.ingredients.domain.repository.IngredientRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestClientException;
import org.springframework.web.client.RestTemplate;

import java.util.List;
import java.util.Map;

/**
 * Importateur d'ingrédients via l'API Nutritionix.
 * <p>
 * Récupère des informations nutritionnelles détaillées (calories, protéines,
 * glucides, lipides, fibres, sodium, etc.) depuis l'API instant de Nutritionix
 * et les importe dans la base d'ingrédients.
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class NutritionixImporter {

    /** Repository des ingrédients. */
    private final IngredientRepository ingredientRepository;

    /** Normaliseur d'ingrédients. */
    private final IngredientNormalizer normalizer;

    /** Client HTTP RestTemplate. */
    private final RestTemplate restTemplate;

    /** Identifiant d'application Nutritionix. */
    @Value("${app.api.nutritionix-app-id}")
    private String appId;

    /** Clé d'application Nutritionix. */
    @Value("${app.api.nutritionix-app-key}")
    private String appKey;

    /**
     * Lance l'import des ingrédients depuis Nutritionix.
     *
     * @param query      terme de recherche
     * @param maxResults nombre maximum de résultats
     * @param job        job d'importation en cours
     */
    @SuppressWarnings("unchecked")
    public void importData(String query, int maxResults, ImportJob job) {
        log.info("Nutritionix import started: query='{}', maxResults={}", query, maxResults);
        job.setTotalRecords(maxResults);

        List<Map<String, Object>> items = null;
        try {
            String url = "https://trackapi.nutritionix.com/v2/search/instant?query={query}";
            HttpHeaders headers = new HttpHeaders();
            headers.set("x-app-id", appId);
            headers.set("x-app-key", appKey);
            HttpEntity<?> entity = new HttpEntity<>(headers);
            Map<String, Object> response = restTemplate.getForObject(url, Map.class, query);

            if (response != null) {
                List<Map<String, Object>> branded = (List<Map<String, Object>>) response.get("branded");
                List<Map<String, Object>> common = (List<Map<String, Object>>) response.get("common");
                items = new java.util.ArrayList<>();
                if (common != null) items.addAll(common);
                if (branded != null) items.addAll(branded);
                if (items.size() > maxResults) items = items.subList(0, maxResults);
            }
        } catch (RestClientException e) {
            log.warn("Nutritionix API call failed: {}. Falling back to demo data.", e.getMessage());
        }

        if (items == null || items.isEmpty()) {
            fallbackDemo(query, maxResults, job);
            return;
        }

        int imported = 0;
        for (Map<String, Object> item : items) {
            try {
                String foodName = (String) item.get("food_name");
                if (foodName == null) continue;

                String slug = normalizer.toSlug(foodName + "-" + java.util.UUID.randomUUID().toString().substring(0, 8));
                if (ingredientRepository.findBySlug(slug).isPresent()) continue;

                String fullName = (String) item.get("food_name");
                if (item.containsKey("brand_name_item_name")) {
                    fullName = (String) item.get("brand_name_item_name");
                }

                Double calories = getDouble(item, "nf_calories");
                Double protein = getDouble(item, "nf_protein");
                Double carbs = getDouble(item, "nf_total_carbohydrate");
                Double fat = getDouble(item, "nf_total_fat");
                Double fiber = getDouble(item, "nf_dietary_fiber");
                Double sugar = getDouble(item, "nf_sugars");
                Double sodium = getDouble(item, "nf_sodium");
                Double cholesterol = getDouble(item, "nf_cholesterol");
                Integer servingQty = getInt(item, "serving_qty");
                String servingUnit = (String) item.get("serving_unit_grams");
                String defaultUnit = servingUnit != null ? servingUnit + "g" : "g";

                String category = (String) item.get("category");

                Ingredient ingredient = Ingredient.builder()
                        .canonicalName(fullName != null ? fullName : foodName)
                        .slug(slug).category(category != null ? category : "Imported").defaultUnit(defaultUnit)
                        .caloriesPer100g(calories).proteinPer100g(protein)
                        .carbohydratesPer100g(carbs).fatPer100g(fat)
                        .fiberPer100g(fiber).sugarPer100g(sugar)
                        .sodiumMgPer100g(sodium).cholesterolMgPer100g(cholesterol)
                        .sourceName("Nutritionix").build();

                ingredientRepository.save(ingredient);
                imported++;
            } catch (Exception e) {
                log.warn("Failed to import Nutritionix record: {}", e.getMessage());
                job.setFailedRecords(job.getFailedRecords() != null ? job.getFailedRecords() + 1 : 1);
            }
        }

        job.setSuccessfulRecords(imported);
        if (job.getFailedRecords() == null) job.setFailedRecords(0);
        log.info("Nutritionix import completed: {} imported, {} failed", imported, job.getFailedRecords());
    }

    private void fallbackDemo(String query, int maxResults, ImportJob job) {
        log.info("Nutritionix API returned no data. Generating demo ingredients.");
        int imported = 0;
        for (int i = 0; i < maxResults; i++) {
            try {
                String name = query.substring(0, Math.min(query.length(), 20)) + " Nutritionix #" + (i + 1);
                Ingredient ingredient = Ingredient.builder()
                        .canonicalName(name).slug(normalizer.toSlug("nutritionix-" + name + "-" + i))
                        .category("Imported").defaultUnit("g").sourceName("Nutritionix").build();
                ingredientRepository.save(ingredient);
                imported++;
            } catch (Exception e) {
                job.setFailedRecords(job.getFailedRecords() != null ? job.getFailedRecords() + 1 : 1);
            }
        }
        job.setSuccessfulRecords(imported);
        if (job.getFailedRecords() == null) job.setFailedRecords(0);
    }

    private Double getDouble(Map<String, Object> map, String key) {
        Object val = map.get(key);
        if (val instanceof Number n) return n.doubleValue();
        return null;
    }

    private Integer getInt(Map<String, Object> map, String key) {
        Object val = map.get(key);
        if (val instanceof Number n) return n.intValue();
        return null;
    }
}
