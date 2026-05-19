package com.platepilote.platepilote.billing.domain.repository;

import com.platepilote.platepilote.billing.domain.entity.BillingCustomer;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;
import java.util.UUID;

public interface BillingCustomerRepository extends JpaRepository<BillingCustomer, UUID> {

    Optional<BillingCustomer> findByProviderAndUserId(String provider, UUID userId);

    Optional<BillingCustomer> findByProviderAndProviderCustomerId(String provider, String providerCustomerId);
}
