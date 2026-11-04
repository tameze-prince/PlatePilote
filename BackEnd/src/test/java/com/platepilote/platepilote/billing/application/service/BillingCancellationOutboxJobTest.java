package com.platepilote.platepilote.billing.application.service;

import com.platepilote.platepilote.billing.domain.entity.BillingCancellationRequest;
import com.platepilote.platepilote.billing.domain.repository.BillingCancellationRequestRepository;
import com.platepilote.platepilote.subscription.domain.repository.SubscriptionRepository;
import org.junit.jupiter.api.Test;

import java.time.Instant;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

class BillingCancellationOutboxJobTest {

    @Test
    void successfulProviderCancellationMarksRequestCompleted() {
        BillingCancellationRequestRepository requests = mock(BillingCancellationRequestRepository.class);
        BillingProvider provider = mock(BillingProvider.class);
        SubscriptionRepository subscriptions = mock(SubscriptionRepository.class);
        BillingCancellationRequest request = dueRequest();
        UUID subscriptionId = UUID.randomUUID();
        Subscription subscription = subscription(subscriptionId);
        request.setSubscriptionId(subscriptionId);
        when(requests.findTop20ByStatusAndNextAttemptAtLessThanEqualOrderByCreatedAtAsc(
                org.mockito.ArgumentMatchers.eq("PENDING"), any(Instant.class))).thenReturn(List.of(request));
        when(subscriptions.findById(subscriptionId)).thenReturn(Optional.of(subscription));

        new BillingCancellationOutboxJob(requests, provider, subscriptions).processDueRequests();

        assertThat(request.getStatus()).isEqualTo("COMPLETED");
        assertThat(request.getLastError()).isNull();
        assertThat(subscription.getStatus()).isEqualTo("CANCELLED");
        verify(provider).cancelSubscription("sub_123");
        verify(subscriptions).save(subscription);
        verify(requests).save(request);
    }

    @Test
    void providerFailureSchedulesRetryAndKeepsRequestPending() {
        BillingCancellationRequestRepository requests = mock(BillingCancellationRequestRepository.class);
        BillingProvider provider = mock(BillingProvider.class);
        SubscriptionRepository subscriptions = mock(SubscriptionRepository.class);
        BillingCancellationRequest request = dueRequest();
        when(requests.findTop20ByStatusAndNextAttemptAtLessThanEqualOrderByCreatedAtAsc(
                org.mockito.ArgumentMatchers.eq("PENDING"), any(Instant.class))).thenReturn(List.of(request));
        org.mockito.Mockito.doThrow(new IllegalStateException("Stripe unavailable"))
                .when(provider).cancelSubscription("sub_123");

        new BillingCancellationOutboxJob(requests, provider, subscriptions).processDueRequests();

        assertThat(request.getStatus()).isEqualTo("PENDING");
        assertThat(request.getAttemptCount()).isEqualTo(1);
        assertThat(request.getLastError()).contains("Stripe unavailable");
        assertThat(request.getNextAttemptAt()).isAfter(Instant.now());
        verify(requests).save(request);
        verify(subscriptions, never()).save(any());
    }

    @Test
    void exhaustedRetriesMarkRequestAndSubscriptionAsFailed() {
        BillingCancellationRequestRepository requests = mock(BillingCancellationRequestRepository.class);
        BillingProvider provider = mock(BillingProvider.class);
        SubscriptionRepository subscriptions = mock(SubscriptionRepository.class);
        BillingCancellationRequest request = dueRequest();
        request.setAttemptCount(11);
        UUID subscriptionId = UUID.randomUUID();
        Subscription subscription = subscription(subscriptionId);
        request.setSubscriptionId(subscriptionId);
        when(requests.findTop20ByStatusAndNextAttemptAtLessThanEqualOrderByCreatedAtAsc(
                org.mockito.ArgumentMatchers.eq("PENDING"), any(Instant.class))).thenReturn(List.of(request));
        when(subscriptions.findById(subscriptionId)).thenReturn(Optional.of(subscription));
        org.mockito.Mockito.doThrow(new IllegalStateException("Stripe unavailable"))
                .when(provider).cancelSubscription("sub_123");

        new BillingCancellationOutboxJob(requests, provider, subscriptions).processDueRequests();

        assertThat(request.getStatus()).isEqualTo("FAILED");
        assertThat(request.getAttemptCount()).isEqualTo(12);
        assertThat(subscription.getStatus()).isEqualTo("CANCELLATION_FAILED");
        verify(subscriptions).save(subscription);
        verify(requests).save(request);
    }

    private Subscription subscription(UUID id) {
        Subscription subscription = Subscription.builder()
                .userId(UUID.randomUUID())
                .provider("STRIPE")
                .providerSubscriptionId("sub_123")
                .planType("PREMIUM_MONTHLY")
                .status("CANCELLATION_PENDING")
                .startDate(Instant.now().minusSeconds(60))
                .build();
        subscription.setId(id);
        return subscription;
    }

    private BillingCancellationRequest dueRequest() {
        BillingCancellationRequest request = new BillingCancellationRequest();
        request.setUserId(java.util.UUID.randomUUID());
        request.setProvider("STRIPE");
        request.setProviderSubscriptionId("sub_123");
        request.setStatus("PENDING");
        request.setAttemptCount(0);
        request.setNextAttemptAt(Instant.now().minusSeconds(1));
        request.setCreatedAt(Instant.now().minusSeconds(60));
        request.setUpdatedAt(Instant.now().minusSeconds(60));
        return request;
    }
}
