package com.platepilote.platepilote.notification.domain.repository;

import com.platepilote.platepilote.notification.domain.entity.DeviceRegistration;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface DeviceRegistrationRepository extends JpaRepository<DeviceRegistration, UUID> {
    Optional<DeviceRegistration> findByDeviceToken(String deviceToken);
    long countByUserIdAndIsActiveTrue(UUID userId);
}
