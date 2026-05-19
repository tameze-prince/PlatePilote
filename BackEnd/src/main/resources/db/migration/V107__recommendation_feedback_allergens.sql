-- V107__recommendation_feedback_allergens.sql
-- Recommendation feedback, allergen mapping, fallback, and pantry-expiry support.

CREATE TABLE IF NOT EXISTS ingredient_allergens (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    ingredient_id UUID NOT NULL REFERENCES ingredients(id) ON DELETE CASCADE,
    allergen_group VARCHAR(120) NOT NULL,
    confidence_score DECIMAL(4,3) NOT NULL DEFAULT 1.000,
    source VARCHAR(120),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    CONSTRAINT uk_ingredient_allergen_group UNIQUE (ingredient_id, allergen_group)
);

CREATE INDEX IF NOT EXISTS idx_ingredient_allergens_lookup ON ingredient_allergens(ingredient_id, allergen_group);
CREATE INDEX IF NOT EXISTS idx_user_interactions_user_type ON user_interactions(user_id, interaction_type, created_at DESC);

INSERT INTO system_settings (setting_key, setting_value, description) VALUES
    ('recommendation_min_results_before_fallback', '5', 'Minimum result count before soft fallback is marked'),
    ('recommendation_expiring_pantry_days', '3', 'Days ahead considered expiring soon for recommendation boosts')
ON CONFLICT (setting_key) DO NOTHING;
