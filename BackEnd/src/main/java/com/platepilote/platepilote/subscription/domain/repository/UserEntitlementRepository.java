package com.platepilote.platepilote.subscription.domain.repository;

import com.platepilote.platepilote.subscription.domain.entity.UserEntitlement;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.Instant;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface UserEntitlementRepository extends JpaRepository<UserEntitlement, UUID> {

    Optional<UserEntitlement> findByUserIdAndEntitlementKey(UUID userId, String entitlementKey);

    List<UserEntitlement> findByUserIdAndStatusAndDeletedAtIsNull(UUID userId, String status);

    boolean existsByUserIdAndEntitlementKeyAndStatusAndDeletedAtIsNull(UUID userId, String entitlementKey, String status);

    List<UserEntitlement> findByStatusAndExpiresAtBeforeAndDeletedAtIsNull(String status, Instant expiresAt);
}
