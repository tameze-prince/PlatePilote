package com.platepilote.platepilote.me.application.dto;

import java.time.Instant;
import java.util.UUID;

public record NotificationExportDto(
        UUID id,
        String type,
        String title,
        String body,
        String data,
        Boolean read,
        Instant readAt,
        Instant createdAt
) {}
