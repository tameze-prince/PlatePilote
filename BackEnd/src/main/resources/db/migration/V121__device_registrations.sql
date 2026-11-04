-- V121__device_registrations.sql
-- Persistent device-token registry for consent-based push notifications.

CREATE TABLE IF NOT EXISTS device_registrations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES our_user(id) ON DELETE CASCADE,
    device_token VARCHAR(512) NOT NULL,
    platform VARCHAR(20) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    CONSTRAINT uk_device_registrations_device_token UNIQUE (device_token),
    CONSTRAINT ck_device_registrations_platform
        CHECK (platform IN ('android', 'ios', 'web'))
);

CREATE INDEX IF NOT EXISTS idx_device_registrations_user_active
    ON device_registrations(user_id, is_active);
