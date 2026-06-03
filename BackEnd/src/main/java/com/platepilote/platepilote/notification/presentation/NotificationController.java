package com.platepilote.platepilote.notification.presentation;

import com.platepilote.platepilote.common.dto.ApiResponse;
import com.platepilote.platepilote.common.dto.PagedResponse;
import com.platepilote.platepilote.common.security.SecurityUtils;
import com.platepilote.platepilote.notification.application.service.NotificationService;
import com.platepilote.platepilote.notification.application.service.NotificationService.NotificationResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.UUID;

/**
 * Contrôleur REST pour la gestion des notifications utilisateur.
 * <p>
 * Expose les endpoints de consultation, marquage de lecture et suppression
 * des notifications. Tous les endpoints sont authentifiés et vérifient
 * la propriété des ressources.
 */
@RestController
@RequestMapping("/api/v1/notifications")
@RequiredArgsConstructor
public class NotificationController {

    /** Service de gestion des notifications. */
    private final NotificationService notificationService;

    /** Utilitaires de sécurité. */
    private final SecurityUtils securityUtils;

    /**
     * Récupère la liste paginée des notifications de l'utilisateur connecté.
     *
     * @param userDetails détails de l'utilisateur authentifié
     * @param page        numéro de page (défaut: 0)
     * @param size        taille de page (défaut: 20)
     * @return page de notifications triées par date de création décroissante
     */
    @GetMapping
    public ResponseEntity<ApiResponse<PagedResponse<NotificationResponse>>> getNotifications(
            @AuthenticationPrincipal UserDetails userDetails,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        UUID userId = securityUtils.getCurrentUserId(userDetails);
        Pageable pageable = PageRequest.of(page, size, Sort.by("createdAt").descending());
        PagedResponse<NotificationResponse> notifications = notificationService.getNotifications(userId, pageable);
        return ResponseEntity.ok(ApiResponse.success(notifications));
    }

    /**
     * Récupère la liste paginée des notifications non lues de l'utilisateur.
     *
     * @param userDetails détails de l'utilisateur authentifié
     * @param page        numéro de page (défaut: 0)
     * @param size        taille de page (défaut: 20)
     * @return page de notifications non lues
     */
    @GetMapping("/unread")
    public ResponseEntity<ApiResponse<PagedResponse<NotificationResponse>>> getUnreadNotifications(
            @AuthenticationPrincipal UserDetails userDetails,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        UUID userId = securityUtils.getCurrentUserId(userDetails);
        Pageable pageable = PageRequest.of(page, size, Sort.by("createdAt").descending());
        PagedResponse<NotificationResponse> notifications = notificationService.getUnreadNotifications(userId, pageable);
        return ResponseEntity.ok(ApiResponse.success(notifications));
    }

    /**
     * Retourne le nombre de notifications non lues de l'utilisateur.
     *
     * @param userDetails détails de l'utilisateur authentifié
     * @return nombre de notifications non lues
     */
    @GetMapping("/unread/count")
    public ResponseEntity<ApiResponse<Long>> getUnreadCount(
            @AuthenticationPrincipal UserDetails userDetails) {
        UUID userId = securityUtils.getCurrentUserId(userDetails);
        long count = notificationService.getUnreadCount(userId);
        return ResponseEntity.ok(ApiResponse.success(count));
    }

    /**
     * Marque une notification spécifique comme lue.
     *
     * @param userDetails    détails de l'utilisateur authentifié
     * @param notificationId identifiant de la notification
     * @return confirmation du marquage
     */
    @PatchMapping("/{notificationId}/read")
    public ResponseEntity<ApiResponse<Void>> markAsRead(
            @AuthenticationPrincipal UserDetails userDetails,
            @PathVariable UUID notificationId) {
        UUID userId = securityUtils.getCurrentUserId(userDetails);
        notificationService.markAsRead(userId, notificationId);
        return ResponseEntity.ok(ApiResponse.success("Notification marked as read", null));
    }

    /**
     * Marque toutes les notifications de l'utilisateur comme lues.
     *
     * @param userDetails détails de l'utilisateur authentifié
     * @return confirmation du marquage
     */
    @PatchMapping("/read-all")
    public ResponseEntity<ApiResponse<Void>> markAllAsRead(
            @AuthenticationPrincipal UserDetails userDetails) {
        UUID userId = securityUtils.getCurrentUserId(userDetails);
        notificationService.markAllAsRead(userId);
        return ResponseEntity.ok(ApiResponse.success("All notifications marked as read", null));
    }

    /**
     * Supprime (soft-delete) une notification.
     *
     * @param userDetails    détails de l'utilisateur authentifié
     * @param notificationId identifiant de la notification
     * @return confirmation de la suppression
     */
    @DeleteMapping("/{notificationId}")
    public ResponseEntity<ApiResponse<Void>> deleteNotification(
            @AuthenticationPrincipal UserDetails userDetails,
            @PathVariable UUID notificationId) {
        UUID userId = securityUtils.getCurrentUserId(userDetails);
        notificationService.deleteNotification(userId, notificationId);
        return ResponseEntity.ok(ApiResponse.success("Notification deleted", null));
    }
}
