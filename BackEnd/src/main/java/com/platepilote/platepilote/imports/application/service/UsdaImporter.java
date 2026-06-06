package com.platepilote.platepilote.imports.application.service;

import com.platepilote.platepilote.imports.domain.entity.ImportJob;
import com.platepilote.platepilote.ingredients.domain.entity.Ingredient;
import com.platepilote.platepilote.ingredients.domain.repository.IngredientRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestClientException;
import org.springframework.web.client.RestTemplate;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Importateur d'ingrédients via l'API USDA FoodData Central.
 * <p>
 * Récupère des aliments avec leurs valeurs nutritionnelles détaillées
 * (calories, protéines, glucides, lipides, fibres, etc.) depuis
 * la base de données USDA FoodData Central.
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class UsdaImporter {

    /** Repository des ingrédients. */
    private final IngredientRepository ingredientRepository;

    /** Normaliseur d'ingrédients. */
    private final IngredientNormalizer normalizer;

    /** Client HTTP RestTemplate. */
    private final RestTemplate restTemplate;

    /** Clé API USDA. */
    @Value("${app.api.usda-key}")
    private String apiKey;

    /**
     * Lance l'import des ingrédients depuis USDA FoodData Central.
     *
     * @param query      terme de recherche
     * @param maxResults nombre maximum de résultats
     * @param job        job d'importation en cours
     */
    @SuppressWarnings("unchecked")
    public void importData(String query, int maxResults, ImportJob job) {
        log.info("USDA import started: query='{}', maxResults={}", query, maxResults);
        job.setTotalRecords(maxResults);

        List<Map<String, Object>> foods = null;
        try {
            String url = "https://api.nal.usda.gov/fdc/v1/foods/search?api_key=" + apiKey;
            Map<String, Object> requestBody = new HashMap<>();
            requestBody.put("query", query);
            List<String> dataTypes = List.of("Foundation", "SR Legacy");
            requestBody.put("dataType", dataTypes);
            requestBody.put("pageSize", maxResults);
            Map<String, Object> response = restTemplate.postForObject(url, requestBody, Map.class);
            if (response != null && response.containsKey("foods")) {
                foods = (List<Map<String, Object>>) response.get("foods");
            }
        } catch (RestClientException e) {
            log.warn("USDA API call failed: {}", e.getMessage());
        }

        if (foods == null || foods.isEmpty()) {
            log.warn("USDA API returned no data. Skipping import.");
            job.setSuccessfulRecords(0);
            job.setFailedRecords(0);
            return;
        }

        int imported = 0;
        int count = 0;
        for (Map<String, Object> food : foods) {
            if (count >= maxResults) break;
            try {
                String name = (String) food.get("description");
                if (name == null || name.isBlank()) { count++; continue; }

                String slug = normalizer.toSlug(name);
                if (ingredientRepository.findBySlug(slug).isPresent()) { count++; continue; }

                String category = (String) food.get("foodCategory");
                String fdcId = String.valueOf(food.get("fdcId"));

                List<Map<String, Object>> nutrients = (List<Map<String, Object>>) food.get("foodNutrients");
                Double calories = null, protein = null, carbs = null, fat = null;
                Double fiber = null, sugar = null, sodium = null, cholesterol = null;

                if (nutrients != null) {
                    for (Map<String, Object> n : nutrients) {
                        Object valObj = n.get("value");
                        if (valObj == null) continue;
                        double val = ((Number) valObj).doubleValue();
                        String id = String.valueOf(n.get("nutrientId"));
                        switch (id) {
                            case "1008" -> calories = val;
                            case "1003" -> protein = val;
                            case "1005" -> carbs = val;
                            case "1004" -> fat = val;
                            case "1079" -> fiber = val;
                            case "2000" -> sugar = val;
                            case "1093" -> sodium = val;
                        }
                    }
                }

                Ingredient ingredient = Ingredient.builder()
                        .canonicalName(name)
                        .slug(slug)
                        .category(category != null ? category : "Imported")
                        .description("Imported from USDA FoodData Central (FDC ID: " + fdcId + ")")
                        .defaultUnit("g")
                        .caloriesPer100g(calories).proteinPer100g(protein)
                        .carbohydratesPer100g(carbs).fatPer100g(fat)
                        .fiberPer100g(fiber).sugarPer100g(sugar)
                        .sodiumMgPer100g(sodium).cholesterolMgPer100g(cholesterol)
                        .sourceName("USDA FoodData Central")
                        .sourceUrl("https://fdc.nal.usda.gov/food/" + fdcId)
                        .usdaFdcId(fdcId)
                        .build();

                ingredientRepository.save(ingredient);
                imported++;
                count++;
            } catch (Exception e) {
                log.warn("Failed to import USDA record: {}", e.getMessage());
                job.setFailedRecords(job.getFailedRecords() != null ? job.getFailedRecords() + 1 : 1);
                count++;
            }
        }

        job.setSuccessfulRecords(imported);
        if (job.getFailedRecords() == null) job.setFailedRecords(0);
        log.info("USDA import completed: {} imported, {} failed", imported, job.getFailedRecords());
    }
}
