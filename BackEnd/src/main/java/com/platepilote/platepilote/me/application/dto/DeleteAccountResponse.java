package com.platepilote.platepilote.me.application.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.Instant;
import java.util.UUID;

@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class DeleteAccountResponse {
    private UUID userId;
    private Instant deletionDateAt;
    /**
     * @deprecated Use scheduledAnonymizationAt; financial records may be retained.
     */
    @Deprecated
    private Instant scheduledPurgeAt;
    private Instant scheduledAnonymizationAt;
    private Integer gracePeriodDays;
    private String message;
}
