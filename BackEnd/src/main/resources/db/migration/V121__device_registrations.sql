-- V121__device_registrations.sql
-- Persistent device-token registry for consent-based push notifications.
-- This migration is safe if Hibernate ddl-auto=update created the table earlier.

CREATE TABLE IF NOT EXISTS device_registrations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL,
    device_token VARCHAR(512) NOT NULL,
    platform VARCHAR(20),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Remove incomplete/duplicate rows before enforcing the production constraints.
DELETE FROM device_registrations
WHERE user_id IS NULL OR device_token IS NULL OR BTRIM(device_token) = '';

WITH ranked_tokens AS (
    SELECT
        id,
        ROW_NUMBER() OVER (
            PARTITION BY device_token
            ORDER BY updated_at DESC NULLS LAST, created_at DESC NULLS LAST, id DESC
        ) AS row_number
    FROM device_registrations
)
DELETE FROM device_registrations device
USING ranked_tokens ranked
WHERE device.id = ranked.id
  AND ranked.row_number > 1;

ALTER TABLE device_registrations
    ALTER COLUMN user_id SET NOT NULL,
    ALTER COLUMN device_token SET NOT NULL;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'fk_device_registrations_user'
    ) THEN
        ALTER TABLE device_registrations
            ADD CONSTRAINT fk_device_registrations_user
            FOREIGN KEY (user_id) REFERENCES our_user(id) ON DELETE CASCADE;
    END IF;
END $$;

CREATE UNIQUE INDEX IF NOT EXISTS idx_device_registrations_device_token_unique
    ON device_registrations(device_token);

CREATE INDEX IF NOT EXISTS idx_device_registrations_user_active
    ON device_registrations(user_id, is_active);
