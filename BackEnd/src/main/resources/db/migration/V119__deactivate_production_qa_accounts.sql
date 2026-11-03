-- V119__deactivate_production_qa_accounts.sql
-- V117 contains deterministic QA identities for local/dev environments.
-- Production skips a still-pending V117; this forward-only cleanup also
-- disables those identities on installations where V117 was already applied.
DO $$
BEGIN
    IF '${environment}' = 'production' THEN
        UPDATE our_user
        SET enabled = FALSE,
            deleted_at = COALESCE(deleted_at, CURRENT_TIMESTAMP),
            updated_at = CURRENT_TIMESTAMP
        WHERE email LIKE '%@platepilote.test';
    END IF;
END $$;
