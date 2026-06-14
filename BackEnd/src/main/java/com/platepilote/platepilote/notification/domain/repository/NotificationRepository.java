package com.platepilote.platepilote.notification.domain.repository;

import com.platepilote.platepilote.notification.domain.entity.Notification;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.UUID;

/**
 * Repository pour l'accès aux données des notifications.
 * <p>
 * Fournit des méthodes de requête avec pagination pour les notifications
 * actives (non supprimées) d'un utilisateur, avec filtrage par statut de lecture.
 */
public interface NotificationRepository extends JpaRepository<Notification, UUID> {

    /**
     * Récupère les notifications non supprimées d'un utilisateur avec pagination.
     *
     * @param userId   identifiant de l'utilisateur
     * @param pageable paramètres de pagination
     * @return page de notifications
     */
    Page<Notification> findByUserIdAndDeletedAtIsNull(UUID userId, Pageable pageable);

    /**
     * Récupère les notifications non supprimées d'un utilisateur filtrées par statut de lecture.
     *
     * @param userId   identifiant de l'utilisateur
     * @param read     statut de lecture
     * @param pageable paramètres de pagination
     * @return page de notifications
     */
    Page<Notification> findByUserIdAndReadAndDeletedAtIsNull(UUID userId, Boolean read, Pageable pageable);

    /**
     * Compte les notifications non supprimées d'un utilisateur par statut de lecture.
     *
     * @param userId identifiant de l'utilisateur
     * @param read   statut de lecture
     * @return nombre de notifications
     */
    long countByUserIdAndReadAndDeletedAtIsNull(UUID userId, Boolean read);
}
