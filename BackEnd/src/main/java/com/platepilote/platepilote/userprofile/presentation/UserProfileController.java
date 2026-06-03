package com.platepilote.platepilote.userprofile.presentation;

import com.platepilote.platepilote.common.dto.ApiResponse;
import com.platepilote.platepilote.common.security.SecurityUtils;
import com.platepilote.platepilote.userprofile.application.dto.UserProfileRequest;
import com.platepilote.platepilote.userprofile.application.dto.UserProfileResponse;
import com.platepilote.platepilote.userprofile.application.service.UserProfileService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.UUID;

/**
 * Contrôleur REST pour la gestion du profil utilisateur.
 * <p>
 * Permet de consulter, modifier et supprimer le profil de l'utilisateur connecté.
 * Tous les endpoints sont authentifiés.
 */
@RestController
@RequestMapping("/api/v1/profile")
@RequiredArgsConstructor
public class UserProfileController {

    /** Service de gestion des profils. */
    private final UserProfileService userProfileService;

    /** Utilitaires de sécurité. */
    private final SecurityUtils securityUtils;

    /**
     * Récupère le profil de l'utilisateur connecté.
     *
     * @param userDetails détails de l'utilisateur authentifié
     * @return profil utilisateur
     */
    @GetMapping
    public ResponseEntity<ApiResponse<UserProfileResponse>> getProfile(
            @AuthenticationPrincipal UserDetails userDetails) {
        UUID userId = extractUserId(userDetails);
        UserProfileResponse profile = userProfileService.getProfileByUserId(userId);
        return ResponseEntity.ok(ApiResponse.success(profile));
    }

    /**
     * Crée ou met à jour le profil de l'utilisateur connecté.
     *
     * @param userDetails détails de l'utilisateur authentifié
     * @param request     données du profil à enregistrer
     * @return profil créé ou mis à jour
     */
    @PutMapping
    public ResponseEntity<ApiResponse<UserProfileResponse>> updateProfile(
            @AuthenticationPrincipal UserDetails userDetails,
            @Valid @RequestBody UserProfileRequest request) {
        UUID userId = extractUserId(userDetails);
        UserProfileResponse profile = userProfileService.createOrUpdateProfile(userId, request);
        return ResponseEntity.ok(ApiResponse.success("Profile updated", profile));
    }

    /**
     * Supprime (soft-delete) le profil de l'utilisateur connecté.
     *
     * @param userDetails détails de l'utilisateur authentifié
     * @return confirmation de la suppression (statut 204 No Content)
     */
    @DeleteMapping
    public ResponseEntity<ApiResponse<Void>> deleteProfile(
            @AuthenticationPrincipal UserDetails userDetails) {
        UUID userId = extractUserId(userDetails);
        userProfileService.deleteProfile(userId);
        return ResponseEntity.status(HttpStatus.NO_CONTENT)
                .body(ApiResponse.success("Profile deleted", null));
    }

    private UUID extractUserId(UserDetails userDetails) {
        return securityUtils.getCurrentUserId(userDetails);
    }
}
