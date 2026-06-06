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
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestClientException;
import org.springframework.web.client.RestTemplate;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

/**
 * Importateur de recettes via l'API Tasty.
 * <p>
 * Récupère des recettes avec leurs sections, ingrédients, instructions
 * et informations nutritionnelles depuis la plateforme Tasty.
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class TastyImporter {

    /** Repository des recettes. */
    private final RecipeRepository recipeRepository;

    /** Repository des ingrédients de recettes. */
    private final RecipeIngredientRepository recipeIngredientRepository;

    /** Repository des étapes de recettes. */
    private final RecipeStepRepository recipeStepRepository;

    /** Client HTTP RestTemplate. */
    private final RestTemplate restTemplate;

    /**
     * Lance l'import des recettes depuis Tasty.
     *
     * @param query      terme de recherche
     * @param maxResults nombre maximum de résultats
     * @param job        job d'importation en cours
     */
    @SuppressWarnings("unchecked")
    public void importData(String query, int maxResults, ImportJob job) {
        log.info("Tasty import started: query='{}', maxResults={}", query, maxResults);
        job.setTotalRecords(maxResults);

        List<Map<String, Object>> recipes = null;
        try {
            String url = "https://tasty.p.rapidapi.com/recipes/list?from=0&size={max}&q={query}";
            org.springframework.http.HttpHeaders headers = new org.springframework.http.HttpHeaders();
            headers.set("X-RapidAPI-Key", "");
            headers.set("X-RapidAPI-Host", "tasty.p.rapidapi.com");
            org.springframework.http.HttpEntity<?> entity = new org.springframework.http.HttpEntity<>(headers);
            Map<String, Object> response = restTemplate.getForObject(url, Map.class, query);

            if (response != null && response.containsKey("results")) {
                recipes = (List<Map<String, Object>>) response.get("results");
            }
        } catch (RestClientException e) {
            log.warn("Tasty API call failed: {}", e.getMessage());
        }

        if (recipes == null || recipes.isEmpty()) {
            log.warn("Tasty API returned no data. Skipping import.");
            job.setSuccessfulRecords(0);
            job.setFailedRecords(0);
            return;
        }

        int imported = 0;
        for (Map<String, Object> item : recipes) {
            try {
                String name = (String) item.get("name");
                if (name == null) continue;

                String description = (String) item.get("description");
                String thumbnailUrl = (String) item.get("thumbnail_url");
                Integer cookTime = (Integer) item.get("cook_time_minutes");
                Integer prepTime = (Integer) item.get("prep_time_minutes");
                Integer totalTime = (Integer) item.get("total_time_minutes");
                Integer servings = (Integer) item.get("num_servings");
                if (servings == null) servings = 4;

                String cuisine = (String) item.get("cuisine");
                String mealType = extractFirst(item, "tags");

                Double calories = null;
                Map<String, Object> nutrition = (Map<String, Object>) item.get("nutrition");
                if (nutrition != null) calories = getDouble(nutrition, "calories");

                Recipe recipe = Recipe.builder()
                        .name(name).description(description != null ? description : "Recipe from Tasty")
                        .servings(servings).prepTimeMinutes(prepTime).cookTimeMinutes(cookTime)
                        .totalTimeMinutes(totalTime).cuisineType(cuisine).mealType(mealType)
                        .imageUrl(thumbnailUrl).isPublic(true).source("Tasty")
                        .caloriesPerServing(calories != null ? calories.intValue() : null).build();

                recipe = recipeRepository.save(recipe);

                List<Map<String, Object>> sections = (List<Map<String, Object>>) item.get("sections");
                if (sections != null) {
                    int sortOrder = 0;
                    for (Map<String, Object> section : sections) {
                        List<Map<String, Object>> components = (List<Map<String, Object>>) section.get("components");
                        if (components != null) {
                            for (Map<String, Object> comp : components) {
                                sortOrder++;
                                Map<String, Object> ingMap = (Map<String, Object>) comp.get("ingredient");
                                String ingName = ingMap != null ? (String) ingMap.get("name") : null;
                                if (ingName == null) continue;
                                String rawQty = (String) comp.get("raw_text");
                                BigDecimal qty = BigDecimal.ONE;
                                String unit = "piece";
                                if (rawQty != null && !rawQty.isBlank()) {
                                    String[] parts = rawQty.trim().split("\\s+");
                                    try {
                                        qty = new BigDecimal(parts[0].replaceAll("[^0-9.]", ""));
                                        if (parts.length > 1) unit = parts[1];
                                    } catch (Exception ignored) {}
                                }
                                recipeIngredientRepository.save(RecipeIngredient.builder()
                                        .recipe(recipe).name(ingName).quantity(qty).unit(unit)
                                        .sortOrder(sortOrder).build());
                            }
                        }
                    }
                }

                List<Map<String, Object>> instructions = (List<Map<String, Object>>) item.get("instructions");
                if (instructions != null) {
                    int stepNum = 1;
                    for (Map<String, Object> instr : instructions) {
                        String text = (String) instr.get("display_text");
                        if (text == null || text.isBlank()) continue;
                        Integer position = (Integer) instr.get("position");
                        if (position != null) stepNum = position;
                        recipeStepRepository.save(RecipeStep.builder()
                                .recipe(recipe).stepNumber(stepNum).instruction(text).build());
                        stepNum++;
                    }
                }

                imported++;
            } catch (Exception e) {
                log.warn("Failed to import Tasty record: {}", e.getMessage());
                job.setFailedRecords(job.getFailedRecords() != null ? job.getFailedRecords() + 1 : 1);
            }
        }

        job.setSuccessfulRecords(imported);
        if (job.getFailedRecords() == null) job.setFailedRecords(0);
        log.info("Tasty import completed: {} imported, {} failed", imported, job.getFailedRecords());
    }

    private String extractFirst(Map<String, Object> map, String key) {
        Object val = map.get(key);
        if (val instanceof List<?> list && !list.isEmpty() && list.get(0) instanceof Map<?, ?> tagMap) {
            Object name = tagMap.get("name");
            return name != null ? name.toString() : null;
        }
        return null;
    }

    private Double getDouble(Map<String, Object> map, String key) {
        Object val = map.get(key);
        if (val instanceof Number n) return n.doubleValue();
        return null;
    }
}
