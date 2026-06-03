package com.platepilote.platepilote.preferences.presentation;

import com.platepilote.platepilote.common.dto.ApiResponse;
import com.platepilote.platepilote.common.security.SecurityUtils;
import com.platepilote.platepilote.preferences.application.dto.AllergyRequest;
import com.platepilote.platepilote.preferences.application.dto.CuisinePreferenceRequest;
import com.platepilote.platepilote.preferences.application.dto.DietaryPreferenceRequest;
import com.platepilote.platepilote.preferences.application.dto.UserPreferencesRequest;
import com.platepilote.platepilote.preferences.application.dto.UserPreferencesResponse;
import com.platepilote.platepilote.preferences.application.service.PreferencesService;
import com.platepilote.platepilote.preferences.domain.entity.Allergy;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
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
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.UUID;

/**
 * Contrôleur REST exposant les endpoints de gestion des préférences utilisateur.
 */
@RestController
@RequestMapping("/api/v1/preferences")
@RequiredArgsConstructor
public class PreferencesController {

    private final PreferencesService preferencesService;

    private final SecurityUtils securityUtils;

    // ==================== RÉGIMES ALIMENTAIRES ====================

    /**
     * Récupère la liste des régimes alimentaires de l'utilisateur connecté.
     *
     * @param userDetails utilisateur authentifié
     * @return liste des types de régime
     */
    @GetMapping("/diets")
    public ResponseEntity<ApiResponse<List<String>>> getDietaryPreferences(
            @AuthenticationPrincipal UserDetails userDetails) {
        UUID userId = securityUtils.getCurrentUserId(userDetails);
        List<String> diets = preferencesService.getDietaryPreferences(userId);
        return ResponseEntity.ok(ApiResponse.success(diets));
    }

    /**
     * Ajoute un régime alimentaire pour l'utilisateur connecté.
     *
     * @param userDetails utilisateur authentifié
     * @param request     données du régime
     * @return confirmation (status 201)
     */
    @PostMapping("/diets")
    public ResponseEntity<ApiResponse<Void>> addDietaryPreference(
            @AuthenticationPrincipal UserDetails userDetails,
            @Valid @RequestBody DietaryPreferenceRequest request) {
        UUID userId = securityUtils.getCurrentUserId(userDetails);
        preferencesService.addDietaryPreference(userId, request);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success("Dietary preference added", null));
    }

    /**
     * Supprime un régime alimentaire.
     *
     * @param userDetails utilisateur authentifié
     * @param dietType    type de régime à supprimer
     * @return confirmation
     */
    @DeleteMapping("/diets/{dietType}")
    public ResponseEntity<ApiResponse<Void>> removeDietaryPreference(
            @AuthenticationPrincipal UserDetails userDetails,
            @PathVariable String dietType) {
        UUID userId = securityUtils.getCurrentUserId(userDetails);
        preferencesService.removeDietaryPreference(userId, dietType);
        return ResponseEntity.ok(ApiResponse.success("Dietary preference removed", null));
    }

    // ==================== ALLERGIES ====================

    /**
     * Récupère la liste des allergies de l'utilisateur connecté.
     *
     * @param userDetails utilisateur authentifié
     * @return liste des allergies
     */
    @GetMapping("/allergies")
    public ResponseEntity<ApiResponse<List<Allergy>>> getAllergies(
            @AuthenticationPrincipal UserDetails userDetails) {
        UUID userId = securityUtils.getCurrentUserId(userDetails);
        List<Allergy> allergies = preferencesService.getAllergies(userId);
        return ResponseEntity.ok(ApiResponse.success(allergies));
    }

    /**
     * Ajoute une allergie pour l'utilisateur connecté.
     *
     * @param userDetails utilisateur authentifié
     * @param request     données de l'allergie
     * @return confirmation (status 201)
     */
    @PostMapping("/allergies")
    public ResponseEntity<ApiResponse<Void>> addAllergy(
            @AuthenticationPrincipal UserDetails userDetails,
            @Valid @RequestBody AllergyRequest request) {
        UUID userId = securityUtils.getCurrentUserId(userDetails);
        preferencesService.addAllergy(userId, request);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success("Allergy added", null));
    }

    /**
     * Supprime une allergie.
     *
     * @param userDetails utilisateur authentifié
     * @param allergen    nom de l'allergène à supprimer
     * @return confirmation
     */
    @DeleteMapping("/allergies/{allergen}")
    public ResponseEntity<ApiResponse<Void>> removeAllergy(
            @AuthenticationPrincipal UserDetails userDetails,
            @PathVariable String allergen) {
        UUID userId = securityUtils.getCurrentUserId(userDetails);
        preferencesService.removeAllergy(userId, allergen);
        return ResponseEntity.ok(ApiResponse.success("Allergy removed", null));
    }

    // ==================== PRÉFÉRENCES CULINAIRES ====================

    /**
     * Récupère la liste des cuisines préférées de l'utilisateur connecté.
     *
     * @param userDetails utilisateur authentifié
     * @return liste des types de cuisine
     */
    @GetMapping("/cuisines")
    public ResponseEntity<ApiResponse<List<String>>> getCuisinePreferences(
            @AuthenticationPrincipal UserDetails userDetails) {
        UUID userId = securityUtils.getCurrentUserId(userDetails);
        List<String> cuisines = preferencesService.getCuisinePreferences(userId);
        return ResponseEntity.ok(ApiResponse.success(cuisines));
    }

    /**
     * Ajoute une préférence culinaire pour l'utilisateur connecté.
     *
     * @param userDetails utilisateur authentifié
     * @param request     données de la cuisine
     * @return confirmation (status 201)
     */
    @PostMapping("/cuisines")
    public ResponseEntity<ApiResponse<Void>> addCuisinePreference(
            @AuthenticationPrincipal UserDetails userDetails,
            @Valid @RequestBody CuisinePreferenceRequest request) {
        UUID userId = securityUtils.getCurrentUserId(userDetails);
        preferencesService.addCuisinePreference(userId, request);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success("Cuisine preference added", null));
    }

    /**
     * Supprime une préférence culinaire.
     *
     * @param userDetails utilisateur authentifié
     * @param cuisineType type de cuisine à supprimer
     * @return confirmation
     */
    @DeleteMapping("/cuisines/{cuisineType}")
    public ResponseEntity<ApiResponse<Void>> removeCuisinePreference(
            @AuthenticationPrincipal UserDetails userDetails,
            @PathVariable String cuisineType) {
        UUID userId = securityUtils.getCurrentUserId(userDetails);
        preferencesService.removeCuisinePreference(userId, cuisineType);
        return ResponseEntity.ok(ApiResponse.success("Cuisine preference removed", null));
    }

    // ==================== PRÉFÉRENCES GROUPÉES ====================

    /**
     * Récupère toutes les préférences de l'utilisateur connecté.
     *
     * @param userDetails utilisateur authentifié
     * @return toutes les préférences groupées
     */
    @GetMapping("/me")
    public ResponseEntity<ApiResponse<UserPreferencesResponse>> getMyPreferences(
            @AuthenticationPrincipal UserDetails userDetails) {
        UUID userId = securityUtils.getCurrentUserId(userDetails);
        UserPreferencesResponse preferences = preferencesService.getAllPreferences(userId);
        return ResponseEntity.ok(ApiResponse.success(preferences));
    }

    /**
     * Remplace toutes les préférences de l'utilisateur connecté.
     *
     * @param userDetails utilisateur authentifié
     * @param request     nouvelles préférences
     * @return préférences mises à jour
     */
    @PutMapping("/me")
    public ResponseEntity<ApiResponse<UserPreferencesResponse>> updateMyPreferences(
            @AuthenticationPrincipal UserDetails userDetails,
            @Valid @RequestBody UserPreferencesRequest request) {
        UUID userId = securityUtils.getCurrentUserId(userDetails);
        preferencesService.updateAllPreferences(userId, request);
        UserPreferencesResponse updated = preferencesService.getAllPreferences(userId);
        return ResponseEntity.ok(ApiResponse.success("Preferences updated", updated));
    }
}
