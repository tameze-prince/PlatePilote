package com.platepilote.platepilote.notification.presentation;

import com.platepilote.platepilote.common.security.SecurityUtils;
import com.platepilote.platepilote.notification.domain.entity.DeviceRegistration;
import com.platepilote.platepilote.notification.domain.repository.DeviceRegistrationRepository;
import org.junit.jupiter.api.Test;
import org.springframework.security.core.userdetails.User;

import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

class DeviceControllerTest {

    @Test
    void unregisterDoesNotDeactivateAnotherUsersDevice() {
        DeviceRegistrationRepository repository = mock(DeviceRegistrationRepository.class);
        SecurityUtils securityUtils = mock(SecurityUtils.class);
        DeviceController controller = new DeviceController(repository, securityUtils);

        UUID currentUserId = UUID.randomUUID();
        DeviceRegistration device = DeviceRegistration.builder()
                .id(UUID.randomUUID())
                .userId(UUID.randomUUID())
                .deviceToken("fcm-token")
                .platform("android")
                .isActive(true)
                .build();

        when(securityUtils.getCurrentUserId(org.mockito.ArgumentMatchers.any()))
                .thenReturn(currentUserId);
        when(repository.findByDeviceToken("fcm-token")).thenReturn(Optional.of(device));

        var response = controller.unregisterDevice(
                User.withUsername("current@example.com").password("x").roles("USER").build(),
                new DeviceController.RegisterDeviceRequest("fcm-token", "android")
        );

        assertThat(response.getStatusCode().is2xxSuccessful()).isTrue();
        assertThat(device.getIsActive()).isTrue();
        verify(repository, never()).save(device);
    }

    @Test
    void unregisterDeactivatesTheCurrentUsersDevice() {
        DeviceRegistrationRepository repository = mock(DeviceRegistrationRepository.class);
        SecurityUtils securityUtils = mock(SecurityUtils.class);
        DeviceController controller = new DeviceController(repository, securityUtils);

        UUID currentUserId = UUID.randomUUID();
        DeviceRegistration device = DeviceRegistration.builder()
                .id(UUID.randomUUID())
                .userId(currentUserId)
                .deviceToken("fcm-token")
                .platform("android")
                .isActive(true)
                .build();

        when(securityUtils.getCurrentUserId(org.mockito.ArgumentMatchers.any()))
                .thenReturn(currentUserId);
        when(repository.findByDeviceToken("fcm-token")).thenReturn(Optional.of(device));

        controller.unregisterDevice(
                User.withUsername("current@example.com").password("x").roles("USER").build(),
                new DeviceController.RegisterDeviceRequest("fcm-token", "android")
        );

        assertThat(device.getIsActive()).isFalse();
        verify(repository).save(device);
    }
}
