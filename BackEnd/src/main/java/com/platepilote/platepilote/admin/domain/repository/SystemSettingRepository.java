package com.platepilote.platepilote.admin.domain.repository;

import com.platepilote.platepilote.admin.domain.entity.SystemSetting;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;
import java.util.UUID;

/**
 * Repository pour l'entité {@link SystemSetting}.
 */

public interface SystemSettingRepository extends JpaRepository<SystemSetting, UUID> {

    /**
     * Recherche un paramètre système par sa clé.
     *
     * @param settingKey clé du paramètre
     * @return paramètre trouvé ou vide
     */
    Optional<SystemSetting> findBySettingKey(String settingKey);
}
