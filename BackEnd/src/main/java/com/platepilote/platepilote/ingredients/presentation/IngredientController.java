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

/**
 * Contrôleur REST pour la consultation des ingrédients.
 * <p>
 * Expose les points d'accès pour rechercher, consulter et filtrer
 * les ingrédients par slug, identifiant ou catégorie.
 * </p>
 */
@RestController
@RequestMapping("/api/v1/ingredients")
@RequiredArgsConstructor
public class IngredientController {

    private final IngredientService ingredientService;

    /**
     * Recherche des ingrédients par mot-clé avec pagination.
     *
     * @param q    terme de recherche
     * @param page numéro de page (défaut : 0)
     * @param size taille de la page (défaut : 20)
     * @return réponse paginée des ingrédients trouvés
     */
    @GetMapping("/search")
    public ResponseEntity<ApiResponse<PagedResponse<IngredientResponse>>> search(
            @RequestParam String q,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        Pageable pageable = PageRequest.of(page, size, Sort.by("canonicalName").ascending());
        PagedResponse<IngredientResponse> result = ingredientService.searchIngredients(q, pageable);
        return ResponseEntity.ok(ApiResponse.success(result));
    }

    /**
     * Récupère un ingrédient par son identifiant.
     *
     * @param id identifiant de l'ingrédient
     * @return réponse détaillée de l'ingrédient
     */
    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<IngredientResponse>> getById(@PathVariable UUID id) {
        IngredientResponse ingredient = ingredientService.getById(id);
        return ResponseEntity.ok(ApiResponse.success(ingredient));
    }

    /**
     * Récupère un ingrédient par son slug.
     *
     * @param slug slug unique de l'ingrédient
     * @return réponse détaillée de l'ingrédient
     */
    @GetMapping("/slug/{slug}")
    public ResponseEntity<ApiResponse<IngredientResponse>> getBySlug(@PathVariable String slug) {
        IngredientResponse ingredient = ingredientService.getBySlug(slug);
        return ResponseEntity.ok(ApiResponse.success(ingredient));
    }

    /**
     * Récupère les ingrédients d'une catégorie donnée avec pagination.
     *
     * @param category catégorie d'ingrédients
     * @param page     numéro de page (défaut : 0)
     * @param size     taille de la page (défaut : 20)
     * @return réponse paginée des ingrédients de la catégorie
     */
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
