package com.platepilote.platepilote.recipes.presentation;

import com.platepilote.platepilote.common.dto.ApiResponse;
import com.platepilote.platepilote.common.dto.PagedResponse;
import com.platepilote.platepilote.recipes.application.dto.RecipeRequest;
import com.platepilote.platepilote.recipes.application.dto.RecipeResponse;
import com.platepilote.platepilote.recipes.application.service.RecipeService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.UUID;

@RestController
@RequestMapping("/api/v1/recipes")
@RequiredArgsConstructor
public class RecipeController {

    private final RecipeService recipeService;

    @GetMapping("/public")
    public ResponseEntity<ApiResponse<PagedResponse<RecipeResponse>>> getPublicRecipes(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        Pageable pageable = PageRequest.of(page, size, Sort.by("createdAt").descending());
        PagedResponse<RecipeResponse> recipes = recipeService.getPublicRecipes(pageable);
        return ResponseEntity.ok(ApiResponse.success(recipes));
    }

    @GetMapping("/public/search")
    public ResponseEntity<ApiResponse<PagedResponse<RecipeResponse>>> searchRecipes(
            @RequestParam String q,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        Pageable pageable = PageRequest.of(page, size, Sort.by("createdAt").descending());
        PagedResponse<RecipeResponse> recipes = recipeService.searchRecipes(q, pageable);
        return ResponseEntity.ok(ApiResponse.success(recipes));
    }

    @GetMapping("/public/cuisine/{cuisineType}")
    public ResponseEntity<ApiResponse<PagedResponse<RecipeResponse>>> getByCuisine(
            @PathVariable String cuisineType,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        Pageable pageable = PageRequest.of(page, size, Sort.by("createdAt").descending());
        PagedResponse<RecipeResponse> recipes = recipeService.getByCuisineType(cuisineType, pageable);
        return ResponseEntity.ok(ApiResponse.success(recipes));
    }

    @GetMapping("/public/meal/{mealType}")
    public ResponseEntity<ApiResponse<PagedResponse<RecipeResponse>>> getByMealType(
            @PathVariable String mealType,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        Pageable pageable = PageRequest.of(page, size, Sort.by("createdAt").descending());
        PagedResponse<RecipeResponse> recipes = recipeService.getByMealType(mealType, pageable);
        return ResponseEntity.ok(ApiResponse.success(recipes));
    }

    @GetMapping("/public/{recipeId}")
    public ResponseEntity<ApiResponse<RecipeResponse>> getPublicRecipe(@PathVariable UUID recipeId) {
        RecipeResponse recipe = recipeService.getRecipeById(recipeId);
        return ResponseEntity.ok(ApiResponse.success(recipe));
    }

    @GetMapping("/my")
    public ResponseEntity<ApiResponse<PagedResponse<RecipeResponse>>> getMyRecipes(
            @AuthenticationPrincipal UserDetails userDetails,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        UUID userId = UUID.fromString(userDetails.getUsername());
        Pageable pageable = PageRequest.of(page, size, Sort.by("createdAt").descending());
        PagedResponse<RecipeResponse> recipes = recipeService.getUserRecipes(userId, pageable);
        return ResponseEntity.ok(ApiResponse.success(recipes));
    }

    @GetMapping("/my/{recipeId}")
    public ResponseEntity<ApiResponse<RecipeResponse>> getMyRecipe(
            @AuthenticationPrincipal UserDetails userDetails,
            @PathVariable UUID recipeId) {
        RecipeResponse recipe = recipeService.getRecipeById(recipeId);
        return ResponseEntity.ok(ApiResponse.success(recipe));
    }

    @PostMapping
    public ResponseEntity<ApiResponse<RecipeResponse>> createRecipe(
            @AuthenticationPrincipal UserDetails userDetails,
            @Valid @RequestBody RecipeRequest request) {
        UUID userId = UUID.fromString(userDetails.getUsername());
        RecipeResponse recipe = recipeService.createRecipe(userId, request);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success("Recipe created", recipe));
    }

    @PutMapping("/{recipeId}")
    public ResponseEntity<ApiResponse<RecipeResponse>> updateRecipe(
            @AuthenticationPrincipal UserDetails userDetails,
            @PathVariable UUID recipeId,
            @Valid @RequestBody RecipeRequest request) {
        UUID userId = UUID.fromString(userDetails.getUsername());
        RecipeResponse recipe = recipeService.updateRecipe(userId, recipeId, request);
        return ResponseEntity.ok(ApiResponse.success("Recipe updated", recipe));
    }

    @DeleteMapping("/{recipeId}")
    public ResponseEntity<ApiResponse<Void>> deleteRecipe(
            @AuthenticationPrincipal UserDetails userDetails,
            @PathVariable UUID recipeId) {
        UUID userId = UUID.fromString(userDetails.getUsername());
        recipeService.deleteRecipe(userId, recipeId);
        return ResponseEntity.ok(ApiResponse.success("Recipe deleted", null));
    }
}
