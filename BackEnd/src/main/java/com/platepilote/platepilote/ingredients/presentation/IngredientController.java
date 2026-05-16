package com.platepilote.platepilote.ingredients.presentation;

import com.platepilote.platepilote.common.dto.ApiResponse;
import com.platepilote.platepilote.common.dto.PagedResponse;
import com.platepilote.platepilote.ingredients.application.dto.IngredientResponse;
import com.platepilote.platepilote.ingredients.application.service.IngredientService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.UUID;

@RestController
@RequestMapping("/api/v1/ingredients")
@RequiredArgsConstructor
public class IngredientController {

    private final IngredientService ingredientService;

    @GetMapping("/search")
    public ResponseEntity<ApiResponse<PagedResponse<IngredientResponse>>> search(
            @RequestParam String q,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        Pageable pageable = PageRequest.of(page, size, Sort.by("canonicalName").ascending());
        PagedResponse<IngredientResponse> result = ingredientService.searchIngredients(q, pageable);
        return ResponseEntity.ok(ApiResponse.success(result));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<IngredientResponse>> getById(@PathVariable UUID id) {
        IngredientResponse ingredient = ingredientService.getById(id);
        return ResponseEntity.ok(ApiResponse.success(ingredient));
    }

    @GetMapping("/slug/{slug}")
    public ResponseEntity<ApiResponse<IngredientResponse>> getBySlug(@PathVariable String slug) {
        IngredientResponse ingredient = ingredientService.getBySlug(slug);
        return ResponseEntity.ok(ApiResponse.success(ingredient));
    }

    @GetMapping("/category/{category}")
    public ResponseEntity<ApiResponse<PagedResponse<IngredientResponse>>> getByCategory(
            @PathVariable String category,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        Pageable pageable = PageRequest.of(page, size, Sort.by("canonicalName").ascending());
        PagedResponse<IngredientResponse> result = ingredientService.getByCategory(category, pageable);
        return ResponseEntity.ok(ApiResponse.success(result));
    }
}
