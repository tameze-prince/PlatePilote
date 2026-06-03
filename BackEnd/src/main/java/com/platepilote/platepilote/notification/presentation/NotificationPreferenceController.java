package com.platepilote.platepilote.notification.presentation;

import com.platepilote.platepilote.common.dto.ApiResponse;
import com.platepilote.platepilote.common.security.SecurityUtils;
import com.platepilote.platepilote.notification.application.service.NotificationPreferenceService;
import com.platepilote.platepilote.notification.application.service.NotificationPreferenceService.NotificationPreferenceResponse;
import com.platepilote.platepilote.notification.application.service.NotificationPreferenceService.UpdatePreferencesRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.UUID;

/**
 * Contrôleur REST pour la gestion des préférences de notification.
 * <p>
 * Permet de consulter et modifier les préférences de notification
 * de l'utilisateur connecté.
 */
@RestController
@RequestMapping("/api/v1/notification-preferences")
@RequiredArgsConstructor
public class NotificationPreferenceController {

    /** Service de gestion des préférences. */
    private final NotificationPreferenceService preferenceService;

    /** Utilitaires de sécurité. */
    private final SecurityUtils securityUtils;

    /**
     * Récupère les préférences de notification de l'utilisateur connecté.
     *
     * @param userDetails détails de l'utilisateur authentifié
     * @return préférences de notification
     */
    @GetMapping
    public ResponseEntity<ApiResponse<NotificationPreferenceResponse>> getPreferences(
            @AuthenticationPrincipal UserDetails userDetails) {
        UUID userId = securityUtils.getCurrentUserId(userDetails);
        return ResponseEntity.ok(ApiResponse.success(preferenceService.getPreferences(userId)));
    }

    /**
     * Met à jour les préférences de notification de l'utilisateur connecté.
     *
     * @param userDetails détails de l'utilisateur authentifié
     * @param request     préférences à mettre à jour
     * @return préférences mises à jour
     */
    @PutMapping
    public ResponseEntity<ApiResponse<NotificationPreferenceResponse>> updatePreferences(
            @AuthenticationPrincipal UserDetails userDetails,
            @RequestBody UpdatePreferencesRequest request) {
        UUID userId = securityUtils.getCurrentUserId(userDetails);
        return ResponseEntity.ok(ApiResponse.success("Preferences updated",
                preferenceService.updatePreferences(userId, request)));
    }
}
