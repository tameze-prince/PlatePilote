package com.platepilote.platepilote.me.application.dto;

import java.time.Instant;

public record SubscriptionExportDto(
        String planType,
        String status,
        String provider,
        Instant startDate,
        Instant endDate,
        Instant trialEndDate,
        Boolean cancelAtPeriodEnd,
        Instant expiresAt,
        Instant lastVerifiedAt
) {}
