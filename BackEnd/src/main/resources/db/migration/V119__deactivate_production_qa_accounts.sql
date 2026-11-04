-- V119__deactivate_production_qa_accounts.sql
-- V117 is part of the immutable historical migration chain and still executes
-- on a fresh production database. This forward-only migration disables the
-- QA identities before the application starts serving requests. It also
-- cleans up installations where V117 was applied previously.
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
