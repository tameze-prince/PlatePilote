package com.platepilote.platepilote.billing.application.service;

import com.platepilote.platepilote.billing.domain.entity.BillingCancellationRequest;
import com.platepilote.platepilote.billing.domain.repository.BillingCancellationRequestRepository;
import com.platepilote.platepilote.common.AbstractIntegrationTest;
import com.platepilote.platepilote.common.RequiresDocker;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

/**
 * PostgreSQL-backed coverage for Flyway V124, the JPA mapping, the due-request
 * locking query, and the uniqueness guarantee. This is deliberately named
 * *Test (not *IT) so Maven Surefire includes it in the regular verify lifecycle.
 */
@RequiresDocker
class BillingCancellationOutboxPostgresTest extends AbstractIntegrationTest {

    @Autowired
    private BillingCancellationRequestRepository requestRepository;

    @Test
    @Transactional
    void v124CreatesQueryableOutboxAndDueRequestCanBeLocked() {
        BillingCancellationRequest request = newRequest("sub_" + UUID.randomUUID());

        BillingCancellationRequest saved = requestRepository.saveAndFlush(request);

        assertThat(saved.getId()).isNotNull();
        assertThat(saved.getCreatedAt()).isNotNull();
        assertThat(saved.getUpdatedAt()).isNotNull();

        assertThat(requestRepository
                .findTop20ByStatusAndNextAttemptAtLessThanEqualOrderByCreatedAtAsc(
                        "PENDING", Instant.now()))
                .extracting(BillingCancellationRequest::getId)
                .contains(saved.getId());
    }

    @Test
    @Transactional
    void providerSubscriptionPairMustBeUnique() {
        String providerSubscriptionId = "sub_" + UUID.randomUUID();
        requestRepository.saveAndFlush(newRequest(providerSubscriptionId));

        assertThatThrownBy(() -> requestRepository.saveAndFlush(newRequest(providerSubscriptionId)))
                .isInstanceOf(DataIntegrityViolationException.class);
    }

    private BillingCancellationRequest newRequest(String providerSubscriptionId) {
        BillingCancellationRequest request = new BillingCancellationRequest();
        // A random user UUID intentionally proves that the outbox survives without
        // a user FK and remains insertable after account deletion/anonymization.
        request.setUserId(UUID.randomUUID());
        request.setProvider("STRIPE");
        request.setProviderSubscriptionId(providerSubscriptionId);
        request.setStatus("PENDING");
        request.setAttemptCount(0);
        request.setNextAttemptAt(Instant.now().minusSeconds(1));
        return request;
    }
}
