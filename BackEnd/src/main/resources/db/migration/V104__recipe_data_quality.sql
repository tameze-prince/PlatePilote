-- V104__recipe_data_quality.sql
-- Trust and quality fields used by the recommendation engine and admin review workflows.

ALTER TABLE recipes ADD COLUMN IF NOT EXISTS enabled BOOLEAN NOT NULL DEFAULT TRUE;
ALTER TABLE recipes ADD COLUMN IF NOT EXISTS verified BOOLEAN NOT NULL DEFAULT FALSE;
ALTER TABLE recipes ADD COLUMN IF NOT EXISTS verification_status VARCHAR(40) NOT NULL DEFAULT 'UNREVIEWED';
ALTER TABLE recipes ADD COLUMN IF NOT EXISTS nutrition_source VARCHAR(120);
ALTER TABLE recipes ADD COLUMN IF NOT EXISTS allergen_source VARCHAR(120);
ALTER TABLE recipes ADD COLUMN IF NOT EXISTS confidence_score DECIMAL(4,3) NOT NULL DEFAULT 0.500;

CREATE INDEX IF NOT EXISTS idx_recipes_quality_lookup
    ON recipes(is_public, enabled, verified, verification_status, deleted_at);
