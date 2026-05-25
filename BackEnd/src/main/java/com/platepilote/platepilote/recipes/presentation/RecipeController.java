package com.platepilote.platepilote.recipes.presentation;

import com.platepilote.platepilote.common.dto.ApiResponse;
import com.platepilote.platepilote.common.dto.PagedResponse;
import com.platepilote.platepilote.common.security.SecurityUtils;
import com.platepilote.platepilote.recipes.application.dto.RecipeRequest;
import com.platepilote.platepilote.recipes.application.dto.RecipeResponse;
import com.platepilote.platepilote.recipes.application.service.RecipeService;
import com.platepilote.platepilote.recipes.domain.entity.Recipe;
import com.platepilote.platepilote.recipes.domain.entity.RecipeFavorite;
import com.platepilote.platepilote.recipes.domain.repository.RecipeFavoriteRepository;
import com.platepilote.platepilote.recipes.domain.repository.RecipeRepository;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
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

import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.UUID;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/v1/recipes")
@RequiredArgsConstructor
public class RecipeController {

    private final RecipeService recipeService;
    private final SecurityUtils securityUtils;
    private final RecipeFavoriteRepository recipeFavoriteRepository;
    private final RecipeRepository recipeRepository;

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
        UUID userId = securityUtils.getCurrentUserId(userDetails);
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
        UUID userId = securityUtils.getCurrentUserId(userDetails);
        RecipeResponse recipe = recipeService.createRecipe(userId, request);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success("Recipe created", recipe));
    }

    @PutMapping("/{recipeId}")
    public ResponseEntity<ApiResponse<RecipeResponse>> updateRecipe(
            @AuthenticationPrincipal UserDetails userDetails,
            @PathVariable UUID recipeId,
            @Valid @RequestBody RecipeRequest request) {
        UUID userId = securityUtils.getCurrentUserId(userDetails);
        RecipeResponse recipe = recipeService.updateRecipe(userId, recipeId, request);
        return ResponseEntity.ok(ApiResponse.success("Recipe updated", recipe));
    }

    @DeleteMapping("/{recipeId}")
    public ResponseEntity<ApiResponse<Void>> deleteRecipe(
            @AuthenticationPrincipal UserDetails userDetails,
            @PathVariable UUID recipeId) {
        UUID userId = securityUtils.getCurrentUserId(userDetails);
        recipeService.deleteRecipe(userId, recipeId);
        return ResponseEntity.ok(ApiResponse.success("Recipe deleted", null));
    }

    @PostMapping("/{recipeId}/favorite")
    public ResponseEntity<ApiResponse<Void>> favoriteRecipe(
            @AuthenticationPrincipal UserDetails userDetails,
            @PathVariable UUID recipeId) {
        UUID userId = securityUtils.getCurrentUserId(userDetails);
        if (!recipeFavoriteRepository.existsByRecipeIdAndUserId(recipeId, userId)) {
            RecipeFavorite favorite = RecipeFavorite.builder()
                    .recipeId(recipeId)
                    .userId(userId)
                    .build();
            recipeFavoriteRepository.save(favorite);
        }
        return ResponseEntity.ok(ApiResponse.success("Recipe favorited", null));
    }

    @DeleteMapping("/{recipeId}/favorite")
    public ResponseEntity<ApiResponse<Void>> unfavoriteRecipe(
            @AuthenticationPrincipal UserDetails userDetails,
            @PathVariable UUID recipeId) {
        UUID userId = securityUtils.getCurrentUserId(userDetails);
        recipeFavoriteRepository.deleteByRecipeIdAndUserId(recipeId, userId);
        return ResponseEntity.ok(ApiResponse.success("Recipe unfavorited", null));
    }

    @GetMapping("/favorites")
    public ResponseEntity<ApiResponse<PagedResponse<RecipeResponse>>> getFavoriteRecipes(
            @AuthenticationPrincipal UserDetails userDetails,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        UUID userId = securityUtils.getCurrentUserId(userDetails);
        Pageable pageable = PageRequest.of(page, size);
        Page<RecipeFavorite> favorites = recipeFavoriteRepository.findByUserIdOrderByCreatedAtDesc(userId, pageable);

        List<UUID> recipeIds = favorites.getContent().stream()
                .map(RecipeFavorite::getRecipeId)
                .toList();

        List<Recipe> recipes = recipeRepository.findByIds(recipeIds);
        Map<UUID, Recipe> recipeMap = recipes.stream()
                .collect(Collectors.toMap(Recipe::getId, r -> r));

        List<RecipeResponse> content = favorites.getContent().stream()
                .map(fav -> recipeMap.get(fav.getRecipeId()))
                .filter(Objects::nonNull)
                .map(this::toSummaryResponse)
                .toList();

        PagedResponse<RecipeResponse> paged = PagedResponse.of(
                content, favorites.getNumber(), favorites.getSize(), favorites.getTotalElements());
        return ResponseEntity.ok(ApiResponse.success(paged));
    }

    private RecipeResponse toSummaryResponse(Recipe recipe) {
        return RecipeResponse.builder()
                .id(recipe.getId())
                .name(recipe.getName())
                .description(recipe.getDescription())
                .prepTimeMinutes(recipe.getPrepTimeMinutes())
                .cookTimeMinutes(recipe.getCookTimeMinutes())
                .totalTimeMinutes(recipe.getTotalTimeMinutes())
                .servings(recipe.getServings())
                .difficulty(recipe.getDifficulty())
                .cuisineType(recipe.getCuisineType())
                .mealType(recipe.getMealType())
                .imageUrl(recipe.getImageUrl())
                .isPublic(recipe.getIsPublic())
                .createdAt(recipe.getCreatedAt())
                .updatedAt(recipe.getUpdatedAt())
                .build();
    }
}
