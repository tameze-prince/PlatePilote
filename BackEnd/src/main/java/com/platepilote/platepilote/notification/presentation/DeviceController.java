package com.platepilote.platepilote.notification.presentation;

import com.platepilote.platepilote.common.dto.ApiResponse;
import com.platepilote.platepilote.common.security.SecurityUtils;
import com.platepilote.platepilote.notification.domain.entity.DeviceRegistration;
import com.platepilote.platepilote.notification.domain.repository.DeviceRegistrationRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.Instant;
import java.util.UUID;

/**
 * Contrôleur REST pour l'enregistrement des appareils mobiles.
 * <p>
 * Permet aux utilisateurs d'enregistrer leurs appareils pour recevoir
 * des notifications push. Les anciens tokens sont désactivés lors
 * d'une réinscription.
 */
@RestController
@RequestMapping("/api/v1/devices")
@RequiredArgsConstructor
public class DeviceController {

    /** Repository des enregistrements d'appareils. */
    private final DeviceRegistrationRepository deviceRepository;

    /** Utilitaires de sécurité. */
    private final SecurityUtils securityUtils;

    /**
     * Enregistre un nouvel appareil pour les notifications push.
     * <p>
     * Si le token existe déjà, l'ancien enregistrement est désactivé
     * avant la création du nouveau.
     *
     * @param userDetails détails de l'utilisateur authentifié
     * @param request     corps de la requête (deviceToken, platform)
     * @return confirmation de l'enregistrement
     */
    @PostMapping
    public ResponseEntity<ApiResponse<Void>> registerDevice(
            @AuthenticationPrincipal UserDetails userDetails,
            @RequestBody RegisterDeviceRequest request) {
        UUID userId = securityUtils.getCurrentUserId(userDetails);

        // Deactivate old token if exists
        deviceRepository.findByDeviceToken(request.deviceToken())
                .ifPresent(device -> {
                    device.setIsActive(false);
                    deviceRepository.save(device);
                });

        DeviceRegistration device = DeviceRegistration.builder()
                .userId(userId)
                .deviceToken(request.deviceToken())
                .platform(request.platform())
                .isActive(true)
                .createdAt(Instant.now())
                .updatedAt(Instant.now())
                .build();
        deviceRepository.save(device);

        return ResponseEntity.ok(ApiResponse.success("Device registered", null));
    }

    /**
     * Requête d'enregistrement d'appareil.
     *
     * @param deviceToken token FCM/APNS de l'appareil
     * @param platform    plateforme (android, ios, web)
     */
    public record RegisterDeviceRequest(
            String deviceToken,
            String platform
    ) {}
}
