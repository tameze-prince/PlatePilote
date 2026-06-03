package com.platepilote.platepilote.pantry.presentation;

import com.platepilote.platepilote.common.dto.ApiResponse;
import com.platepilote.platepilote.common.dto.PagedResponse;
import com.platepilote.platepilote.common.security.SecurityUtils;
import com.platepilote.platepilote.pantry.application.dto.PantryItemRequest;
import com.platepilote.platepilote.pantry.application.dto.PantryItemResponse;
import com.platepilote.platepilote.pantry.application.service.PantryService;
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
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.math.BigDecimal;
import java.util.List;
import java.util.UUID;

/**
 * Contrôleur REST exposant les endpoints de gestion du garde-manger.
 */
@RestController
@RequestMapping("/api/v1/pantry")
@RequiredArgsConstructor
public class PantryController {

    private final PantryService pantryService;

    private final SecurityUtils securityUtils;

    /**
     * Récupère tous les articles du garde-manger de l'utilisateur connecté (paginné).
     *
     * @param userDetails utilisateur authentifié
     * @param page        numéro de page (défaut 0)
     * @param size        taille de page (défaut 20)
     * @return liste paginée des articles
     */
    @GetMapping
    public ResponseEntity<ApiResponse<PagedResponse<PantryItemResponse>>> getAllItems(
            @AuthenticationPrincipal UserDetails userDetails,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        UUID userId = securityUtils.getCurrentUserId(userDetails);
        Pageable pageable = PageRequest.of(page, size, Sort.by("createdAt").descending());
        PagedResponse<PantryItemResponse> items = pantryService.getAllItems(userId, pageable);
        return ResponseEntity.ok(ApiResponse.success(items));
    }

    /**
     * Récupère les articles filtrés par catégorie.
     *
     * @param userDetails utilisateur authentifié
     * @param category    catégorie souhaitée
     * @return liste des articles de la catégorie
     */
    @GetMapping("/category/{category}")
    public ResponseEntity<ApiResponse<List<PantryItemResponse>>> getItemsByCategory(
            @AuthenticationPrincipal UserDetails userDetails,
            @PathVariable String category) {
        UUID userId = securityUtils.getCurrentUserId(userDetails);
        List<PantryItemResponse> items = pantryService.getItemsByCategory(userId, category);
        return ResponseEntity.ok(ApiResponse.success(items));
    }

    /**
     * Récupère les articles qui expirent dans un nombre de jours donné.
     *
     * @param userDetails utilisateur authentifié
     * @param days        nombre de jours (défaut 7)
     * @return liste des articles proches de la péremption
     */
    @GetMapping("/expiring")
    public ResponseEntity<ApiResponse<List<PantryItemResponse>>> getExpiringItems(
            @AuthenticationPrincipal UserDetails userDetails,
            @RequestParam(defaultValue = "7") int days) {
        UUID userId = securityUtils.getCurrentUserId(userDetails);
        List<PantryItemResponse> items = pantryService.getExpiringItems(userId, days);
        return ResponseEntity.ok(ApiResponse.success(items));
    }

    /**
     * Recherche des articles par nom.
     *
     * @param userDetails utilisateur authentifié
     * @param q           terme de recherche
     * @return liste des articles correspondants
     */
    @GetMapping("/search")
    public ResponseEntity<ApiResponse<List<PantryItemResponse>>> searchItems(
            @AuthenticationPrincipal UserDetails userDetails,
            @RequestParam String q) {
        UUID userId = securityUtils.getCurrentUserId(userDetails);
        List<PantryItemResponse> items = pantryService.searchItems(userId, q);
        return ResponseEntity.ok(ApiResponse.success(items));
    }

    /**
     * Ajoute un nouvel article dans le garde-manger.
     *
     * @param userDetails utilisateur authentifié
     * @param request     données de l'article
     * @return l'article créé (status 201)
     */
    @PostMapping
    public ResponseEntity<ApiResponse<PantryItemResponse>> addItem(
            @AuthenticationPrincipal UserDetails userDetails,
            @Valid @RequestBody PantryItemRequest request) {
        UUID userId = securityUtils.getCurrentUserId(userDetails);
        PantryItemResponse item = pantryService.addItem(userId, request);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success("Item added", item));
    }

    /**
     * Met à jour un article existant.
     *
     * @param userDetails utilisateur authentifié
     * @param itemId      identifiant de l'article
     * @param request     nouvelles données
     * @return l'article mis à jour
     */
    @PutMapping("/{itemId}")
    public ResponseEntity<ApiResponse<PantryItemResponse>> updateItem(
            @AuthenticationPrincipal UserDetails userDetails,
            @PathVariable UUID itemId,
            @Valid @RequestBody PantryItemRequest request) {
        UUID userId = securityUtils.getCurrentUserId(userDetails);
        PantryItemResponse item = pantryService.updateItem(userId, itemId, request);
        return ResponseEntity.ok(ApiResponse.success("Item updated", item));
    }

    /**
     * Supprime (soft-delete) un article du garde-manger.
     *
     * @param userDetails utilisateur authentifié
     * @param itemId      identifiant de l'article
     */
    @DeleteMapping("/{itemId}")
    public ResponseEntity<ApiResponse<Void>> removeItem(
            @AuthenticationPrincipal UserDetails userDetails,
            @PathVariable UUID itemId) {
        UUID userId = securityUtils.getCurrentUserId(userDetails);
        pantryService.removeItem(userId, itemId);
        return ResponseEntity.ok(ApiResponse.success("Item removed", null));
    }

    /**
     * Consomme une partie d'un article. Si la quantité atteint zéro, l'article est supprimé.
     *
     * @param userDetails utilisateur authentifié
     * @param itemId      identifiant de l'article
     * @param amount      quantité consommée
     */
    @PatchMapping("/{itemId}/consume")
    public ResponseEntity<ApiResponse<Void>> consumeItem(
            @AuthenticationPrincipal UserDetails userDetails,
            @PathVariable UUID itemId,
            @RequestParam BigDecimal amount) {
        UUID userId = securityUtils.getCurrentUserId(userDetails);
        pantryService.consumeItem(userId, itemId, amount);
        return ResponseEntity.ok(ApiResponse.success("Item consumed", null));
    }
}
