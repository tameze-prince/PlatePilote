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
}
