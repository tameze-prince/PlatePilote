package com.platepilote.platepilote.dashboard.presentation;

import com.platepilote.platepilote.common.dto.ApiResponse;
import com.platepilote.platepilote.common.security.SecurityUtils;
import com.platepilote.platepilote.dashboard.application.service.DashboardService;
import com.platepilote.platepilote.dashboard.application.service.DashboardService.DashboardResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.UUID;

/**
 * Contrôleur REST pour le tableau de bord.
 * <p>
 * Expose l'endpoint principal de la page d'accueil qui agrège
 * les données clés de l'utilisateur.
 */
@RestController
@RequestMapping("/api/v1/dashboard")
@RequiredArgsConstructor
public class DashboardController {

    /** Service de construction du tableau de bord. */
    private final DashboardService dashboardService;

    /** Utilitaires de sécurité. */
    private final SecurityUtils securityUtils;

    /**
     * Récupère le tableau de bord d'accueil de l'utilisateur connecté.
     *
     * @param userDetails détails de l'utilisateur authentifié
     * @return tableau de bord complet
     */
    @GetMapping("/home")
    public ResponseEntity<ApiResponse<DashboardResponse>> getHomeDashboard(
            @AuthenticationPrincipal UserDetails userDetails) {
        UUID userId = securityUtils.getCurrentUserId(userDetails);
        DashboardResponse dashboard = dashboardService.getHomeDashboard(userId);
        return ResponseEntity.ok(ApiResponse.success(dashboard));
    }
}
