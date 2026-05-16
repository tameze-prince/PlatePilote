package com.platepilote.platepilote.notification.domain.repository;

import com.platepilote.platepilote.notification.domain.entity.Notification;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.UUID;

@Repository
public interface NotificationRepository extends JpaRepository<Notification, UUID> {

    Page<Notification> findByUserIdAndDeletedAtIsNull(UUID userId, Pageable pageable);

    Page<Notification> findByUserIdAndReadAndDeletedAtIsNull(UUID userId, Boolean read, Pageable pageable);

    long countByUserIdAndReadAndDeletedAtIsNull(UUID userId, Boolean read);
}
