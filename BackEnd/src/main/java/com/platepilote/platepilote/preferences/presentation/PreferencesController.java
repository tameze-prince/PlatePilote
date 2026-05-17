package com.platepilote.platepilote.preferences.presentation;

import com.platepilote.platepilote.common.dto.ApiResponse;
import com.platepilote.platepilote.common.security.SecurityUtils;
import com.platepilote.platepilote.preferences.application.dto.AllergyRequest;
import com.platepilote.platepilote.preferences.application.dto.DietaryPreferenceRequest;
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
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/preferences")
@RequiredArgsConstructor
public class PreferencesController {

    private final PreferencesService preferencesService;

    private final SecurityUtils securityUtils;

    // ==================== DIETARY PREFERENCES ====================

    @GetMapping("/diets")
    public ResponseEntity<ApiResponse<List<String>>> getDietaryPreferences(
            @AuthenticationPrincipal UserDetails userDetails) {
        UUID userId = securityUtils.getCurrentUserId(userDetails);
        List<String> diets = preferencesService.getDietaryPreferences(userId);
        return ResponseEntity.ok(ApiResponse.success(diets));
    }

    @PostMapping("/diets")
    public ResponseEntity<ApiResponse<Void>> addDietaryPreference(
            @AuthenticationPrincipal UserDetails userDetails,
            @Valid @RequestBody DietaryPreferenceRequest request) {
        UUID userId = securityUtils.getCurrentUserId(userDetails);
        preferencesService.addDietaryPreference(userId, request);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success("Dietary preference added", null));
    }

    @DeleteMapping("/diets/{dietType}")
    public ResponseEntity<ApiResponse<Void>> removeDietaryPreference(
            @AuthenticationPrincipal UserDetails userDetails,
            @PathVariable String dietType) {
        UUID userId = securityUtils.getCurrentUserId(userDetails);
        preferencesService.removeDietaryPreference(userId, dietType);
        return ResponseEntity.ok(ApiResponse.success("Dietary preference removed", null));
    }

    // ==================== ALLERGIES ====================

    @GetMapping("/allergies")
    public ResponseEntity<ApiResponse<List<Allergy>>> getAllergies(
            @AuthenticationPrincipal UserDetails userDetails) {
        UUID userId = securityUtils.getCurrentUserId(userDetails);
        List<Allergy> allergies = preferencesService.getAllergies(userId);
        return ResponseEntity.ok(ApiResponse.success(allergies));
    }

    @PostMapping("/allergies")
    public ResponseEntity<ApiResponse<Void>> addAllergy(
            @AuthenticationPrincipal UserDetails userDetails,
            @Valid @RequestBody AllergyRequest request) {
        UUID userId = securityUtils.getCurrentUserId(userDetails);
        preferencesService.addAllergy(userId, request);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success("Allergy added", null));
    }

    @DeleteMapping("/allergies/{allergen}")
    public ResponseEntity<ApiResponse<Void>> removeAllergy(
            @AuthenticationPrincipal UserDetails userDetails,
            @PathVariable String allergen) {
        UUID userId = securityUtils.getCurrentUserId(userDetails);
        preferencesService.removeAllergy(userId, allergen);
        return ResponseEntity.ok(ApiResponse.success("Allergy removed", null));
    }
}
