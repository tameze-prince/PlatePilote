package com.platepilote.platepilote.me.presentation;

import com.platepilote.platepilote.common.dto.ApiResponse;
import com.platepilote.platepilote.common.security.SecurityUtils;
import com.platepilote.platepilote.me.application.dto.DataExportResponse;
import com.platepilote.platepilote.me.application.dto.DeleteAccountResponse;
import com.platepilote.platepilote.me.application.dto.RightsActionResponse;
import com.platepilote.platepilote.me.application.service.MeService;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.UUID;

@RestController
@RequestMapping(path = "/api/v1/me", produces = MediaType.APPLICATION_JSON_VALUE)
@PreAuthorize("isAuthenticated()")
public class MeController {
    private final MeService meService;
    private final SecurityUtils securityUtils;

    public MeController(MeService meService, SecurityUtils securityUtils) {
        this.meService = meService;
        this.securityUtils = securityUtils;
    }

    @GetMapping("/data-export")
    public ResponseEntity<ApiResponse<DataExportResponse>> exportData(
            @AuthenticationPrincipal UserDetails userDetails) {
        UUID userId = securityUtils.getCurrentUserId(userDetails);
        return ResponseEntity.ok(ApiResponse.success(meService.exportUserData(userId)));
    }

    @DeleteMapping("/account")
    public ResponseEntity<ApiResponse<DeleteAccountResponse>> deleteAccount(
            @AuthenticationPrincipal UserDetails userDetails) {
        UUID userId = securityUtils.getCurrentUserId(userDetails);
        return ResponseEntity.ok(ApiResponse.success("Account deletion scheduled", meService.deleteUserAccount(userId)));
    }

    @PostMapping("/restrict-processing")
    public ResponseEntity<ApiResponse<RightsActionResponse>> restrictProcessing(
            @AuthenticationPrincipal UserDetails userDetails) {
        UUID userId = securityUtils.getCurrentUserId(userDetails);
        return ResponseEntity.ok(ApiResponse.success(meService.restrictProcessing(userId)));
    }

    @PostMapping("/opt-out-analytics")
    public ResponseEntity<ApiResponse<RightsActionResponse>> optOutAnalytics(
            @AuthenticationPrincipal UserDetails userDetails) {
        UUID userId = securityUtils.getCurrentUserId(userDetails);
        return ResponseEntity.ok(ApiResponse.success(meService.optOutAnalytics(userId)));
    }
}
