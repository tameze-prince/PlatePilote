package com.platepilote.platepilote.billing.domain.repository;

import com.platepilote.platepilote.billing.domain.entity.BillingEvent;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;
import java.util.UUID;

public interface BillingEventRepository extends JpaRepository<BillingEvent, UUID> {

    Optional<BillingEvent> findByProviderAndEventId(String provider, String eventId);

    Page<BillingEvent> findAllByOrderByCreatedAtDesc(Pageable pageable);
}
