package com.platepilote.platepilote.notification.domain.repository;

import com.platepilote.platepilote.notification.domain.entity.NotificationPreference;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface NotificationPreferenceRepository extends JpaRepository<NotificationPreference, UUID> {
    Optional<NotificationPreference> findByUserId(UUID userId);
    boolean existsByUserId(UUID userId);
}
