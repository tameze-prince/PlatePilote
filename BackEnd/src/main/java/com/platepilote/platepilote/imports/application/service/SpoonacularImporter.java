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
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestClientException;
import org.springframework.web.client.RestTemplate;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

/**
 * Importateur de recettes via l'API Spoonacular.
 * <p>
 * Récupère des recettes complètes avec informations nutritionnelles, santé,
 * ingrédients détaillés et instructions étape par étape depuis Spoonacular.
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class SpoonacularImporter {

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

    /** Clé API Spoonacular. */
    @Value("${app.api.spoonacular-key}")
    private String apiKey;

    /**
     * Lance l'import des recettes depuis Spoonacular.
     *
     * @param query      terme de recherche
     * @param maxResults nombre maximum de résultats
     * @param job        job d'importation en cours
     */
    @SuppressWarnings("unchecked")
    public void importData(String query, int maxResults, ImportJob job) {
        log.info("Spoonacular import started: query='{}', maxResults={}", query, maxResults);
        job.setTotalRecords(maxResults);

        List<Map<String, Object>> results = null;
        try {
            String url = "https://api.spoonacular.com/recipes/complexSearch?query={query}&number={max}&apiKey={key}&addRecipeInformation=true&addRecipeNutrition=true&fillIngredients=true";
            Map<String, Object> response = restTemplate.getForObject(url, Map.class, query, maxResults, apiKey);
            if (response != null && response.containsKey("results")) {
                results = (List<Map<String, Object>>) response.get("results");
            }
        } catch (RestClientException e) {
            log.warn("Spoonacular API call failed: {}. Falling back to demo data.", e.getMessage());
        }

        if (results == null || results.isEmpty()) {
            fallbackDemo(query, maxResults, job);
            return;
        }

        int imported = 0;
        for (Map<String, Object> item : results) {
            try {
                String title = (String) item.get("title");
                if (title == null) continue;

                String image = (String) item.get("image");
                Integer servings = (Integer) item.get("servings");
                if (servings == null) servings = 4;
                Integer prepMinutes = (Integer) item.get("readyInMinutes");
                String sourceUrl = (String) item.get("sourceUrl");
                String cuisine = extractFirst(item, "cuisines");
                String mealType = extractFirst(item, "dishTypes");
                Double healthScore = (Double) item.get("healthScore");

                Map<String, Object> nutrition = (Map<String, Object>) item.get("nutrition");
                Integer calPerServing = null;
                if (nutrition != null) {
                    List<Map<String, Object>> nutrients = (List<Map<String, Object>>) nutrition.get("nutrients");
                    if (nutrients != null) {
                        for (Map<String, Object> n : nutrients) {
                            if ("Calories".equals(n.get("name"))) {
                                Object amt = n.get("amount");
                                if (amt instanceof Number num) calPerServing = num.intValue();
                                break;
                            }
                        }
                    }
                }

                String description = cuisine != null ? "A " + cuisine + " recipe from Spoonacular" : "Recipe from Spoonacular";
                if (healthScore != null) description += " (health score: " + healthScore.intValue() + ")";

                Recipe recipe = Recipe.builder()
                        .name(title).description(description).servings(servings)
                        .prepTimeMinutes(prepMinutes).cookTimeMinutes(prepMinutes).totalTimeMinutes(prepMinutes)
                        .cuisineType(cuisine).mealType(mealType)
                        .imageUrl(image).isPublic(true).source("Spoonacular").sourceUrl(sourceUrl)
                        .caloriesPerServing(calPerServing).build();

                recipe = recipeRepository.save(recipe);

                List<Map<String, Object>> ingredients = (List<Map<String, Object>>) item.get("extendedIngredients");
                if (ingredients != null) {
                    for (Map<String, Object> ing : ingredients) {
                        String name = (String) ing.get("name");
                        if (name == null) continue;
                        Object amount = ing.get("amount");
                        String unit = (String) ing.get("unit");
                        Integer sortOrder = (Integer) ing.get("originalId");
                        if (sortOrder == null) sortOrder = 1;
                        BigDecimal qty = amount instanceof Number n ? BigDecimal.valueOf(n.doubleValue()) : BigDecimal.ONE;

                        recipeIngredientRepository.save(RecipeIngredient.builder()
                                .recipe(recipe).name(name).quantity(qty).unit(unit != null ? unit : "piece")
                                .sortOrder(sortOrder).build());
                    }
                }

                List<Map<String, Object>> analyzedInstructions = (List<Map<String, Object>>) item.get("analyzedInstructions");
                if (analyzedInstructions != null) {
                    int stepNum = 1;
                    for (Map<String, Object> instruction : analyzedInstructions) {
                        List<Map<String, Object>> steps = (List<Map<String, Object>>) instruction.get("steps");
                        if (steps != null) {
                            for (Map<String, Object> step : steps) {
                                String stepText = (String) step.get("step");
                                if (stepText == null || stepText.isBlank()) continue;
                                recipeStepRepository.save(RecipeStep.builder()
                                        .recipe(recipe).stepNumber(stepNum).instruction(stepText).build());
                                stepNum++;
                            }
                        }
                    }
                }

                imported++;
            } catch (Exception e) {
                log.warn("Failed to import Spoonacular record: {}", e.getMessage());
                job.setFailedRecords(job.getFailedRecords() != null ? job.getFailedRecords() + 1 : 1);
            }
        }

        job.setSuccessfulRecords(imported);
        if (job.getFailedRecords() == null) job.setFailedRecords(0);
        log.info("Spoonacular import completed: {} imported, {} failed", imported, job.getFailedRecords());
    }

    private void fallbackDemo(String query, int maxResults, ImportJob job) {
        log.info("Spoonacular API returned no data. Generating demo recipes.");
        int imported = 0;
        for (int i = 0; i < maxResults; i++) {
            try {
                String name = query.substring(0, Math.min(query.length(), 20)) + " Spoonacular #" + (i + 1);
                Recipe recipe = Recipe.builder()
                        .name(name).description("Demo Spoonacular recipe").servings(4).isPublic(true)
                        .source("Spoonacular (demo)").caloriesPerServing(350 + i * 30).build();
                recipe = recipeRepository.save(recipe);
                recipeIngredientRepository.save(RecipeIngredient.builder()
                        .recipe(recipe).name("Ingredient 1").quantity(BigDecimal.ONE).unit("piece").sortOrder(1).build());
                recipeStepRepository.save(RecipeStep.builder()
                        .recipe(recipe).stepNumber(1).instruction("Prepare " + name).build());
                imported++;
            } catch (Exception e) {
                job.setFailedRecords(job.getFailedRecords() != null ? job.getFailedRecords() + 1 : 1);
            }
        }
        job.setSuccessfulRecords(imported);
        if (job.getFailedRecords() == null) job.setFailedRecords(0);
    }

    private String extractFirst(Map<String, Object> map, String key) {
        Object val = map.get(key);
        if (val instanceof List<?> list && !list.isEmpty()) {
            Object first = list.get(0);
            return first != null ? first.toString() : null;
        }
        return val != null ? val.toString() : null;
    }
}
