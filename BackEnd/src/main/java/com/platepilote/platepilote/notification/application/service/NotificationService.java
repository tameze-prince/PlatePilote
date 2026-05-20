package com.platepilote.platepilote.notification.application.service;

import com.platepilote.platepilote.common.dto.PagedResponse;
import com.platepilote.platepilote.common.kernel.ResourceNotFoundException;
import com.platepilote.platepilote.common.security.SecurityUtils;
import com.platepilote.platepilote.notification.domain.entity.Notification;
import com.platepilote.platepilote.notification.domain.repository.NotificationRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional
public class NotificationService {

    private final NotificationRepository notificationRepository;
    private final SecurityUtils securityUtils;

    @Transactional(readOnly = true)
    public PagedResponse<NotificationResponse> getNotifications(UUID userId, Pageable pageable) {
        Page<Notification> page = notificationRepository.findByUserIdAndDeletedAtIsNull(userId, pageable);
        return toPagedResponse(page);
    }

    @Transactional(readOnly = true)
    public PagedResponse<NotificationResponse> getUnreadNotifications(UUID userId, Pageable pageable) {
        Page<Notification> page = notificationRepository.findByUserIdAndReadAndDeletedAtIsNull(userId, false, pageable);
        return toPagedResponse(page);
    }

    @Transactional(readOnly = true)
    public long getUnreadCount(UUID userId) {
        return notificationRepository.countByUserIdAndReadAndDeletedAtIsNull(userId, false);
    }

    public void markAsRead(UUID userId, UUID notificationId) {
        Notification notification = notificationRepository.findById(notificationId)
                .orElseThrow(() -> new ResourceNotFoundException("Notification", "id", notificationId.toString()));

        securityUtils.verifyOwnership(notification.getUserId(), userId, "Notification", notificationId.toString());

        notification.setRead(true);
        notification.setReadAt(Instant.now());
        notificationRepository.save(notification);
    }

    public void markAllAsRead(UUID userId) {
        List<Notification> unread = notificationRepository
                .findByUserIdAndReadAndDeletedAtIsNull(userId, false, Pageable.unpaged())
                .getContent();

        unread.forEach(n -> {
            n.setRead(true);
            n.setReadAt(Instant.now());
        });

        notificationRepository.saveAll(unread);
    }

    public void deleteNotification(UUID userId, UUID notificationId) {
        Notification notification = notificationRepository.findById(notificationId)
                .orElseThrow(() -> new ResourceNotFoundException("Notification", "id", notificationId.toString()));

        securityUtils.verifyOwnership(notification.getUserId(), userId, "Notification", notificationId.toString());

        notification.softDelete();
        notificationRepository.save(notification);
    }

    private PagedResponse<NotificationResponse> toPagedResponse(Page<Notification> page) {
        List<NotificationResponse> content = page.getContent()
                .stream()
                .map(this::toResponse)
                .collect(Collectors.toList());

        return PagedResponse.of(content, page.getNumber(), page.getSize(), page.getTotalElements());
    }

    private NotificationResponse toResponse(Notification notification) {
        return new NotificationResponse(
                notification.getId(),
                notification.getType(),
                notification.getTitle(),
                notification.getBody(),
                notification.getData(),
                notification.getRead(),
                notification.getReadAt(),
                notification.getCreatedAt()
        );
    }

    public record NotificationResponse(
            UUID id,
            String type,
            String title,
            String body,
            String data,
            Boolean read,
            Instant readAt,
            Instant createdAt
    ) {}
}
