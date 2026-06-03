package com.platepilote.platepilote.mealplanning.presentation;

import com.platepilote.platepilote.common.dto.ApiResponse;
import com.platepilote.platepilote.common.dto.PagedResponse;
import com.platepilote.platepilote.common.security.SecurityUtils;
import com.platepilote.platepilote.mealplanning.application.dto.MealPlanEntryRequest;
import com.platepilote.platepilote.mealplanning.application.dto.MealPlanRequest;
import com.platepilote.platepilote.mealplanning.application.dto.MealPlanResponse;
import com.platepilote.platepilote.mealplanning.application.service.MealPlanService;
import com.platepilote.platepilote.mealplanning.application.service.SmartSwapService;
import com.platepilote.platepilote.mealplanning.domain.entity.MealPlanMode;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.format.annotation.DateTimeFormat;
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

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

/**
 * Contrôleur REST pour la gestion des plans de repas.
 * <p>
 * Expose les points d'accès permettant de créer, consulter, modifier et supprimer
 * des plans de repas, ainsi que de gérer les échanges de recettes.
 * </p>
 */
@RestController
@RequestMapping("/api/v1/meal-plans")
@RequiredArgsConstructor
public class MealPlanController {

    private final MealPlanService mealPlanService;
    private final SecurityUtils securityUtils;

    /**
     * Récupère la liste paginée des plans de repas de l'utilisateur connecté.
     *
     * @param userDetails informations de l'utilisateur authentifié
     * @param page        numéro de page (défaut : 0)
     * @param size        taille de la page (défaut : 20)
     * @return réponse paginée contenant les plans de repas
     */
    @GetMapping
    public ResponseEntity<ApiResponse<PagedResponse<MealPlanResponse>>> getMyMealPlans(
            @AuthenticationPrincipal UserDetails userDetails,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        UUID userId = securityUtils.getCurrentUserId(userDetails);
        Pageable pageable = PageRequest.of(page, size, Sort.by("startDate").descending());
        PagedResponse<MealPlanResponse> plans = mealPlanService.getUserMealPlans(userId, pageable);
        return ResponseEntity.ok(ApiResponse.success(plans));
    }

    /**
     * Récupère un plan de repas complet par son identifiant.
     *
     * @param userDetails informations de l'utilisateur authentifié
     * @param mealPlanId  identifiant du plan de repas
     * @return réponse complète du plan
     */
    @GetMapping("/{mealPlanId}")
    public ResponseEntity<ApiResponse<MealPlanResponse>> getMealPlan(
            @AuthenticationPrincipal UserDetails userDetails,
            @PathVariable UUID mealPlanId) {
        UUID userId = securityUtils.getCurrentUserId(userDetails);
        MealPlanResponse plan = mealPlanService.getMealPlanById(userId, mealPlanId);
        return ResponseEntity.ok(ApiResponse.success(plan));
    }

    /**
     * Génère un plan de repas hebdomadaire automatique.
     *
     * @param userDetails informations de l'utilisateur authentifié
     * @param startDate   date de début de la semaine
     * @param mode        mode de génération (STANDARD, WASTELESS, ENDOFMONTH, BUSYWEEK, FAMILY)
     * @return réponse du plan généré
     */
    @PostMapping("/generate")
    public ResponseEntity<ApiResponse<MealPlanResponse>> generateWeeklyPlan(
            @AuthenticationPrincipal UserDetails userDetails,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam(defaultValue = "STANDARD") String mode) {
        UUID userId = securityUtils.getCurrentUserId(userDetails);
        MealPlanMode mealPlanMode = MealPlanMode.valueOf(mode.toUpperCase());
        MealPlanResponse plan = mealPlanService.generateWeeklyPlan(userId, startDate, mealPlanMode);
        return ResponseEntity.ok(ApiResponse.success("Weekly plan generated", plan));
    }

    /**
     * Crée un nouveau plan de repas.
     *
     * @param userDetails informations de l'utilisateur authentifié
     * @param request     données du plan à créer
     * @return réponse du plan créé (statut 201)
     */
    @PostMapping
    public ResponseEntity<ApiResponse<MealPlanResponse>> createMealPlan(
            @AuthenticationPrincipal UserDetails userDetails,
            @Valid @RequestBody MealPlanRequest request) {
        UUID userId = securityUtils.getCurrentUserId(userDetails);
        MealPlanResponse plan = mealPlanService.createMealPlan(userId, request);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success("Meal plan created", plan));
    }

    /**
     * Ajoute une entrée (repas) à un plan de repas existant.
     *
     * @param userDetails informations de l'utilisateur authentifié
     * @param mealPlanId  identifiant du plan de repas
     * @param request     données de l'entrée à ajouter
     * @return réponse du plan mis à jour
     */
    @PostMapping("/{mealPlanId}/entries")
    public ResponseEntity<ApiResponse<MealPlanResponse>> addEntry(
            @AuthenticationPrincipal UserDetails userDetails,
            @PathVariable UUID mealPlanId,
            @Valid @RequestBody MealPlanEntryRequest request) {
        UUID userId = securityUtils.getCurrentUserId(userDetails);
        MealPlanResponse plan = mealPlanService.addEntry(userId, mealPlanId, request);
        return ResponseEntity.ok(ApiResponse.success("Entry added", plan));
    }

    /**
     * Supprime une entrée (repas) d'un plan de repas.
     *
     * @param userDetails informations de l'utilisateur authentifié
     * @param entryId     identifiant de l'entrée à supprimer
     * @return confirmation de la suppression
     */
    @DeleteMapping("/entries/{entryId}")
    public ResponseEntity<ApiResponse<Void>> removeEntry(
            @AuthenticationPrincipal UserDetails userDetails,
            @PathVariable UUID entryId) {
        UUID userId = securityUtils.getCurrentUserId(userDetails);
        mealPlanService.removeEntry(userId, entryId);
        return ResponseEntity.ok(ApiResponse.success("Entry removed", null));
    }

    /**
     * Active un plan de repas (statut ACTIVE).
     *
     * @param userDetails informations de l'utilisateur authentifié
     * @param mealPlanId  identifiant du plan à activer
     * @return confirmation de l'activation
     */
    @PostMapping("/{mealPlanId}/activate")
    public ResponseEntity<ApiResponse<Void>> activateMealPlan(
            @AuthenticationPrincipal UserDetails userDetails,
            @PathVariable UUID mealPlanId) {
        UUID userId = securityUtils.getCurrentUserId(userDetails);
        mealPlanService.activateMealPlan(userId, mealPlanId);
        return ResponseEntity.ok(ApiResponse.success("Meal plan activated", null));
    }

    /**
     * Récupère les options d'échange disponibles pour une entrée donnée.
     *
     * @param userDetails informations de l'utilisateur authentifié
     * @param entryId     identifiant de l'entrée
     * @param limit       nombre maximum d'options (défaut : 10)
     * @return liste des options d'échange
     */
    @GetMapping("/entries/{entryId}/swap-options")
    public ResponseEntity<ApiResponse<List<SmartSwapService.SwapOption>>> getSwapOptions(
            @AuthenticationPrincipal UserDetails userDetails,
            @PathVariable UUID entryId,
            @RequestParam(defaultValue = "10") int limit) {
        UUID userId = securityUtils.getCurrentUserId(userDetails);
        List<SmartSwapService.SwapOption> options = mealPlanService.getSwapOptions(userId, entryId, limit);
        return ResponseEntity.ok(ApiResponse.success(options));
    }

    /**
     * Applique un échange de recette sur une entrée.
     *
     * @param userDetails informations de l'utilisateur authentifié
     * @param entryId     identifiant de l'entrée à modifier
     * @param newRecipeId identifiant de la nouvelle recette
     * @return réponse du plan mis à jour
     */
    @PostMapping("/entries/{entryId}/swap")
    public ResponseEntity<ApiResponse<MealPlanResponse>> applySwap(
            @AuthenticationPrincipal UserDetails userDetails,
            @PathVariable UUID entryId,
            @RequestParam UUID newRecipeId) {
        UUID userId = securityUtils.getCurrentUserId(userDetails);
        MealPlanResponse plan = mealPlanService.applySwap(userId, entryId, newRecipeId);
        return ResponseEntity.ok(ApiResponse.success("Entry swapped", plan));
    }

    /**
     * Modifie le mode de fonctionnement d'un plan de repas.
     *
     * @param userDetails informations de l'utilisateur authentifié
     * @param mealPlanId  identifiant du plan
     * @param mode        nouveau mode (STANDARD, WASTELESS, ENDOFMONTH, BUSYWEEK, FAMILY)
     * @return réponse du plan mis à jour
     */
    @PutMapping("/{mealPlanId}/mode")
    public ResponseEntity<ApiResponse<MealPlanResponse>> setMode(
            @AuthenticationPrincipal UserDetails userDetails,
            @PathVariable UUID mealPlanId,
            @RequestParam String mode) {
        UUID userId = securityUtils.getCurrentUserId(userDetails);
        MealPlanMode mealPlanMode = MealPlanMode.valueOf(mode.toUpperCase());
        MealPlanResponse plan = mealPlanService.setMode(userId, mealPlanId, mealPlanMode);
        return ResponseEntity.ok(ApiResponse.success("Mode updated", plan));
    }

    /**
     * Supprime (soft-delete) un plan de repas.
     *
     * @param userDetails informations de l'utilisateur authentifié
     * @param mealPlanId  identifiant du plan à supprimer
     * @return confirmation de la suppression
     */
    @DeleteMapping("/{mealPlanId}")
    public ResponseEntity<ApiResponse<Void>> deleteMealPlan(
            @AuthenticationPrincipal UserDetails userDetails,
            @PathVariable UUID mealPlanId) {
        UUID userId = securityUtils.getCurrentUserId(userDetails);
        mealPlanService.deleteMealPlan(userId, mealPlanId);
        return ResponseEntity.ok(ApiResponse.success("Meal plan deleted", null));
    }
}
