-- Durable provider cancellation requests must outlive the user row.
CREATE TABLE billing_cancellation_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    subscription_id UUID,
    provider VARCHAR(32) NOT NULL,
    provider_subscription_id VARCHAR(255) NOT NULL,
    status VARCHAR(24) NOT NULL DEFAULT 'PENDING',
    attempt_count INTEGER NOT NULL DEFAULT 0,
    next_attempt_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_error TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_billing_cancellation_provider_subscription
        UNIQUE (provider, provider_subscription_id),
    CONSTRAINT ck_billing_cancellation_status
        CHECK (status IN ('PENDING', 'COMPLETED', 'FAILED'))
);

CREATE INDEX idx_billing_cancellation_due
    ON billing_cancellation_requests(status, next_attempt_at, created_at)
    WHERE status = 'PENDING';
