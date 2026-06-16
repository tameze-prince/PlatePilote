package com.platepilote.platepilote.me.presentation;

import com.platepilote.platepilote.common.security.SecurityUtils;
import com.platepilote.platepilote.me.application.dto.DataExportResponse;
import com.platepilote.platepilote.me.application.dto.DeleteAccountResponse;
import com.platepilote.platepilote.me.application.service.MeService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDate;
import java.util.UUID;

/**
 * RGPD Data Subject Rights endpoints.
 *
 * <ul>
 *   <li>GET /api/v1/me/data-export — RGPD art. 15 + 20 (access + portability)</li>
 *   <li>DELETE /api/v1/me/account — RGPD art. 17 (erasure) with 30-day grace</li>
 * </ul>
 *
 * Both require an authenticated principal. Soft-delete allows recovery
 * during the grace window; hard purge is asynchronous after 30 days.
 */
@RestController
@RequestMapping("/api/v1/me")
@PreAuthorize("isAuthenticated()")
public class MeController {

    private final MeService meService;

    public MeController(MeService meService) {
        this.meService = meService;
    }

    /**
     * Returns a JSON snapshot of all personal data held for the
     * authenticated user. The payload is suitable for direct download
     * on mobile or web clients.
     */
    @GetMapping("/data-export")
    public ResponseEntity<DataExportResponse> exportUserData() {
        UUID userId = SecurityUtils.currentUserId();
        return ResponseEntity.ok(meService.exportUserData(userId));
    }

    /**
     * Schedules a soft-delete + 30-day purge. The body contains the
     * scheduled hard-delete date so the client can communicate it to
     * the user. HTTP 202 Accepted because purge is asynchronous.
     */
    @DeleteMapping("/account")
    public ResponseEntity<DeleteAccountResponse> requestAccountDeletion() {
        UUID userId = SecurityUtils.currentUserId();
        meService.requestAccountDeletion(userId);
        LocalDate scheduled = LocalDate.now().plusDays(30);
        return ResponseEntity.accepted().body(
            new DeleteAccountResponse(
                "Account scheduled for deletion. Data will be hard-purged after the grace window.",
                scheduled.toString()
            )
        );
    }
}
