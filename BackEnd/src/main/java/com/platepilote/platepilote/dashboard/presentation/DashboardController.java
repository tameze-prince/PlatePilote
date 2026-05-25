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

@RestController
@RequestMapping("/api/v1/dashboard")
@RequiredArgsConstructor
public class DashboardController {

    private final DashboardService dashboardService;
    private final SecurityUtils securityUtils;

    @GetMapping("/home")
    public ResponseEntity<ApiResponse<DashboardResponse>> getHomeDashboard(
            @AuthenticationPrincipal UserDetails userDetails) {
        UUID userId = securityUtils.getCurrentUserId(userDetails);
        DashboardResponse dashboard = dashboardService.getHomeDashboard(userId);
        return ResponseEntity.ok(ApiResponse.success(dashboard));
    }
}
