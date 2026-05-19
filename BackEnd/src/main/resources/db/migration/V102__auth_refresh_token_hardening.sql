-- V102__auth_refresh_token_hardening.sql
-- Index persisted refresh tokens for rotation, logout, and cleanup paths.

CREATE INDEX IF NOT EXISTS idx_refresh_tokens_user_revoked ON refresh_tokens(user_id, revoked);
CREATE INDEX IF NOT EXISTS idx_refresh_tokens_expires_at ON refresh_tokens(expires_at);
