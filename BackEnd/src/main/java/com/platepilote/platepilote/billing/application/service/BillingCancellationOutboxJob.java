package com.platepilote.platepilote.billing.application.service;

import com.platepilote.platepilote.billing.domain.entity.BillingCancellationRequest;
import com.platepilote.platepilote.billing.domain.repository.BillingCancellationRequestRepository;
import com.platepilote.platepilote.subscription.domain.repository.SubscriptionRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Duration;
import java.time.Instant;
import java.util.List;

/**
 * Retries durable provider cancellations. The database row is retained for
 * operational follow-up when the bounded retry policy is exhausted.
 */
@Service
public class BillingCancellationOutboxJob {

    private static final Logger log = LoggerFactory.getLogger(BillingCancellationOutboxJob.class);
    private static final int MAX_ATTEMPTS = 12;

    private final BillingCancellationRequestRepository requestRepository;
    private final BillingProvider billingProvider;
    private final SubscriptionRepository subscriptionRepository;

    public BillingCancellationOutboxJob(
            BillingCancellationRequestRepository requestRepository,
            BillingProvider billingProvider,
            SubscriptionRepository subscriptionRepository
    ) {
        this.requestRepository = requestRepository;
        this.billingProvider = billingProvider;
        this.subscriptionRepository = subscriptionRepository;
    }

    @Scheduled(fixedDelayString = "${app.billing.cancellation-retry-delay-ms:60000}")
    @Transactional
    public void processDueRequests() {
        List<BillingCancellationRequest> dueRequests =
                requestRepository.findTop20ByStatusAndNextAttemptAtLessThanEqualOrderByCreatedAtAsc(
                        "PENDING", Instant.now());

        for (BillingCancellationRequest request : dueRequests) {
            try {
                billingProvider.cancelSubscription(request.getProviderSubscriptionId());
                request.markCompleted(Instant.now());
                if (request.getSubscriptionId() != null) {
                    subscriptionRepository.findById(request.getSubscriptionId()).ifPresent(subscription -> {
                        subscription.setStatus("CANCELLED");
                        subscription.setCancelAtPeriodEnd(false);
                        subscription.setEndDate(Instant.now());
                        subscription.setExpiresAt(Instant.now());
                        subscriptionRepository.save(subscription);
                    });
                }
                log.info("Completed billing cancellation request {}", request.getId());
            } catch (Exception exception) {
                Instant now = Instant.now();
                int nextAttempt = request.getAttemptCount() + 1;
                long delayMinutes = Math.min(360L, 1L << Math.min(nextAttempt, 9));
                request.markFailedAttempt(
                        exception.getMessage(),
                        now,
                        now.plus(Duration.ofMinutes(delayMinutes)),
                        MAX_ATTEMPTS);
                if ("FAILED".equals(request.getStatus())) {
                    if (request.getSubscriptionId() != null) {
                        subscriptionRepository.findById(request.getSubscriptionId()).ifPresent(subscription -> {
                            subscription.setStatus("CANCELLATION_FAILED");
                            subscriptionRepository.save(subscription);
                        });
                    }
                    log.error("Billing cancellation request {} exhausted retries; manual action required",
                            request.getId());
                } else {
                    log.warn("Billing cancellation request {} failed; retry scheduled at {}",
                            request.getId(), request.getNextAttemptAt());
                }
            }
            requestRepository.save(request);
        }
    }
}
