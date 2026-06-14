package com.platepilote.platepilote.notification.domain.repository;

import com.platepilote.platepilote.notification.domain.entity.NotificationPreference;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;
import java.util.UUID;

/**
 * Repository pour l'accès aux préférences de notification.
 */
public interface NotificationPreferenceRepository extends JpaRepository<NotificationPreference, UUID> {

    /**
     * Récupère les préférences de notification d'un utilisateur.
     *
     * @param userId identifiant de l'utilisateur
     * @return préférences trouvées ou vide
     */
    Optional<NotificationPreference> findByUserId(UUID userId);

    /**
     * Vérifie si des préférences existent pour un utilisateur.
     *
     * @param userId identifiant de l'utilisateur
     * @return true si des préférences existent
     */
    boolean existsByUserId(UUID userId);
}
