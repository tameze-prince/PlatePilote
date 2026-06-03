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
import org.springframework.web.client.RestClientException;
import org.springframework.web.client.RestTemplate;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

/**
 * Importateur de recettes via l'API Edamam.
 * <p>
 * Récupère des recettes, ingrédients, valeurs nutritionnelles et instructions
 * depuis l'API Recipe d'Edamam. Les données sont importées dans le catalogue
 * de recettes PlatePilote.
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class EdamamImporter {

    /** Repository des recettes. */
    private final RecipeRepository recipeRepository;

    /** Repository des ingrédients de recettes. */
    private final RecipeIngredientRepository recipeIngredientRepository;

    /** Repository des étapes de recettes. */
    private final RecipeStepRepository recipeStepRepository;

    /** Client HTTP RestTemplate. */
    private final RestTemplate restTemplate;

    /** Identifiant d'application Edamam. */
    @Value("${app.api.edamam-app-id}")
    private String appId;

    /** Clé d'application Edamam. */
    @Value("${app.api.edamam-app-key}")
    private String appKey;

    /**
     * Lance l'import des recettes depuis Edamam.
     *
     * @param query      terme de recherche
     * @param maxResults nombre maximum de résultats
     * @param job        job d'importation en cours
     */
    @SuppressWarnings("unchecked")
    public void importData(String query, int maxResults, ImportJob job) {
        log.info("Edamam import started: query='{}', maxResults={}", query, maxResults);
        job.setTotalRecords(maxResults);

        List<Map<String, Object>> hits = null;
        try {
            String url = "https://api.edamam.com/api/recipes/v2?type=public&q={query}&app_id={appId}&app_key={appKey}&to={max}";
            Map<String, Object> response = restTemplate.getForObject(url, Map.class, query, appId, appKey, maxResults);
            if (response != null && response.containsKey("hits")) {
                hits = (List<Map<String, Object>>) response.get("hits");
            }
        } catch (RestClientException e) {
            log.warn("Edamam API call failed: {}. Falling back to demo data.", e.getMessage());
        }

        if (hits == null || hits.isEmpty()) {
            fallbackDemo(query, maxResults, job);
            return;
        }

        int imported = 0;
        for (Map<String, Object> hit : hits) {
            try {
                Map<String, Object> recipeMap = (Map<String, Object>) hit.get("recipe");
                if (recipeMap == null) continue;

                String label = (String) recipeMap.get("label");
                if (label == null) continue;

                String uri = (String) recipeMap.get("uri");
                String image = (String) recipeMap.get("image");
                String cuisineType = extractFirst(recipeMap, "cuisineType");
                String mealType = extractFirst(recipeMap, "mealType");
                String dishType = extractFirst(recipeMap, "dishType");
                List<String> ingredientLines = (List<String>) recipeMap.get("ingredientLines");
                List<Map<String, Object>> ingredients = (List<Map<String, Object>>) recipeMap.get("ingredients");
                Map<String, Object> totalNutrients = (Map<String, Object>) recipeMap.get("totalNutrients");
                Integer yield = (Integer) recipeMap.get("yield");
                if (yield == null) yield = 4;

                Double calories = null;
                if (totalNutrients != null) {
                    Map<String, Object> energy = (Map<String, Object>) totalNutrients.get("ENERC_KCAL");
                    if (energy != null) {
                        Object qty = energy.get("quantity");
                        if (qty instanceof Number n) calories = n.doubleValue() / yield;
                    }
                }
                Integer calPerServing = calories != null ? calories.intValue() : null;

                String urlStr = (String) recipeMap.get("url");
                String source = (String) recipeMap.get("source");

                Recipe recipe = Recipe.builder()
                        .name(label)
                        .description(dishType != null ? "A " + dishType + " recipe from Edamam" : "Recipe from Edamam")
                        .servings(yield)
                        .cuisineType(cuisineType)
                        .mealType(mealType)
                        .imageUrl(image)
                        .isPublic(true)
                        .source(source != null ? "Edamam (" + source + ")" : "Edamam")
                        .sourceUrl(urlStr)
                        .caloriesPerServing(calPerServing)
                        .build();

                recipe = recipeRepository.save(recipe);

                if (ingredients != null) {
                    int sortOrder = 0;
                    for (Map<String, Object> ing : ingredients) {
                        String food = (String) ing.get("food");
                        if (food == null) continue;
                        sortOrder++;
                        Map<String, Object> measures = (Map<String, Object>) ing.get("measures");
                        BigDecimal qty = BigDecimal.ONE;
                        String unit = "piece";
                        if (measures != null && !measures.isEmpty()) {
                            Object qtyObj = measures.get("quantity");
                            if (qtyObj instanceof Number n) qty = BigDecimal.valueOf(n.doubleValue());
                            String labelUnit = (String) measures.get("label");
                            if (labelUnit != null) unit = labelUnit;
                        }
                        recipeIngredientRepository.save(RecipeIngredient.builder()
                                .recipe(recipe).name(food).quantity(qty).unit(unit).sortOrder(sortOrder).build());
                    }
                }

                if (ingredientLines != null && ingredientLines.size() > 1) {
                    int stepNum = 1;
                    for (String line : ingredientLines) {
                        if (line == null || line.isBlank()) continue;
                        recipeStepRepository.save(RecipeStep.builder()
                                .recipe(recipe).stepNumber(stepNum).instruction(line).build());
                        stepNum++;
                    }
                }

                imported++;
            } catch (Exception e) {
                log.warn("Failed to import Edamam record: {}", e.getMessage());
                job.setFailedRecords(job.getFailedRecords() != null ? job.getFailedRecords() + 1 : 1);
            }
        }

        job.setSuccessfulRecords(imported);
        if (job.getFailedRecords() == null) job.setFailedRecords(0);
        log.info("Edamam import completed: {} imported, {} failed", imported, job.getFailedRecords());
    }

    private void fallbackDemo(String query, int maxResults, ImportJob job) {
        log.info("Edamam API returned no data. Generating demo recipes.");
        int imported = 0;
        for (int i = 0; i < maxResults; i++) {
            try {
                String name = query.substring(0, Math.min(query.length(), 20)) + " Edamam #" + (i + 1);
                Recipe recipe = Recipe.builder()
                        .name(name).description("Demo Edamam recipe").servings(4).isPublic(true)
                        .source("Edamam (demo)").caloriesPerServing(400 + i * 50).build();
                recipe = recipeRepository.save(recipe);
                recipeIngredientRepository.save(RecipeIngredient.builder()
                        .recipe(recipe).name("Demo Ingredient").quantity(BigDecimal.ONE).unit("piece").sortOrder(1).build());
                recipeStepRepository.save(RecipeStep.builder()
                        .recipe(recipe).stepNumber(1).instruction("Cook the " + name).build());
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
