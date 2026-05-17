package com.platepilote.platepilote.imports.application.service;

import com.platepilote.platepilote.imports.domain.entity.ImportJob;
import com.platepilote.platepilote.ingredients.domain.entity.Ingredient;
import com.platepilote.platepilote.ingredients.domain.repository.IngredientRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
@Slf4j
public class UsdaImporter {

    private final IngredientRepository ingredientRepository;
    private final IngredientNormalizer normalizer;
    private final RestTemplate restTemplate;

    @Value("${app.api.usda-key}")
    private String apiKey;

    @SuppressWarnings("unchecked")
    public void importData(String query, int maxResults, ImportJob job) {
        log.info("USDA import started: query='{}', maxResults={}", query, maxResults);
        job.setTotalRecords(maxResults);

        String url = "https://api.nal.usda.gov/fdc/v1/foods/search?api_key={key}&query={query}&pageSize={size}&dataType=Foundation,SR Legacy";
        Map<String, Object> response = restTemplate.getForObject(url, Map.class,
                apiKey, query, maxResults);

        if (response == null || !response.containsKey("foods")) {
            log.warn("USDA API returned no results");
            job.setSuccessfulRecords(0);
            job.setFailedRecords(0);
            return;
        }

        List<Map<String, Object>> foods = (List<Map<String, Object>>) response.get("foods");
        int imported = 0;

        for (Map<String, Object> food : foods) {
            try {
                String name = (String) food.get("description");
                if (name == null || name.isBlank()) continue;

                String slug = normalizer.toSlug(name);
                if (ingredientRepository.findBySlug(slug).isPresent()) {
                    log.debug("Ingredient '{}' already exists, skipping", name);
                    continue;
                }

                String category = (String) food.get("foodCategory");
                String fdcId = String.valueOf(food.get("fdcId"));
                String dataType = (String) food.get("foodCategory");

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
                            case "1018" -> cholesterol = val;
                        }
                    }
                }

                Ingredient ingredient = Ingredient.builder()
                        .canonicalName(name)
                        .slug(slug)
                        .category(category != null ? category : "Imported")
                        .description("Imported from USDA FoodData Central (FDC ID: " + fdcId + ")")
                        .defaultUnit("g")
                        .caloriesPer100g(calories)
                        .proteinPer100g(protein)
                        .carbohydratesPer100g(carbs)
                        .fatPer100g(fat)
                        .fiberPer100g(fiber)
                        .sugarPer100g(sugar)
                        .sodiumMgPer100g(sodium)
                        .cholesterolMgPer100g(cholesterol)
                        .sourceName("USDA FoodData Central")
                        .sourceUrl("https://fdc.nal.usda.gov/food/" + fdcId)
                        .usdaFdcId(fdcId)
                        .build();

                ingredientRepository.save(ingredient);
                imported++;
            } catch (Exception e) {
                log.warn("Failed to import USDA record: {}", e.getMessage());
                job.setFailedRecords(job.getFailedRecords() != null ? job.getFailedRecords() + 1 : 1);
            }
        }

        job.setSuccessfulRecords(imported);
        if (job.getFailedRecords() == null) job.setFailedRecords(0);
        log.info("USDA import completed: {} imported, {} failed", imported, job.getFailedRecords());
    }
}
