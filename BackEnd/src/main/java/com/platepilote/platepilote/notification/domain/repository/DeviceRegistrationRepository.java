package com.platepilote.platepilote.notification.domain.repository;

import com.platepilote.platepilote.notification.domain.entity.DeviceRegistration;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

/**
 * Repository pour l'accès aux données des enregistrements d'appareils.
 * <p>
 * Permet de rechercher un appareil par son token et de compter les
 * appareils actifs d'un utilisateur.
 */
@Repository
public interface DeviceRegistrationRepository extends JpaRepository<DeviceRegistration, UUID> {

    /**
     * Recherche un enregistrement d'appareil par son token.
     *
     * @param deviceToken token de l'appareil
     * @return enregistrement trouvé ou vide
     */
    Optional<DeviceRegistration> findByDeviceToken(String deviceToken);

    /**
     * Compte le nombre d'appareils actifs d'un utilisateur.
     *
     * @param userId identifiant de l'utilisateur
     * @return nombre d'appareils actifs
     */
    long countByUserIdAndIsActiveTrue(UUID userId);
}
