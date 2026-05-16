package com.platepilote.platepilote.imports.presentation;

import com.platepilote.platepilote.common.dto.ApiResponse;
import com.platepilote.platepilote.imports.application.service.ImportService;
import com.platepilote.platepilote.imports.domain.entity.ImportJob;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/imports")
@RequiredArgsConstructor
public class ImportController {

    private final ImportService importService;

    @PostMapping("/usda")
    public ResponseEntity<ApiResponse<ImportJob>> importFromUsda(
            @RequestParam(defaultValue = "chicken") String query,
            @RequestParam(defaultValue = "10") int maxResults) {
        ImportJob job = importService.importFromUsda(query, maxResults);
        return ResponseEntity.ok(ApiResponse.success("USDA import started", job));
    }

    @PostMapping("/open-food-facts")
    public ResponseEntity<ApiResponse<ImportJob>> importFromOpenFoodFacts(
            @RequestParam(defaultValue = "rice") String query,
            @RequestParam(defaultValue = "10") int maxResults) {
        ImportJob job = importService.importFromOpenFoodFacts(query, maxResults);
        return ResponseEntity.ok(ApiResponse.success("Open Food Facts import started", job));
    }

    @PostMapping("/themealdb")
    public ResponseEntity<ApiResponse<ImportJob>> importFromMealDb(
            @RequestParam(defaultValue = "chicken") String query,
            @RequestParam(defaultValue = "10") int maxResults) {
        ImportJob job = importService.importFromMealDb(query, maxResults);
        return ResponseEntity.ok(ApiResponse.success("TheMealDB import started", job));
    }
}
