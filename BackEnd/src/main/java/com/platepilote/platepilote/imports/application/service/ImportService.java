package com.platepilote.platepilote.imports.application.service;

import com.platepilote.platepilote.imports.domain.entity.ImportJob;
import com.platepilote.platepilote.imports.domain.repository.ImportJobRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Async;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import java.time.Instant;
import java.util.concurrent.CompletableFuture;

/**
 * Service central d'importation de données depuis des sources externes.
 * <p>
 * Orchestre l'ensemble des importateurs (USDA, OpenFoodFacts, TheMealDB, Edamam,
 * Spoonacular, Nutritionix, Tasty, BarcodeLookup, Chomp, RecipeAPI) et gère
 * le cycle de vie des jobs d'importation (création, complétion, échec).
 * Un job d'import programmé est exécuté quotidiennement à 2h00 du matin.
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class ImportService {

    /** Repository des jobs d'importation. */
    private final ImportJobRepository importJobRepository;
    private final UsdaImporter usdaImporter;
    private final OpenFoodFactsImporter openFoodFactsImporter;
    private final MealDbImporter mealDbImporter;
    private final EdamamImporter edamamImporter;
    private final SpoonacularImporter spoonacularImporter;
    private final NutritionixImporter nutritionixImporter;
    private final TastyImporter tastyImporter;
    private final BarcodeLookupImporter barcodeLookupImporter;
    private final ChompImporter chompImporter;
    private final RecipeAPIImporter recipeAPIImporter;

    /**
     * Importe des données depuis USDA FoodData Central de manière asynchrone.
     *
     * @param query      terme de recherche
     * @param maxResults nombre maximum de résultats
     * @return future contenant le job d'importation complété
     */
    @Async
    public CompletableFuture<ImportJob> importFromUsda(String query, int maxResults) {
        ImportJob job = createJob("USDA_FOOD_DATA_CENTRAL");
        try {
            usdaImporter.importData(query, maxResults, job);
            markCompleted(job);
        } catch (Exception e) {
            markFailed(job, e.getMessage());
        }
        return CompletableFuture.completedFuture(job);
    }

    /**
     * Importe des données depuis Open Food Facts de manière asynchrone.
     *
     * @param query      terme de recherche
     * @param maxResults nombre maximum de résultats
     * @return future contenant le job d'importation complété
     */
    @Async
    public CompletableFuture<ImportJob> importFromOpenFoodFacts(String query, int maxResults) {
        ImportJob job = createJob("OPEN_FOOD_FACTS");
        try {
            openFoodFactsImporter.importData(query, maxResults, job);
            markCompleted(job);
        } catch (Exception e) {
            markFailed(job, e.getMessage());
        }
        return CompletableFuture.completedFuture(job);
    }

    /**
     * Importe des recettes depuis TheMealDB de manière asynchrone.
     *
     * @param query      terme de recherche
     * @param maxResults nombre maximum de résultats
     * @return future contenant le job d'importation complété
     */
    @Async
    public CompletableFuture<ImportJob> importFromMealDb(String query, int maxResults) {
        ImportJob job = createJob("THE_MEAL_DB");
        try {
            mealDbImporter.importData(query, maxResults, job);
            markCompleted(job);
        } catch (Exception e) {
            markFailed(job, e.getMessage());
        }
        return CompletableFuture.completedFuture(job);
    }

    /**
     * Importe des recettes depuis Edamam de manière asynchrone.
     *
     * @param query      terme de recherche
     * @param maxResults nombre maximum de résultats
     * @return future contenant le job d'importation complété
     */
    @Async
    public CompletableFuture<ImportJob> importFromEdamam(String query, int maxResults) {
        ImportJob job = createJob("EDAMAM");
        try { edamamImporter.importData(query, maxResults, job); markCompleted(job);
        } catch (Exception e) { markFailed(job, e.getMessage()); }
        return CompletableFuture.completedFuture(job);
    }

    /**
     * Importe des recettes depuis Spoonacular de manière asynchrone.
     *
     * @param query      terme de recherche
     * @param maxResults nombre maximum de résultats
     * @return future contenant le job d'importation complété
     */
    @Async
    public CompletableFuture<ImportJob> importFromSpoonacular(String query, int maxResults) {
        ImportJob job = createJob("SPOONACULAR");
        try { spoonacularImporter.importData(query, maxResults, job); markCompleted(job);
        } catch (Exception e) { markFailed(job, e.getMessage()); }
        return CompletableFuture.completedFuture(job);
    }

    /**
     * Importe des ingrédients depuis Nutritionix de manière asynchrone.
     *
     * @param query      terme de recherche
     * @param maxResults nombre maximum de résultats
     * @return future contenant le job d'importation complété
     */
    @Async
    public CompletableFuture<ImportJob> importFromNutritionix(String query, int maxResults) {
        ImportJob job = createJob("NUTRITIONIX");
        try { nutritionixImporter.importData(query, maxResults, job); markCompleted(job);
        } catch (Exception e) { markFailed(job, e.getMessage()); }
        return CompletableFuture.completedFuture(job);
    }

    /**
     * Importe des recettes depuis Tasty de manière asynchrone.
     *
     * @param query      terme de recherche
     * @param maxResults nombre maximum de résultats
     * @return future contenant le job d'importation complété
     */
    @Async
    public CompletableFuture<ImportJob> importFromTasty(String query, int maxResults) {
        ImportJob job = createJob("TASTY");
        try { tastyImporter.importData(query, maxResults, job); markCompleted(job);
        } catch (Exception e) { markFailed(job, e.getMessage()); }
        return CompletableFuture.completedFuture(job);
    }

    /**
     * Importe des produits depuis BarcodeLookup de manière asynchrone.
     *
     * @param query      terme de recherche
     * @param maxResults nombre maximum de résultats
     * @return future contenant le job d'importation complété
     */
    @Async
    public CompletableFuture<ImportJob> importFromBarcodeLookup(String query, int maxResults) {
        ImportJob job = createJob("BARCODE_LOOKUP");
        try { barcodeLookupImporter.importData(query, maxResults, job); markCompleted(job);
        } catch (Exception e) { markFailed(job, e.getMessage()); }
        return CompletableFuture.completedFuture(job);
    }

    /**
     * Importe des produits depuis Chomp de manière asynchrone.
     *
     * @param query      terme de recherche
     * @param maxResults nombre maximum de résultats
     * @return future contenant le job d'importation complété
     */
    @Async
    public CompletableFuture<ImportJob> importFromChomp(String query, int maxResults) {
        ImportJob job = createJob("CHOMP");
        try { chompImporter.importData(query, maxResults, job); markCompleted(job);
        } catch (Exception e) { markFailed(job, e.getMessage()); }
        return CompletableFuture.completedFuture(job);
    }

    /**
     * Importe des recettes depuis RecipeAPI de manière asynchrone.
     *
     * @param query      terme de recherche
     * @param maxResults nombre maximum de résultats
     * @return future contenant le job d'importation complété
     */
    @Async
    public CompletableFuture<ImportJob> importFromRecipeAPI(String query, int maxResults) {
        ImportJob job = createJob("RECIPE_API");
        try { recipeAPIImporter.importData(query, maxResults, job); markCompleted(job);
        } catch (Exception e) { markFailed(job, e.getMessage()); }
        return CompletableFuture.completedFuture(job);
    }

    /**
     * Importation programmée quotidienne à 2h00 du matin.
     * <p>
     * Lance l'import depuis toutes les sources disponibles avec des requêtes
     * et limites prédéfinies pour maintenir le catalogue à jour.
     */
    @Scheduled(cron = "0 0 2 * * ?")
    public void scheduledNightlyImport() {
        log.info("Starting scheduled nightly import");
        importFromUsda("chicken,rice,beans,tomato,onion", 20);
        importFromOpenFoodFacts("rice,pasta,sauce,oil", 20);
        importFromMealDb("chicken,beef,pasta,curry,salad", 10);
        importFromEdamam("pasta,chicken,salad,soup,curry", 10);
        importFromSpoonacular("pasta,chicken,rice,beef,salad", 10);
        importFromNutritionix("chicken,rice,beans,oil,cheese", 15);
        importFromTasty("pasta,chicken,salad,dessert,soup", 10);
        importFromBarcodeLookup("rice,pasta,sauce,oil,cereal", 10);
        importFromChomp("rice,pasta,sauce,oil,cereal", 10);
        importFromRecipeAPI("pasta,chicken,rice,beef,salad", 10);
    }

    private ImportJob createJob(String source) {
        ImportJob job = ImportJob.builder()
                .source(source)
                .status("RUNNING")
                .startedAt(Instant.now())
                .build();
        return importJobRepository.save(job);
    }

    private void markCompleted(ImportJob job) {
        job.setStatus("COMPLETED");
        job.setCompletedAt(Instant.now());
        importJobRepository.save(job);
    }

    private void markFailed(ImportJob job, String error) {
        job.setStatus("FAILED");
        job.setErrorMessage(error);
        job.setCompletedAt(Instant.now());
        importJobRepository.save(job);
    }
}
