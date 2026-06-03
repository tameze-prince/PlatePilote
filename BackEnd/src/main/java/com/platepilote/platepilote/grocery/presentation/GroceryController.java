package com.platepilote.platepilote.grocery.presentation;

import com.platepilote.platepilote.common.dto.ApiResponse;
import com.platepilote.platepilote.common.dto.PagedResponse;
import com.platepilote.platepilote.common.security.SecurityUtils;
import com.platepilote.platepilote.grocery.application.dto.GroceryItemRequest;
import com.platepilote.platepilote.grocery.application.dto.GroceryListRequest;
import com.platepilote.platepilote.grocery.application.service.GroceryService;
import com.platepilote.platepilote.grocery.application.service.GroceryService.CheckoutResponse;
import com.platepilote.platepilote.grocery.application.service.GroceryService.GroceryListResponse;
import com.platepilote.platepilote.grocery.application.service.GroceryService.PurchaseRecordResponse;
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
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;
import java.util.UUID;

/**
 * Contrôleur REST pour la gestion des listes de courses.
 * <p>
 * Expose les endpoints permettant de créer, consulter, modifier et supprimer
 * des listes de courses, ainsi que de générer une liste depuis un plan de repas
 * et d'effectuer le passage en caisse.
 * <p>
 * Tous les endpoints nécessitent une authentification.
 * Base URL : {@code /api/v1/grocery-lists}
 */
@RestController
@RequestMapping("/api/v1/grocery-lists")
@RequiredArgsConstructor
public class GroceryController {

    private final GroceryService groceryService;
    private final SecurityUtils securityUtils;

    /**
     * Récupère toutes les listes de courses de l'utilisateur connecté, de manière paginée.
     *
     * @param userDetails les informations de l'utilisateur authentifié
     * @param page        le numéro de page (défaut : 0)
     * @param size        la taille de page (défaut : 20)
     * @return une page de listes de courses triées par date de création décroissante
     */
    @GetMapping
    public ResponseEntity<ApiResponse<PagedResponse<GroceryListResponse>>> getMyLists(
            @AuthenticationPrincipal UserDetails userDetails,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        UUID userId = securityUtils.getCurrentUserId(userDetails);
        Pageable pageable = PageRequest.of(page, size, Sort.by("createdAt").descending());
        PagedResponse<GroceryListResponse> lists = groceryService.getUserLists(userId, pageable);
        return ResponseEntity.ok(ApiResponse.success(lists));
    }

    /**
     * Récupère une liste de courses spécifique avec le détail de ses articles.
     *
     * @param userDetails les informations de l'utilisateur authentifié
     * @param listId      l'identifiant de la liste
     * @return la liste de courses complète
     */
    @GetMapping("/{listId}")
    public ResponseEntity<ApiResponse<GroceryListResponse>> getList(
            @AuthenticationPrincipal UserDetails userDetails,
            @PathVariable UUID listId) {
        UUID userId = securityUtils.getCurrentUserId(userDetails);
        GroceryListResponse list = groceryService.getListById(userId, listId);
        return ResponseEntity.ok(ApiResponse.success(list));
    }

    /**
     * Génère une liste de courses à partir d'un plan de repas.
     *
     * @param userDetails les informations de l'utilisateur authentifié
     * @param mealPlanId  l'identifiant du plan de repas
     * @return la liste de courses générée (statut 201)
     */
    @PostMapping("/generate")
    public ResponseEntity<ApiResponse<GroceryListResponse>> generateFromMealPlan(
            @AuthenticationPrincipal UserDetails userDetails,
            @RequestParam UUID mealPlanId) {
        UUID userId = securityUtils.getCurrentUserId(userDetails);
        GroceryListResponse list = groceryService.generateFromMealPlan(userId, mealPlanId);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success("Grocery list generated from meal plan", list));
    }

    /**
     * Crée une nouvelle liste de courses.
     *
     * @param userDetails les informations de l'utilisateur authentifié
     * @param request     les données de la liste (nom obligatoire)
     * @return la liste créée (statut 201)
     */
    @PostMapping
    public ResponseEntity<ApiResponse<GroceryListResponse>> createList(
            @AuthenticationPrincipal UserDetails userDetails,
            @Valid @RequestBody GroceryListRequest request) {
        UUID userId = securityUtils.getCurrentUserId(userDetails);
        GroceryListResponse list = groceryService.createList(userId, request);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success("Grocery list created", list));
    }

    /**
     * Ajoute un article à une liste de courses existante.
     *
     * @param userDetails les informations de l'utilisateur authentifié
     * @param listId      l'identifiant de la liste
     * @param request     les données du nouvel article
     * @return la liste mise à jour
     */
    @PostMapping("/{listId}/items")
    public ResponseEntity<ApiResponse<GroceryListResponse>> addItem(
            @AuthenticationPrincipal UserDetails userDetails,
            @PathVariable UUID listId,
            @Valid @RequestBody GroceryItemRequest request) {
        UUID userId = securityUtils.getCurrentUserId(userDetails);
        GroceryListResponse list = groceryService.addItem(userId, listId, request);
        return ResponseEntity.ok(ApiResponse.success("Item added", list));
    }

    /**
     * Bascule l'état coché/décoché d'un article.
     *
     * @param userDetails les informations de l'utilisateur authentifié
     * @param itemId      l'identifiant de l'article
     * @return réponse vide confirmant le basculement
     */
    @PatchMapping("/items/{itemId}/toggle")
    public ResponseEntity<ApiResponse<Void>> toggleItem(
            @AuthenticationPrincipal UserDetails userDetails,
            @PathVariable UUID itemId) {
        UUID userId = securityUtils.getCurrentUserId(userDetails);
        groceryService.toggleItemChecked(userId, itemId);
        return ResponseEntity.ok(ApiResponse.success("Item toggled", null));
    }

    /**
     * Supprime un article d'une liste de courses.
     *
     * @param userDetails les informations de l'utilisateur authentifié
     * @param itemId      l'identifiant de l'article à supprimer
     * @return réponse vide confirmant la suppression
     */
    @DeleteMapping("/items/{itemId}")
    public ResponseEntity<ApiResponse<Void>> removeItem(
            @AuthenticationPrincipal UserDetails userDetails,
            @PathVariable UUID itemId) {
        UUID userId = securityUtils.getCurrentUserId(userDetails);
        groceryService.removeItem(userId, itemId);
        return ResponseEntity.ok(ApiResponse.success("Item removed", null));
    }

    /**
     * Marque une liste de courses comme terminée.
     *
     * @param userDetails les informations de l'utilisateur authentifié
     * @param listId      l'identifiant de la liste à compléter
     * @return réponse vide confirmant la complétion
     */
    @PatchMapping("/{listId}/complete")
    public ResponseEntity<ApiResponse<Void>> completeList(
            @AuthenticationPrincipal UserDetails userDetails,
            @PathVariable UUID listId) {
        UUID userId = securityUtils.getCurrentUserId(userDetails);
        groceryService.completeList(userId, listId);
        return ResponseEntity.ok(ApiResponse.success("List completed", null));
    }

    /**
     * Effectue le passage en caisse d'une liste de courses.
     * <p>
     * Les articles cochés sont enregistrés dans l'historique d'achat et ajoutés au garde-manger.
     *
     * @param userDetails les informations de l'utilisateur authentifié
     * @param listId      l'identifiant de la liste
     * @param request     la liste des articles achetés et leurs prix réels (optionnel)
     * @return le résultat complet du passage en caisse
     */
    @PostMapping("/{listId}/checkout")
    public ResponseEntity<ApiResponse<CheckoutResponse>> checkoutList(
            @AuthenticationPrincipal UserDetails userDetails,
            @PathVariable UUID listId,
            @RequestBody CheckoutRequest request) {
        UUID userId = securityUtils.getCurrentUserId(userDetails);
        CheckoutResponse result = groceryService.checkoutList(
                userId, listId, request.checkedItemIds(), request.actualPrices());
        return ResponseEntity.ok(ApiResponse.success("Checkout completed", result));
    }

    /**
     * Récupère l'historique des achats de l'utilisateur connecté, de manière paginée.
     *
     * @param userDetails les informations de l'utilisateur authentifié
     * @param page        le numéro de page (défaut : 0)
     * @param size        la taille de page (défaut : 20)
     * @return une page d'historique d'achats
     */
    @GetMapping("/history")
    public ResponseEntity<ApiResponse<PagedResponse<PurchaseRecordResponse>>> getPurchaseHistory(
            @AuthenticationPrincipal UserDetails userDetails,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        UUID userId = securityUtils.getCurrentUserId(userDetails);
        Pageable pageable = PageRequest.of(page, size, Sort.by("updatedAt").descending());
        PagedResponse<PurchaseRecordResponse> history = groceryService.getPurchaseHistory(userId, pageable);
        return ResponseEntity.ok(ApiResponse.success(history));
    }

    public record CheckoutRequest(
            List<UUID> checkedItemIds,
            Map<UUID, BigDecimal> actualPrices
    ) {}

    /**
     * Supprime logiquement une liste de courses (soft-delete).
     *
     * @param userDetails les informations de l'utilisateur authentifié
     * @param listId      l'identifiant de la liste à supprimer
     * @return réponse vide confirmant la suppression
     */
    @DeleteMapping("/{listId}")
    public ResponseEntity<ApiResponse<Void>> deleteList(
            @AuthenticationPrincipal UserDetails userDetails,
            @PathVariable UUID listId) {
        UUID userId = securityUtils.getCurrentUserId(userDetails);
        groceryService.deleteList(userId, listId);
        return ResponseEntity.ok(ApiResponse.success("List deleted", null));
    }
}
