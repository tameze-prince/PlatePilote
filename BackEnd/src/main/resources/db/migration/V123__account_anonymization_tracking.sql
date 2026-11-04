-- V123__account_anonymization_tracking.sql
-- Prevent the scheduled anonymizer from reprocessing the same account every day.

ALTER TABLE our_user
    ADD COLUMN IF NOT EXISTS anonymized_at TIMESTAMP WITH TIME ZONE;

CREATE INDEX IF NOT EXISTS idx_our_user_pending_anonymization
    ON our_user(deleted_at)
    WHERE enabled = FALSE AND deleted_at IS NOT NULL AND anonymized_at IS NULL;
