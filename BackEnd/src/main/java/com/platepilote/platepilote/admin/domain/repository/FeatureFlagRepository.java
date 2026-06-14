package com.platepilote.platepilote.admin.domain.repository;

import com.platepilote.platepilote.admin.domain.entity.FeatureFlag;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;
import java.util.UUID;

/**
 * Repository pour l'entité {@link FeatureFlag}.
 */
public interface FeatureFlagRepository extends JpaRepository<FeatureFlag, UUID> {

    /**
     * Recherche un feature flag par sa clé.
     *
     * @param flagKey clé du feature flag
     * @return feature flag trouvé ou vide
     */
    Optional<FeatureFlag> findByFlagKey(String flagKey);
}
