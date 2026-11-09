-- V127__normalize_legacy_timestamps_and_recipe_confidence.sql
--
-- The legacy columns below were created as TIMESTAMP WITHOUT TIME ZONE.
-- The established database convention is UTC, so interpret each stored
-- wall-clock value as UTC when converting it to TIMESTAMPTZ.
-- Do not edit this migration after application; use a new migration instead.

ALTER TABLE ingredients
    ALTER COLUMN created_at TYPE TIMESTAMP WITH TIME ZONE
        USING created_at AT TIME ZONE 'UTC',
    ALTER COLUMN updated_at TYPE TIMESTAMP WITH TIME ZONE
        USING updated_at AT TIME ZONE 'UTC',
    ALTER COLUMN deleted_at TYPE TIMESTAMP WITH TIME ZONE
        USING deleted_at AT TIME ZONE 'UTC';

ALTER TABLE barcode_products
    ALTER COLUMN created_at TYPE TIMESTAMP WITH TIME ZONE
        USING created_at AT TIME ZONE 'UTC',
    ALTER COLUMN updated_at TYPE TIMESTAMP WITH TIME ZONE
        USING updated_at AT TIME ZONE 'UTC',
    ALTER COLUMN deleted_at TYPE TIMESTAMP WITH TIME ZONE
        USING deleted_at AT TIME ZONE 'UTC';

ALTER TABLE import_jobs
    ALTER COLUMN created_at TYPE TIMESTAMP WITH TIME ZONE
        USING created_at AT TIME ZONE 'UTC',
    ALTER COLUMN updated_at TYPE TIMESTAMP WITH TIME ZONE
        USING updated_at AT TIME ZONE 'UTC',
    ALTER COLUMN deleted_at TYPE TIMESTAMP WITH TIME ZONE
        USING deleted_at AT TIME ZONE 'UTC',
    ALTER COLUMN started_at TYPE TIMESTAMP WITH TIME ZONE
        USING started_at AT TIME ZONE 'UTC',
    ALTER COLUMN completed_at TYPE TIMESTAMP WITH TIME ZONE
        USING completed_at AT TIME ZONE 'UTC';

ALTER TABLE purchase_records
    ALTER COLUMN purchased_at TYPE TIMESTAMP WITH TIME ZONE
        USING purchased_at AT TIME ZONE 'UTC',
    ALTER COLUMN created_at TYPE TIMESTAMP WITH TIME ZONE
        USING created_at AT TIME ZONE 'UTC',
    ALTER COLUMN updated_at TYPE TIMESTAMP WITH TIME ZONE
        USING updated_at AT TIME ZONE 'UTC',
    ALTER COLUMN deleted_at TYPE TIMESTAMP WITH TIME ZONE
        USING deleted_at AT TIME ZONE 'UTC';

-- Recipe.confidenceScore is a Java Double; align its SQL representation.
ALTER TABLE recipes
    ALTER COLUMN confidence_score TYPE DOUBLE PRECISION
        USING confidence_score::DOUBLE PRECISION;
