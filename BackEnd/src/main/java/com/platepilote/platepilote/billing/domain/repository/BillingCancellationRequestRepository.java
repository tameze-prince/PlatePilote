package com.platepilote.platepilote.billing.domain.repository;

import com.platepilote.platepilote.billing.domain.entity.BillingCancellationRequest;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;

import jakarta.persistence.LockModeType;
import java.time.Instant;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface BillingCancellationRequestRepository extends JpaRepository<BillingCancellationRequest, UUID> {

    Optional<BillingCancellationRequest> findByProviderAndProviderSubscriptionId(
            String provider, String providerSubscriptionId);

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    List<BillingCancellationRequest> findTop20ByStatusAndNextAttemptAtLessThanEqualOrderByCreatedAtAsc(
            String status, Instant now);
}
