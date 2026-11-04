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
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
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
            @Valid @RequestBody RegisterDeviceRequest request) {
        UUID userId = securityUtils.getCurrentUserId(userDetails);

        Instant now = Instant.now();
        DeviceRegistration device = deviceRepository.findByDeviceToken(request.deviceToken())
                .orElseGet(DeviceRegistration::new);

        // Reassign an existing physical device when the user switches accounts.
        device.setUserId(userId);
        device.setDeviceToken(request.deviceToken());
        device.setPlatform(request.platform());
        device.setIsActive(true);
        if (device.getCreatedAt() == null) {
            device.setCreatedAt(now);
        }
        device.setUpdatedAt(now);
        deviceRepository.save(device);

        return ResponseEntity.ok(ApiResponse.success("Device registered", null));
    }

    /**
     * Désactive le token push de l'utilisateur courant après retrait du consentement.
     * L'opération est idempotente et ne peut pas désactiver le token d'un autre compte.
     */
    @PostMapping("/unregister")
    public ResponseEntity<ApiResponse<Void>> unregisterDevice(
            @AuthenticationPrincipal UserDetails userDetails,
            @Valid @RequestBody RegisterDeviceRequest request) {
        UUID userId = securityUtils.getCurrentUserId(userDetails);
        deviceRepository.findByDeviceToken(request.deviceToken())
                .filter(device -> userId.equals(device.getUserId()))
                .ifPresent(device -> {
                    device.setIsActive(false);
                    device.setUpdatedAt(Instant.now());
                    deviceRepository.save(device);
                });
        return ResponseEntity.ok(ApiResponse.success("Device unregistered", null));
    }

    /**
     * Requête d'enregistrement d'appareil.
     *
     * @param deviceToken token FCM/APNS de l'appareil
     * @param platform    plateforme (android, ios, web)
     */
    public record RegisterDeviceRequest(
            @NotBlank String deviceToken,
            @NotBlank @Pattern(regexp = "android|ios|web") String platform
    ) {}
}
