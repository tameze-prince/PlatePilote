ALTER TABLE meal_plans ADD COLUMN IF NOT EXISTS mode VARCHAR(20) NOT NULL DEFAULT 'STANDARD';

CREATE TABLE IF NOT EXISTS swap_tracking (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES our_users(id) ON DELETE CASCADE,
    swapped_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_swap_tracking_user_week ON swap_tracking(user_id, swapped_at DESC);
