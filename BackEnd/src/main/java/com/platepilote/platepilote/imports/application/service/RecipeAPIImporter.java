package com.platepilote.platepilote.imports.application.service;

import com.platepilote.platepilote.imports.domain.entity.ImportJob;
import com.platepilote.platepilote.ingredients.domain.entity.Ingredient;
import com.platepilote.platepilote.ingredients.domain.repository.IngredientRepository;
import com.platepilote.platepilote.recipes.domain.entity.Recipe;
import com.platepilote.platepilote.recipes.domain.entity.RecipeIngredient;
import com.platepilote.platepilote.recipes.domain.entity.RecipeStep;
import com.platepilote.platepilote.recipes.domain.repository.RecipeIngredientRepository;
import com.platepilote.platepilote.recipes.domain.repository.RecipeRepository;
import com.platepilote.platepilote.recipes.domain.repository.RecipeStepRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestClientException;
import org.springframework.web.client.RestTemplate;

import java.math.BigDecimal;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * Importateur de recettes via l'API RecipeAPI.
 * <p>
 * Récupère des recettes avec leurs ingrédients, instructions et informations
 * nutritionnelles depuis RecipeAPI.io et les importe dans le catalogue
 * de recettes PlatePilote.
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class RecipeAPIImporter {

    /** Repository des recettes. */
    private final RecipeRepository recipeRepository;

    /** Repository des ingrédients de recettes. */
    private final RecipeIngredientRepository recipeIngredientRepository;

    /** Repository des étapes de recettes. */
    private final RecipeStepRepository recipeStepRepository;

    /** Repository des ingrédients. */
    private final IngredientRepository ingredientRepository;

    /** Normaliseur d'ingrédients. */
    private final IngredientNormalizer normalizer;

    /** Client HTTP RestTemplate. */
    private final RestTemplate restTemplate;

    /** Clé API RecipeAPI. */
    @Value("${app.api.recipeapi-key:}")
    private String apiKey;

    /**
     * Lance l'import des recettes depuis RecipeAPI.
     *
     * @param query      terme de recherche
     * @param maxResults nombre maximum de résultats
     * @param job        job d'importation en cours
     */
    @SuppressWarnings("unchecked")
    public void importData(String query, int maxResults, ImportJob job) {
        log.info("RecipeAPI import started: query='{}', maxResults={}", query, maxResults);
        job.setTotalRecords(maxResults);

        List<Map<String, Object>> results = null;
        try {
            HttpHeaders headers = new HttpHeaders();
            headers.setBearerAuth(apiKey);
            String url = "https://recipeapi.io/api/v1/recipes?search={query}&per_page={max}";
            Map<String, Object> response = restTemplate.exchange(
                    url, HttpMethod.GET, new HttpEntity<>(headers), Map.class, query, maxResults).getBody();
            if (response != null && response.containsKey("data")) {
                results = (List<Map<String, Object>>) response.get("data");
            }
        } catch (RestClientException e) {
            log.warn("RecipeAPI call failed: {}", e.getMessage());
        }

        if (results == null || results.isEmpty()) {
            log.warn("RecipeAPI returned no data. Skipping import.");
            job.setSuccessfulRecords(0);
            job.setFailedRecords(0);
            return;
        }

        int imported = 0;
        for (Map<String, Object> item : results) {
            try {
                String name = (String) item.get("name");
                if (name == null) continue;

                String description = (String) item.get("description");
                String cuisine = (String) item.get("cuisine");
                String mealType = (String) item.get("meal_type");
                String difficulty = (String) item.get("difficulty");
                Integer servings = (Integer) item.get("servings");
                if (servings == null) servings = 4;
                Integer prepTime = (Integer) item.get("prep_time");
                Integer cookTime = (Integer) item.get("cook_time");
                Integer totalTime = prepTime != null && cookTime != null ? prepTime + cookTime : (prepTime != null ? prepTime : cookTime);
                Integer calPerServing = (Integer) item.get("calories_per_serving");

                String recipeDescription = description != null ? description : "Recipe from RecipeAPI";
                if (cuisine != null) recipeDescription = "A " + cuisine + " recipe from RecipeAPI";

                Recipe recipe = Recipe.builder()
                        .name(name).description(recipeDescription).servings(servings)
                        .prepTimeMinutes(prepTime).cookTimeMinutes(cookTime).totalTimeMinutes(totalTime)
                        .cuisineType(cuisine).mealType(mealType).difficulty(difficulty)
                        .isPublic(true).source("RecipeAPI")
                        .caloriesPerServing(calPerServing).build();

                recipe = recipeRepository.save(recipe);

                List<Map<String, Object>> ingredients = (List<Map<String, Object>>) item.get("ingredients");
                if (ingredients != null) {
                    for (int i = 0; i < ingredients.size(); i++) {
                        Map<String, Object> ing = ingredients.get(i);
                        String ingName = (String) ing.get("name");
                        if (ingName == null) continue;
                        Object qty = ing.get("quantity");
                        String unit = (String) ing.get("unit");
                        BigDecimal quantity = qty instanceof Number n ? BigDecimal.valueOf(n.doubleValue()) : BigDecimal.ONE;

                        recipeIngredientRepository.save(RecipeIngredient.builder()
                                .recipe(recipe).name(ingName).quantity(quantity)
                                .unit(unit != null ? unit : "piece").sortOrder(i + 1).build());
                    }
                }

                List<String> instructions = (List<String>) item.get("instructions");
                if (instructions != null) {
                    for (int i = 0; i < instructions.size(); i++) {
                        String step = instructions.get(i);
                        if (step == null || step.isBlank()) continue;
                        recipeStepRepository.save(RecipeStep.builder()
                                .recipe(recipe).stepNumber(i + 1).instruction(step).build());
                    }
                }

                imported++;
            } catch (Exception e) {
                log.warn("Failed to import RecipeAPI record: {}", e.getMessage());
                job.setFailedRecords(job.getFailedRecords() != null ? job.getFailedRecords() + 1 : 1);
            }
        }

        job.setSuccessfulRecords(imported);
        if (job.getFailedRecords() == null) job.setFailedRecords(0);
        log.info("RecipeAPI import completed: {} imported, {} failed", imported, job.getFailedRecords());
    }

}
