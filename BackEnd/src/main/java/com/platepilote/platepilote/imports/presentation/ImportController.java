package com.platepilote.platepilote.imports.presentation;

import com.platepilote.platepilote.common.dto.ApiResponse;
import com.platepilote.platepilote.imports.application.service.ImportService;
import com.platepilote.platepilote.imports.domain.entity.ImportJob;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import java.util.concurrent.CompletableFuture;

@RestController
@RequestMapping("/api/v1/imports")
@RequiredArgsConstructor
public class ImportController {

    private final ImportService importService;

    @PostMapping("/usda")
    @PreAuthorize("hasAnyRole('ADMIN','SUPER_ADMIN','CONTENT_MANAGER','SYSTEM')")
    public ResponseEntity<ApiResponse<ImportJob>> importFromUsda(
            @RequestParam(defaultValue = "chicken") String query,
            @RequestParam(defaultValue = "10") int maxResults) {
        CompletableFuture<ImportJob> future = importService.importFromUsda(query, maxResults);
        ImportJob job = future.join();
        return ResponseEntity.ok(ApiResponse.success("USDA import started", job));
    }

    @PostMapping("/open-food-facts")
    @PreAuthorize("hasAnyRole('ADMIN','SUPER_ADMIN','CONTENT_MANAGER','SYSTEM')")
    public ResponseEntity<ApiResponse<ImportJob>> importFromOpenFoodFacts(
            @RequestParam(defaultValue = "rice") String query,
            @RequestParam(defaultValue = "10") int maxResults) {
        CompletableFuture<ImportJob> future = importService.importFromOpenFoodFacts(query, maxResults);
        ImportJob job = future.join();
        return ResponseEntity.ok(ApiResponse.success("Open Food Facts import started", job));
    }

    @PostMapping("/themealdb")
    @PreAuthorize("hasAnyRole('ADMIN','SUPER_ADMIN','CONTENT_MANAGER','SYSTEM')")
    public ResponseEntity<ApiResponse<ImportJob>> importFromMealDb(
            @RequestParam(defaultValue = "chicken") String query,
            @RequestParam(defaultValue = "10") int maxResults) {
        CompletableFuture<ImportJob> future = importService.importFromMealDb(query, maxResults);
        ImportJob job = future.join();
        return ResponseEntity.ok(ApiResponse.success("TheMealDB import started", job));
    }

    @PostMapping("/edamam")
    @PreAuthorize("hasAnyRole('ADMIN','SUPER_ADMIN','CONTENT_MANAGER','SYSTEM')")
    public ResponseEntity<ApiResponse<ImportJob>> importFromEdamam(
            @RequestParam(defaultValue = "pasta") String query,
            @RequestParam(defaultValue = "10") int maxResults) {
        CompletableFuture<ImportJob> future = importService.importFromEdamam(query, maxResults);
        ImportJob job = future.join();
        return ResponseEntity.ok(ApiResponse.success("Edamam import started", job));
    }

    @PostMapping("/spoonacular")
    @PreAuthorize("hasAnyRole('ADMIN','SUPER_ADMIN','CONTENT_MANAGER','SYSTEM')")
    public ResponseEntity<ApiResponse<ImportJob>> importFromSpoonacular(
            @RequestParam(defaultValue = "pasta") String query,
            @RequestParam(defaultValue = "10") int maxResults) {
        CompletableFuture<ImportJob> future = importService.importFromSpoonacular(query, maxResults);
        ImportJob job = future.join();
        return ResponseEntity.ok(ApiResponse.success("Spoonacular import started", job));
    }

    @PostMapping("/nutritionix")
    @PreAuthorize("hasAnyRole('ADMIN','SUPER_ADMIN','CONTENT_MANAGER','SYSTEM')")
    public ResponseEntity<ApiResponse<ImportJob>> importFromNutritionix(
            @RequestParam(defaultValue = "chicken") String query,
            @RequestParam(defaultValue = "10") int maxResults) {
        CompletableFuture<ImportJob> future = importService.importFromNutritionix(query, maxResults);
        ImportJob job = future.join();
        return ResponseEntity.ok(ApiResponse.success("Nutritionix import started", job));
    }

    @PostMapping("/tasty")
    @PreAuthorize("hasAnyRole('ADMIN','SUPER_ADMIN','CONTENT_MANAGER','SYSTEM')")
    public ResponseEntity<ApiResponse<ImportJob>> importFromTasty(
            @RequestParam(defaultValue = "pasta") String query,
            @RequestParam(defaultValue = "10") int maxResults) {
        CompletableFuture<ImportJob> future = importService.importFromTasty(query, maxResults);
        ImportJob job = future.join();
        return ResponseEntity.ok(ApiResponse.success("Tasty import started", job));
    }

    @PostMapping("/barcode-lookup")
    @PreAuthorize("hasAnyRole('ADMIN','SUPER_ADMIN','CONTENT_MANAGER','SYSTEM')")
    public ResponseEntity<ApiResponse<ImportJob>> importFromBarcodeLookup(
            @RequestParam(defaultValue = "rice") String query,
            @RequestParam(defaultValue = "10") int maxResults) {
        CompletableFuture<ImportJob> future = importService.importFromBarcodeLookup(query, maxResults);
        ImportJob job = future.join();
        return ResponseEntity.ok(ApiResponse.success("Barcode Lookup import started", job));
    }
}
