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

/**
 * Service de gestion des notifications utilisateur.
 * <p>
 * Permet de consulter, marquer comme lues et supprimer les notifications.
 * Gère le cycle de vie complet des notifications avec pagination et
 * vérification de propriété.
 */
@Service
@RequiredArgsConstructor
@Transactional
public class NotificationService {

    /** Repository des notifications. */
    private final NotificationRepository notificationRepository;

    /** Utilitaires de sécurité pour la vérification de propriété. */
    private final SecurityUtils securityUtils;

    /**
     * Récupère les notifications paginées d'un utilisateur.
     *
     * @param userId   identifiant de l'utilisateur
     * @param pageable paramètres de pagination
     * @return page de notifications
     */
    @Transactional(readOnly = true)
    public PagedResponse<NotificationResponse> getNotifications(UUID userId, Pageable pageable) {
        Page<Notification> page = notificationRepository.findByUserIdAndDeletedAtIsNull(userId, pageable);
        return toPagedResponse(page);
    }

    /**
     * Récupère les notifications non lues paginées d'un utilisateur.
     *
     * @param userId   identifiant de l'utilisateur
     * @param pageable paramètres de pagination
     * @return page de notifications non lues
     */
    @Transactional(readOnly = true)
    public PagedResponse<NotificationResponse> getUnreadNotifications(UUID userId, Pageable pageable) {
        Page<Notification> page = notificationRepository.findByUserIdAndReadAndDeletedAtIsNull(userId, false, pageable);
        return toPagedResponse(page);
    }

    /**
     * Compte le nombre de notifications non lues d'un utilisateur.
     *
     * @param userId identifiant de l'utilisateur
     * @return nombre de notifications non lues
     */
    @Transactional(readOnly = true)
    public long getUnreadCount(UUID userId) {
        return notificationRepository.countByUserIdAndReadAndDeletedAtIsNull(userId, false);
    }

    /**
     * Marque une notification comme lue.
     *
     * @param userId         identifiant de l'utilisateur propriétaire
     * @param notificationId identifiant de la notification
     * @throws com.platepilote.platepilote.common.kernel.ResourceNotFoundException si la notification n'existe pas
     */
    public void markAsRead(UUID userId, UUID notificationId) {
        Notification notification = notificationRepository.findById(notificationId)
                .orElseThrow(() -> new ResourceNotFoundException("Notification", "id", notificationId.toString()));

        securityUtils.verifyOwnership(notification.getUserId(), userId, "Notification", notificationId.toString());

        notification.setRead(true);
        notification.setReadAt(Instant.now());
        notificationRepository.save(notification);
    }

    /**
     * Marque toutes les notifications non lues d'un utilisateur comme lues.
     *
     * @param userId identifiant de l'utilisateur
     */
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

    /**
     * Supprime (soft-delete) une notification.
     *
     * @param userId         identifiant de l'utilisateur propriétaire
     * @param notificationId identifiant de la notification
     * @throws com.platepilote.platepilote.common.kernel.ResourceNotFoundException si la notification n'existe pas
     */
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

    /**
     * DTO de réponse représentant une notification.
     *
     * @param id        identifiant de la notification
     * @param type      type de notification (ex: PANTRY_ALERT, MEAL_PLAN_REMINDER)
     * @param title     titre de la notification
     * @param body      corps du message
     * @param data      données JSON additionnelles
     * @param read      indicateur de lecture
     * @param readAt    date de lecture
     * @param createdAt date de création
     */
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
