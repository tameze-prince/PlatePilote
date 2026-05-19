-- V103__subscription_entitlements.sql
-- Provider-neutral entitlement state for App Store / Play Store billing readiness.

ALTER TABLE subscriptions ADD COLUMN IF NOT EXISTS provider VARCHAR(40) DEFAULT 'INTERNAL';
ALTER TABLE subscriptions ADD COLUMN IF NOT EXISTS provider_subscription_id VARCHAR(255);
ALTER TABLE subscriptions ADD COLUMN IF NOT EXISTS purchase_token VARCHAR(1000);
ALTER TABLE subscriptions ADD COLUMN IF NOT EXISTS original_transaction_id VARCHAR(255);
ALTER TABLE subscriptions ADD COLUMN IF NOT EXISTS expires_at TIMESTAMP WITH TIME ZONE;
ALTER TABLE subscriptions ADD COLUMN IF NOT EXISTS last_verified_at TIMESTAMP WITH TIME ZONE;

CREATE TABLE IF NOT EXISTS user_entitlements (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES our_user(id) ON DELETE CASCADE,
    entitlement_key VARCHAR(120) NOT NULL,
    source VARCHAR(40) NOT NULL DEFAULT 'INTERNAL',
    status VARCHAR(40) NOT NULL DEFAULT 'ACTIVE',
    starts_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    expires_at TIMESTAMP WITH TIME ZONE,
    last_verified_at TIMESTAMP WITH TIME ZONE,
    metadata JSONB,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMP WITH TIME ZONE,
    CONSTRAINT uk_user_entitlement_key UNIQUE (user_id, entitlement_key)
);

CREATE INDEX IF NOT EXISTS idx_user_entitlements_user_status ON user_entitlements(user_id, status);
CREATE INDEX IF NOT EXISTS idx_user_entitlements_expires ON user_entitlements(expires_at);
