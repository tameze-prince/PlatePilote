package com.platepilote.platepilote.subscription.domain.repository;

import com.platepilote.platepilote.subscription.domain.entity.Subscription;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface SubscriptionRepository extends JpaRepository<Subscription, UUID> {

    Optional<Subscription> findByUserId(UUID userId);

    Optional<Subscription> findByProviderAndProviderSubscriptionId(String provider, String providerSubscriptionId);

    boolean existsByUserId(UUID userId);
}
