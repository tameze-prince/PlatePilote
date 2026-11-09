-- V128__enforce_entity_schema_contracts.sql
--
-- Align nullable/defaulted legacy columns with the JPA entity contract.
-- Existing rows are normalized before NOT NULL constraints are applied.
-- V121's foreign-key guard was global by constraint name; verify the
-- relationship against the target table and referenced table here.

UPDATE our_user
SET provider = CASE
    WHEN provider_id IS NOT NULL THEN 'google'
    ELSE 'local'
END
WHERE provider IS NULL OR BTRIM(provider) = '';

UPDATE our_user SET enabled = TRUE WHERE enabled IS NULL;
ALTER TABLE our_user
    ALTER COLUMN provider SET DEFAULT 'local',
    ALTER COLUMN provider SET NOT NULL,
    ALTER COLUMN enabled SET DEFAULT TRUE,
    ALTER COLUMN enabled SET NOT NULL;

UPDATE refresh_tokens SET revoked = FALSE WHERE revoked IS NULL;
ALTER TABLE refresh_tokens
    ALTER COLUMN revoked SET DEFAULT FALSE,
    ALTER COLUMN revoked SET NOT NULL;

UPDATE email_verification_tokens SET used = FALSE WHERE used IS NULL;
ALTER TABLE email_verification_tokens
    ALTER COLUMN used SET DEFAULT FALSE,
    ALTER COLUMN used SET NOT NULL;

UPDATE notifications SET read = FALSE WHERE read IS NULL;
ALTER TABLE notifications
    ALTER COLUMN read SET DEFAULT FALSE,
    ALTER COLUMN read SET NOT NULL;

UPDATE grocery_items SET checked = FALSE WHERE checked IS NULL;
ALTER TABLE grocery_items
    ALTER COLUMN checked SET DEFAULT FALSE,
    ALTER COLUMN checked SET NOT NULL;

UPDATE grocery_lists SET status = 'ACTIVE'
WHERE status IS NULL OR BTRIM(status) = '';
ALTER TABLE grocery_lists
    ALTER COLUMN status SET DEFAULT 'ACTIVE',
    ALTER COLUMN status SET NOT NULL;

UPDATE meal_plans SET status = 'DRAFT'
WHERE status IS NULL OR BTRIM(status) = '';
ALTER TABLE meal_plans
    ALTER COLUMN status SET DEFAULT 'DRAFT',
    ALTER COLUMN status SET NOT NULL;

-- V101 already creates locale as VARCHAR(20). V117's conditional fallback
-- used VARCHAR(5); widen it explicitly so every supported migration path
-- converges on the same schema.
ALTER TABLE user_profiles
    ALTER COLUMN locale TYPE VARCHAR(20);

-- V117 adds this profile field for seeded personas. Map it in JPA and make
-- the column declaration explicit for databases that did not run that
-- conditional branch.
ALTER TABLE user_profiles
    ADD COLUMN IF NOT EXISTS weekly_budget NUMERIC(10,2);

-- V121 checked the constraint name globally instead of scoping it to the
-- device_registrations table. Remove impossible orphan registrations and
-- guarantee the intended FK exists on this table.
DELETE FROM device_registrations dr
WHERE NOT EXISTS (
    SELECT 1 FROM our_user u WHERE u.id = dr.user_id
);

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint c
        WHERE c.conrelid = 'device_registrations'::regclass
          AND c.contype = 'f'
          AND c.confrelid = 'our_user'::regclass
          AND pg_get_constraintdef(c.oid) LIKE 'FOREIGN KEY (user_id) REFERENCES our_user(id)%'
    ) THEN
        ALTER TABLE device_registrations
            ADD CONSTRAINT fk_device_registrations_user
            FOREIGN KEY (user_id) REFERENCES our_user(id) ON DELETE CASCADE;
    END IF;
END $$;
