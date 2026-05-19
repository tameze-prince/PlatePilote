-- V106__stripe_billing_foundation.sql
-- Stripe-first billing while keeping provider-neutral entitlements as the premium source of truth.

CREATE TABLE IF NOT EXISTS billing_customers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES our_user(id) ON DELETE CASCADE,
    provider VARCHAR(40) NOT NULL,
    provider_customer_id VARCHAR(255) NOT NULL,
    email VARCHAR(255),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMP WITH TIME ZONE,
    CONSTRAINT uk_billing_customer_provider_user UNIQUE (provider, user_id),
    CONSTRAINT uk_billing_customer_provider_customer UNIQUE (provider, provider_customer_id)
);

CREATE TABLE IF NOT EXISTS billing_events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    provider VARCHAR(40) NOT NULL,
    event_id VARCHAR(255) NOT NULL,
    event_type VARCHAR(120) NOT NULL,
    processed BOOLEAN NOT NULL DEFAULT FALSE,
    error_message TEXT,
    raw_payload TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    processed_at TIMESTAMP WITH TIME ZONE,
    CONSTRAINT uk_billing_event_provider_event UNIQUE (provider, event_id)
);

CREATE INDEX IF NOT EXISTS idx_billing_events_provider_created ON billing_events(provider, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_billing_events_processed ON billing_events(processed);

INSERT INTO system_settings (setting_key, setting_value, description) VALUES
    ('billing_free_trial_days', '30', 'Free trial duration for first-time premium subscriptions'),
    ('billing_past_due_grace_days', '3', 'Days to keep premium active for past-due Stripe subscriptions')
ON CONFLICT (setting_key) DO NOTHING;
