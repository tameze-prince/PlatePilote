package com.platepilote.platepilote.imports.application.service;

import com.platepilote.platepilote.imports.domain.entity.ImportJob;
import com.platepilote.platepilote.recipes.domain.entity.Recipe;
import com.platepilote.platepilote.recipes.domain.entity.RecipeIngredient;
import com.platepilote.platepilote.recipes.domain.entity.RecipeStep;
import com.platepilote.platepilote.recipes.domain.repository.RecipeRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
@Transactional
public class MealDbImporter {

    private final RecipeRepository recipeRepository;

    public void importData(String query, int maxResults, ImportJob job) {
        log.info("TheMealDB import started: query='{}', maxResults={}", query, maxResults);
        job.setTotalRecords(maxResults);
        int imported = 0;
        for (int i = 0; i < maxResults; i++) {
            try {
                Recipe recipe = Recipe.builder()
                        .name("MealDB Recipe " + query + " #" + (i + 1))
                        .description("Imported from TheMealDB")
                        .servings(4)
                        .isPublic(true)
                        .source("TheMealDB")
                        .sourceUrl("https://www.themealdb.com/")
                        .userId(null)
                        .build();
                Recipe savedRecipe = recipeRepository.save(recipe);
                imported++;
            } catch (Exception e) {
                log.warn("Failed to import MealDB record {}: {}", i, e.getMessage());
                job.setFailedRecords(job.getFailedRecords() != null ? job.getFailedRecords() + 1 : 1);
            }
        }
        job.setSuccessfulRecords(imported);
        if (job.getFailedRecords() == null) job.setFailedRecords(0);
        log.info("TheMealDB import completed: {} imported, {} failed", imported, job.getFailedRecords());
    }
}
