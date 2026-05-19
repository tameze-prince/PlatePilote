-- V101__core_v1_authorization_recommendations_admin.sql
-- Core v1 backend completion: RBAC, profile location, canonical ingredient links, admin/audit tables.

-- Roles
INSERT INTO roles (id, name, description) VALUES
    (uuid_generate_v4(), 'ROLE_USER', 'Standard user role'),
    (uuid_generate_v4(), 'ROLE_PREMIUM_USER', 'Premium subscriber role'),
    (uuid_generate_v4(), 'ROLE_ADMIN', 'Platform administrator'),
    (uuid_generate_v4(), 'ROLE_SUPER_ADMIN', 'Full platform administrator'),
    (uuid_generate_v4(), 'ROLE_SUPPORT_AGENT', 'Customer support agent'),
    (uuid_generate_v4(), 'ROLE_ANALYST', 'Analytics read-only role'),
    (uuid_generate_v4(), 'ROLE_CONTENT_MANAGER', 'Food content and import manager'),
    (uuid_generate_v4(), 'ROLE_SYSTEM', 'Automated system task role')
ON CONFLICT (name) DO UPDATE SET description = EXCLUDED.description;

-- Normalize legacy premium role if present.
UPDATE roles
SET name = 'ROLE_PREMIUM_USER',
    description = 'Premium subscriber role'
WHERE name = 'ROLE_PREMIUM'
  AND NOT EXISTS (SELECT 1 FROM roles WHERE name = 'ROLE_PREMIUM_USER');

INSERT INTO user_roles (user_id, role_id)
SELECT ur.user_id, premium_user.id
FROM user_roles ur
JOIN roles legacy_premium ON legacy_premium.id = ur.role_id AND legacy_premium.name = 'ROLE_PREMIUM'
JOIN roles premium_user ON premium_user.name = 'ROLE_PREMIUM_USER'
ON CONFLICT (user_id, role_id) DO NOTHING;

INSERT INTO user_roles (user_id, role_id)
SELECT u.id, user_role.id
FROM our_user u
JOIN roles user_role ON user_role.name = 'ROLE_USER'
WHERE NOT EXISTS (SELECT 1 FROM user_roles ur WHERE ur.user_id = u.id)
ON CONFLICT (user_id, role_id) DO NOTHING;

-- Profile/location fields for locale-aware recommendations.
ALTER TABLE user_profiles ADD COLUMN IF NOT EXISTS country_code VARCHAR(2) DEFAULT 'US';
ALTER TABLE user_profiles ADD COLUMN IF NOT EXISTS currency_code VARCHAR(3) DEFAULT 'USD';
ALTER TABLE user_profiles ADD COLUMN IF NOT EXISTS locale VARCHAR(20) DEFAULT 'en-US';
ALTER TABLE user_profiles ADD COLUMN IF NOT EXISTS cooking_skill VARCHAR(30) DEFAULT 'BEGINNER';
ALTER TABLE user_profiles ADD COLUMN IF NOT EXISTS household_size INTEGER DEFAULT 1;

-- Canonical ingredient links for accurate pantry/recipe matching and pricing.
ALTER TABLE recipe_ingredients ADD COLUMN IF NOT EXISTS ingredient_id UUID REFERENCES ingredients(id);
ALTER TABLE pantry_items ADD COLUMN IF NOT EXISTS ingredient_id UUID REFERENCES ingredients(id);

CREATE INDEX IF NOT EXISTS idx_recipe_ingredients_ingredient ON recipe_ingredients(ingredient_id);
CREATE INDEX IF NOT EXISTS idx_pantry_items_ingredient ON pantry_items(ingredient_id);
CREATE INDEX IF NOT EXISTS idx_ingredient_prices_lookup ON ingredient_prices(ingredient_id, country_code, effective_date DESC);
CREATE INDEX IF NOT EXISTS idx_recipes_flags ON recipes(is_public, deleted_at, cuisine_type, meal_type, total_time_minutes);

-- Backfill recipe/pantry canonical ingredient IDs using canonical names first, then aliases.
UPDATE recipe_ingredients ri
SET ingredient_id = i.id
FROM ingredients i
WHERE ri.ingredient_id IS NULL
  AND LOWER(TRIM(ri.name)) = LOWER(TRIM(i.canonical_name));

UPDATE recipe_ingredients ri
SET ingredient_id = ia.ingredient_id
FROM ingredient_aliases ia
WHERE ri.ingredient_id IS NULL
  AND LOWER(REGEXP_REPLACE(ri.name, '[^a-zA-Z0-9]+', ' ', 'g')) = ia.normalized_alias;

UPDATE pantry_items pi
SET ingredient_id = i.id
FROM ingredients i
WHERE pi.ingredient_id IS NULL
  AND LOWER(TRIM(pi.name)) = LOWER(TRIM(i.canonical_name));

UPDATE pantry_items pi
SET ingredient_id = ia.ingredient_id
FROM ingredient_aliases ia
WHERE pi.ingredient_id IS NULL
  AND LOWER(REGEXP_REPLACE(pi.name, '[^a-zA-Z0-9]+', ' ', 'g')) = ia.normalized_alias;

-- Admin and observability tables.
CREATE TABLE IF NOT EXISTS audit_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    actor_user_id UUID REFERENCES our_user(id),
    actor_email VARCHAR(255),
    action VARCHAR(120) NOT NULL,
    target_type VARCHAR(120),
    target_id VARCHAR(120),
    metadata JSONB,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS feature_flags (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    flag_key VARCHAR(120) NOT NULL UNIQUE,
    description TEXT,
    enabled BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS system_settings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    setting_key VARCHAR(120) NOT NULL UNIQUE,
    setting_value TEXT,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS admin_notes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES our_user(id),
    admin_user_id UUID REFERENCES our_user(id),
    note TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS ai_usage_metrics (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES our_user(id),
    provider VARCHAR(120),
    operation VARCHAR(120) NOT NULL,
    input_tokens INTEGER DEFAULT 0,
    output_tokens INTEGER DEFAULT 0,
    estimated_cost DECIMAL(10,4) DEFAULT 0,
    success BOOLEAN DEFAULT TRUE,
    error_message TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS recommendation_events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES our_user(id) ON DELETE CASCADE,
    request_type VARCHAR(50) NOT NULL,
    country_code VARCHAR(2),
    currency_code VARCHAR(3),
    result_count INTEGER NOT NULL DEFAULT 0,
    duration_ms INTEGER,
    quota_limited BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_audit_logs_created ON audit_logs(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_audit_logs_actor ON audit_logs(actor_user_id);
CREATE INDEX IF NOT EXISTS idx_recommendation_events_user_created ON recommendation_events(user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_user_interactions_user_created ON user_interactions(user_id, created_at DESC);

INSERT INTO feature_flags (flag_key, description, enabled) VALUES
    ('enable_premium_trial', 'Allow users to start premium trials', FALSE),
    ('enable_ai_suggestions', 'Enable optional AI-assisted suggestions', FALSE),
    ('enable_shared_households', 'Enable household sharing features', FALSE),
    ('enable_beta_features', 'Expose beta features to selected users', FALSE)
ON CONFLICT (flag_key) DO NOTHING;

INSERT INTO system_settings (setting_key, setting_value, description) VALUES
    ('free_weekly_recommendation_limit', '20', 'Maximum weekly recommendation requests for free users'),
    ('recommendation_weight_pantry', '0.25', 'Recommendation pantry match weight'),
    ('recommendation_weight_budget', '0.20', 'Recommendation budget fit weight'),
    ('recommendation_weight_preference', '0.20', 'Recommendation preference and cuisine weight'),
    ('recommendation_weight_nutrition', '0.15', 'Recommendation nutrition goal weight'),
    ('recommendation_weight_time', '0.10', 'Recommendation time convenience weight'),
    ('recommendation_weight_variety', '0.05', 'Recommendation variety weight'),
    ('recommendation_weight_location', '0.05', 'Recommendation location relevance weight')
ON CONFLICT (setting_key) DO NOTHING;
