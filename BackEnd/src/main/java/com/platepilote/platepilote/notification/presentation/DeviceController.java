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

@RestController
@RequestMapping("/api/v1/devices")
@RequiredArgsConstructor
public class DeviceController {

    private final DeviceRegistrationRepository deviceRepository;
    private final SecurityUtils securityUtils;

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

    public record RegisterDeviceRequest(
            String deviceToken,
            String platform
    ) {}
}
