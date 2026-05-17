package com.platepilote.platepilote.imports.application.service;

import com.platepilote.platepilote.imports.domain.entity.ImportJob;
import com.platepilote.platepilote.recipes.domain.entity.Recipe;
import com.platepilote.platepilote.recipes.domain.entity.RecipeIngredient;
import com.platepilote.platepilote.recipes.domain.entity.RecipeStep;
import com.platepilote.platepilote.recipes.domain.repository.RecipeIngredientRepository;
import com.platepilote.platepilote.recipes.domain.repository.RecipeRepository;
import com.platepilote.platepilote.recipes.domain.repository.RecipeStepRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
@Slf4j
public class MealDbImporter {

    private final RecipeRepository recipeRepository;
    private final RecipeIngredientRepository recipeIngredientRepository;
    private final RecipeStepRepository recipeStepRepository;
    private final RestTemplate restTemplate;

    @Value("${app.api.themealdb-key}")
    private String apiKey;

    @SuppressWarnings("unchecked")
    public void importData(String query, int maxResults, ImportJob job) {
        log.info("TheMealDB import started: query='{}', maxResults={}", query, maxResults);
        job.setTotalRecords(maxResults);

        String url = "https://www.themealdb.com/api/json/v1/{key}/search.php?s={query}";
        Map<String, Object> response = restTemplate.getForObject(url, Map.class, apiKey, query);

        if (response == null || !response.containsKey("meals") || response.get("meals") == null) {
            log.warn("TheMealDB API returned no results for query '{}'", query);
            job.setSuccessfulRecords(0);
            job.setFailedRecords(0);
            return;
        }

        List<Map<String, Object>> meals = (List<Map<String, Object>>) response.get("meals");
        int imported = 0;
        int count = 0;

        for (Map<String, Object> meal : meals) {
            if (count >= maxResults) break;
            try {
                String idMeal = (String) meal.get("idMeal");
                String mealName = (String) meal.get("strMeal");



                String category = (String) meal.get("strCategory");
                String area = (String) meal.get("strArea");
                String instructions = (String) meal.get("strInstructions");
                String mealThumb = (String) meal.get("strMealThumb");
                String tags = (String) meal.get("strTags");
                String source = (String) meal.get("strSource");

                Recipe recipe = Recipe.builder()
                        .name(mealName)
                        .description("A " + (area != null ? area + " " : "") + (category != null ? category : "MealDB") + " recipe imported from TheMealDB")
                        .servings(4)
                        .difficulty("Medium")
                        .cuisineType(area)
                        .mealType(category)
                        .imageUrl(mealThumb)
                        .isPublic(true)
                        .source("TheMealDB")
                        .sourceUrl(source != null ? source : "https://www.themealdb.com/meal/" + idMeal)
                        .build();

                recipe = recipeRepository.save(recipe);

                for (int i = 1; i <= 20; i++) {
                    String ingredient = (String) meal.get("strIngredient" + i);
                    String measure = (String) meal.get("strMeasure" + i);
                    if (ingredient == null || ingredient.isBlank()) break;

                    BigDecimal qty;
                    try {
                        String cleaned = measure != null ? measure.trim().split("\\s+")[0] : "1";
                        qty = new BigDecimal(cleaned.replaceAll("[^0-9./]", "").isEmpty() ? "1" : cleaned.replaceAll("[^0-9./]", ""));
                    } catch (Exception e) {
                        qty = BigDecimal.ONE;
                    }

                    String unit = "piece";
                    if (measure != null) {
                        String[] parts = measure.trim().split("\\s+");
                        if (parts.length > 1) {
                            unit = measure.trim().substring(parts[0].length()).trim();
                        } else {
                            unit = parts[0].matches("[0-9./]+") ? "piece" : parts[0];
                        }
                    }

                    RecipeIngredient ri = RecipeIngredient.builder()
                            .recipe(recipe)
                            .name(ingredient.trim())
                            .quantity(qty)
                            .unit(unit)
                            .sortOrder(i)
                            .build();

                    recipeIngredientRepository.save(ri);
                }

                if (instructions != null && !instructions.isBlank()) {
                    String[] steps = instructions.split("\\r?\\n");
                    int stepNum = 1;
                    for (String stepText : steps) {
                        String trimmed = stepText.trim();
                        if (trimmed.isEmpty()) continue;

                        RecipeStep recipeStep = RecipeStep.builder()
                                .recipe(recipe)
                                .stepNumber(stepNum)
                                .instruction(trimmed)
                                .build();

                        recipeStepRepository.save(recipeStep);
                        stepNum++;
                    }
                }

                imported++;
                count++;
            } catch (Exception e) {
                log.warn("Failed to import MealDB record: {}", e.getMessage());
                job.setFailedRecords(job.getFailedRecords() != null ? job.getFailedRecords() + 1 : 1);
                count++;
            }
        }

        job.setSuccessfulRecords(imported);
        if (job.getFailedRecords() == null) job.setFailedRecords(0);
        log.info("TheMealDB import completed: {} imported, {} failed", imported, job.getFailedRecords());
    }
}
