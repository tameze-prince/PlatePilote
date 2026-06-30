package com.platepilote.platepilote.me.presentation;

import com.platepilote.platepilote.common.security.SecurityUtils;
import com.platepilote.platepilote.me.application.dto.DataExportResponse;
import com.platepilote.platepilote.me.application.dto.DeleteAccountResponse;
import com.platepilote.platepilote.me.application.service.MeService;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.UUID;

/**
 * RGPD endpoints for Data Subject Access Rights. Maps to PRD §8.1.4 + BR-008 (§9.2):
 * <ul>
 *   <li>GET    /api/v1/me/data-export  → art. 15 (access) + art. 20 (portability)</li>
 *   <li>DELETE /api/v1/me/account      → art. 17 (erasure, 30j grace)</li>
 * </ul>
 */
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
    public ResponseEntity<DataExportResponse> exportData() {
        UUID userId = securityUtils.requireCurrentUserId();
        return ResponseEntity.ok(meService.exportUserData(userId));
    }

    @DeleteMapping("/account")
    public ResponseEntity<DeleteAccountResponse> deleteAccount() {
        UUID userId = securityUtils.requireCurrentUserId();
        return ResponseEntity.ok(meService.deleteUserAccount(userId));
    }
}
