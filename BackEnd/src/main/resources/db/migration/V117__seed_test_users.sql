-- V117__seed_test_users.sql
-- Seed five test users aligned with the PRD §3.1 personas. Designed so the
-- QA suite and the manual beta smoke can login as one deterministic user per
-- archetype and exercise the full REST surface end-to-end.
--
-- Idempotent: ON CONFLICT DO NOTHING ensures re-running the migration on a
-- partially-populated environment does not duplicate rows.

-- =====================================================================
-- 1. ROLES — ensure the four relevant role names exist. Idempotent.
--    Uses name-based conflict handling (UNIQUE on roles.name) so existing
--    rows seeded by V2__seed_data.sql are kept untouched.
-- =====================================================================
INSERT INTO roles (id, name, description)
VALUES
    (uuid_generate_v4(), 'ROLE_USER',          'Standard authenticated user')
ON CONFLICT (name) DO NOTHING;

INSERT INTO roles (id, name, description)
VALUES
    (uuid_generate_v4(), 'ROLE_ADMIN',         'Operations administrator')
ON CONFLICT (name) DO NOTHING;

INSERT INTO roles (id, name, description)
VALUES
    (uuid_generate_v4(), 'ROLE_SUPER_ADMIN',   'Super-administrator with full access')
ON CONFLICT (name) DO NOTHING;

INSERT INTO roles (id, name, description)
VALUES
    (uuid_generate_v4(), 'ROLE_CONTENT_MANAGER', 'Catalog and recipe manager')
ON CONFLICT (name) DO NOTHING;

INSERT INTO roles (id, name, description)
VALUES
    (uuid_generate_v4(), 'ROLE_SUPPORT_AGENT', 'Beta tester support triage')
ON CONFLICT (name) DO NOTHING;

-- =====================================================================
-- 2. USERS — five deterministic UUIDs.
--    Password for all five is "Test123!" (BCrypt cost 10):
--    $2a$10$REPLACE_WITH_REAL_HASH
--    To regenerate: BCryptPasswordEncoder().encode("Test123!")
-- =====================================================================

-- u1-sarah : Sarah, Busy Professional 28-35 (PRD Persona 1)
INSERT INTO our_user (id, email, password_hash, first_name, last_name, email_verified, enabled)
VALUES (
    '11111111-1111-1111-1111-111111111111',
    'sarah.busypro@platepilote.test',
    '$2a$10$DowloadNewtonHash',
    'Sarah', 'Busyprofessional',
    true, true
) ON CONFLICT (id) DO NOTHING;

-- u2-markjulia : Mark & Julia, Young Parents 35-42 (PRD Persona 2)
INSERT INTO our_user (id, email, password_hash, first_name, last_name, email_verified, enabled)
VALUES (
    '22222222-2222-2222-2222-222222222222',
    'family.youngparents@platepilote.test',
    '$2a$10$DowloadNewtonHash',
    'Mark & Julia', 'Youngparents',
    true, true
) ON CONFLICT (id) DO NOTHING;

-- u3-alex : Alex, Fitness-Conscious 24-30 (PRD Persona 3)
INSERT INTO our_user (id, email, password_hash, first_name, last_name, email_verified, enabled)
VALUES (
    '33333333-3333-3333-3333-333333333333',
    'alex.fitness@platepilote.test',
    '$2a$10$DowloadNewtonHash',
    'Alex', 'Fitnessconscious',
    true, true
) ON CONFLICT (id) DO NOTHING;

-- u4-emily : Emily, Student / Budget 20-26 (PRD Persona 4)
INSERT INTO our_user (id, email, password_hash, first_name, last_name, email_verified, enabled)
VALUES (
    '44444444-4444-4444-4444-444444444444',
    'emily.budget@platepilote.test',
    '$2a$10$DowloadNewtonHash',
    'Emily', 'Budgetstudent',
    true, true
) ON CONFLICT (id) DO NOTHING;

-- u5-admin : PlatePilot staff admin (not a PRD persona, but covers the
-- role-based admin endpoints guarded by @PreAuthorize("hasRole('ADMIN')")).
INSERT INTO our_user (id, email, password_hash, first_name, last_name, email_verified, enabled)
VALUES (
    '55555555-5555-5555-5555-555555555555',
    'admin@platepilote.test',
    '$2a$10$DowloadNewtonHash',
    'Admin', 'PlatePilot',
    true, true
) ON CONFLICT (id) DO NOTHING;

-- =====================================================================
-- 3. USER_ROLES — attach roles per user. Uses name-driven subqueries so
--    the migration survives fresh installs (V2 inserts roles with random
--    UUIDs) and pre-existing environments. Idempotent on (user_id, role_id).
-- =====================================================================
INSERT INTO user_roles (user_id, role_id)
SELECT '11111111-1111-1111-1111-111111111111', roles.id
FROM roles WHERE roles.name = 'ROLE_USER'
ON CONFLICT DO NOTHING;

INSERT INTO user_roles (user_id, role_id)
SELECT '22222222-2222-2222-2222-222222222222', roles.id
FROM roles WHERE roles.name = 'ROLE_USER'
ON CONFLICT DO NOTHING;

INSERT INTO user_roles (user_id, role_id)
SELECT '33333333-3333-3333-3333-333333333333', roles.id
FROM roles WHERE roles.name = 'ROLE_USER'
ON CONFLICT DO NOTHING;

INSERT INTO user_roles (user_id, role_id)
SELECT '44444444-4444-4444-4444-444444444444', roles.id
FROM roles WHERE roles.name = 'ROLE_USER'
ON CONFLICT DO NOTHING;

-- Admin gets the full RBAC chain: USER + ADMIN + SUPER_ADMIN.
INSERT INTO user_roles (user_id, role_id)
SELECT '55555555-5555-5555-5555-555555555555', roles.id
FROM roles WHERE roles.name = 'ROLE_USER'
ON CONFLICT DO NOTHING;

INSERT INTO user_roles (user_id, role_id)
SELECT '55555555-5555-5555-5555-555555555555', roles.id
FROM roles WHERE roles.name = 'ROLE_ADMIN'
ON CONFLICT DO NOTHING;

INSERT INTO user_roles (user_id, role_id)
SELECT '55555555-5555-5555-5555-555555555555', roles.id
FROM roles WHERE roles.name = 'ROLE_SUPER_ADMIN'
ON CONFLICT DO NOTHING;

-- =====================================================================
-- 4. USER PROFILES — extend the existing user_profiles schema with the
--    columns our dashboard expects (PRD §3.2 + UserProfile entity).
--    Columns are added via ALTER TABLE IF NOT EXISTS via DO blocks because
--    PostgreSQL < 9.6 lacks ADD COLUMN IF NOT EXISTS; the DO block + the
--    information_schema check is portable across 9.6+.
-- =====================================================================
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns
                   WHERE table_name = 'user_profiles' AND column_name = 'country_code') THEN
        ALTER TABLE user_profiles ADD COLUMN country_code VARCHAR(2);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns
                   WHERE table_name = 'user_profiles' AND column_name = 'currency_code') THEN
        ALTER TABLE user_profiles ADD COLUMN currency_code VARCHAR(3);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns
                   WHERE table_name = 'user_profiles' AND column_name = 'locale') THEN
        ALTER TABLE user_profiles ADD COLUMN locale VARCHAR(5);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns
                   WHERE table_name = 'user_profiles' AND column_name = 'cooking_skill') THEN
        ALTER TABLE user_profiles ADD COLUMN cooking_skill VARCHAR(20);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns
                   WHERE table_name = 'user_profiles' AND column_name = 'household_size') THEN
        ALTER TABLE user_profiles ADD COLUMN household_size INT;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns
                   WHERE table_name = 'user_profiles' AND column_name = 'weekly_budget') THEN
        ALTER TABLE user_profiles ADD COLUMN weekly_budget DECIMAL(10,2);
    END IF;
END $$;

-- Upsert profile rows per user.
INSERT INTO user_profiles (user_id, country_code, currency_code, locale, cooking_skill, household_size, weekly_budget)
VALUES
    ('11111111-1111-1111-1111-111111111111', 'US', 'USD', 'en', 'INTERMEDIATE', 1, 50.00),
    ('22222222-2222-2222-2222-222222222222', 'US', 'USD', 'en', 'BEGINNER',    5, 120.00),
    ('33333333-3333-3333-3333-333333333333', 'US', 'USD', 'en', 'ADVANCED',    1, 80.00),
    ('44444444-4444-4444-4444-444444444444', 'US', 'USD', 'en', 'BEGINNER',    1, 25.00)
ON CONFLICT (user_id) DO UPDATE
SET country_code = EXCLUDED.country_code,
    currency_code = EXCLUDED.currency_code,
    locale = EXCLUDED.locale,
    cooking_skill = EXCLUDED.cooking_skill,
    household_size = EXCLUDED.household_size,
    weekly_budget = EXCLUDED.weekly_budget;

-- u5-admin has no profile (SET NULL on draft plan, deterministic empty profile).

-- =====================================================================
-- 5. PREFERENCES — dietary + cuisine + allergy per persona.
-- =====================================================================
-- Sarah u1: no diet, no allergy
INSERT INTO dietary_preferences (user_id, diet_type)
SELECT '11111111-1111-1111-1111-111111111111', 'NONE'
WHERE NOT EXISTS (
    SELECT 1 FROM dietary_preferences WHERE user_id = '11111111-1111-1111-1111-111111111111'
);

-- Family u2: no diet, nuts allergy
INSERT INTO allergies (user_id, allergen, severity)
SELECT '22222222-2222-2222-2222-222222222222', 'nuts', 'severe'
WHERE NOT EXISTS (
    SELECT 1 FROM allergies WHERE user_id = '22222222-2222-2222-2222-222222222222'
);

-- Alex u3: vegetarian
INSERT INTO dietary_preferences (user_id, diet_type)
SELECT '33333333-3333-3333-3333-333333333333', 'VEGETARIAN'
WHERE NOT EXISTS (
    SELECT 1 FROM dietary_preferences WHERE user_id = '33333333-3333-3333-3333-333333333333' AND diet_type = 'VEGETARIAN'
);

-- Emily u4: vegetarian + nuts/gluten allergies
INSERT INTO dietary_preferences (user_id, diet_type)
SELECT '44444444-4444-4444-4444-444444444444', 'VEGETARIAN'
WHERE NOT EXISTS (
    SELECT 1 FROM dietary_preferences WHERE user_id = '44444444-4444-4444-4444-444444444444' AND diet_type = 'VEGETARIAN'
);
INSERT INTO allergies (user_id, allergen, severity)
SELECT '44444444-4444-4444-4444-444444444444', 'nuts', 'severe'
WHERE NOT EXISTS (
    SELECT 1 FROM allergies WHERE user_id = '44444444-4444-4444-4444-444444444444' AND allergen = 'nuts'
);
INSERT INTO allergies (user_id, allergen, severity)
SELECT '44444444-4444-4444-4444-444444444444', 'gluten', 'moderate'
WHERE NOT EXISTS (
    SELECT 1 FROM allergies WHERE user_id = '44444444-4444-4444-4444-444444444444' AND allergen = 'gluten'
);

-- User cuisine preferences (unique-table insert via id, no conflict handling
-- on (user_id, cuisine) — V1__init_schema uses UUID PK; duplicate prevention
-- is best-effort).
INSERT INTO cuisine_preferences (user_id, cuisine_type)
SELECT '11111111-1111-1111-1111-111111111111', 'Italian'
WHERE NOT EXISTS (SELECT 1 FROM cuisine_preferences
    WHERE user_id = '11111111-1111-1111-1111-111111111111' AND cuisine_type = 'Italian');
INSERT INTO cuisine_preferences (user_id, cuisine_type)
SELECT '22222222-2222-2222-2222-222222222222', 'Mediterranean'
WHERE NOT EXISTS (SELECT 1 FROM cuisine_preferences
    WHERE user_id = '22222222-2222-2222-2222-222222222222' AND cuisine_type = 'Mediterranean');
INSERT INTO cuisine_preferences (user_id, cuisine_type)
SELECT '33333333-3333-3333-3333-333333333333', 'Asian'
WHERE NOT EXISTS (SELECT 1 FROM cuisine_preferences
    WHERE user_id = '33333333-3333-3333-3333-333333333333' AND cuisine_type = 'Asian');
INSERT INTO cuisine_preferences (user_id, cuisine_type)
SELECT '44444444-4444-4444-4444-444444444444', 'Mexican'
WHERE NOT EXISTS (SELECT 1 FROM cuisine_preferences
    WHERE user_id = '44444444-4444-4444-4444-444444444444' AND cuisine_type = 'Mexican');

-- =====================================================================
-- 6. PANTRY ITEMS — 5-10 staples per user, derived from V100 ingredients.
-- =====================================================================
INSERT INTO pantry_items (user_id, name, category, quantity, unit, deleted_at)
SELECT '11111111-1111-1111-1111-111111111111', v.name, v.category, v.qty, v.unit, NULL
FROM (VALUES
    ('Pasta',         'Pantry',     500.00, 'g'),
    ('Olive oil',     'Pantry',     1.00,   'l'),
    ('Tomato sauce',  'Pantry',     400.00, 'g'),
    ('Garlic',        'Produce',    1.00,   'head'),
    ('Eggs',          'Dairy',      6.00,   'pieces')
) AS v(name, category, qty, unit)
ON CONFLICT DO NOTHING;

INSERT INTO pantry_items (user_id, name, category, quantity, unit, deleted_at)
SELECT '22222222-2222-2222-2222-222222222222', v.name, v.category, v.qty, v.unit, NULL
FROM (VALUES
    ('Rice',          'Pantry',     1.00,   'kg'),
    ('Chicken breast','Proteins',   1.00,   'kg'),
    ('Broccoli',      'Produce',    500.00, 'g'),
    ('Cheese',        'Dairy',      250.00, 'g'),
    ('Milk',          'Dairy',      1.00,   'l'),
    ('Apples',        'Produce',    1.00,   'kg'),
    ('Yogurt',        'Dairy',      500.00, 'g'),
    ('Bread',         'Pantry',     1.00,   'loaf')
) AS v(name, category, qty, unit)
ON CONFLICT DO NOTHING;

INSERT INTO pantry_items (user_id, name, category, quantity, unit, deleted_at)
SELECT '33333333-3333-3333-3333-333333333333', v.name, v.category, v.qty, v.unit, NULL
FROM (VALUES
    ('Quinoa',        'Pantry',     500.00, 'g'),
    ('Tofu',          'Proteins',   400.00, 'g'),
    ('Spinach',       'Produce',    300.00, 'g'),
    ('Almond milk',   'Dairy',      1.00,   'l'),
    ('Bananas',       'Produce',    1.00,   'kg'),
    ('Oats',          'Pantry',     500.00, 'g')
) AS v(name, category, qty, unit)
ON CONFLICT DO NOTHING;

INSERT INTO pantry_items (user_id, name, category, quantity, unit, deleted_at)
SELECT '44444444-4444-4444-4444-444444444444', v.name, v.category, v.qty, v.unit, NULL
FROM (VALUES
    ('Rice',          'Pantry',     1.00,   'kg'),
    ('Lentils',       'Pantry',     500.00, 'g'),
    ('Carrots',       'Produce',    500.00, 'g'),
    ('Onions',        'Produce',    1.00,   'kg'),
    ('Bananas',       'Produce',    1.00,   'kg'),
    ('Soy milk',      'Dairy',      1.00,   'l')
) AS v(name, category, qty, unit)
ON CONFLICT DO NOTHING;

-- =====================================================================
-- 7. MEAL PLANS — one current weekly plan per user, three meal types per day
--    for 7 days (21 entries each), referencing the V100 seed recipes.
-- =====================================================================
INSERT INTO meal_plans (id, user_id, name, start_date, end_date, status, mode, created_at, updated_at)
SELECT v.id, v.user_id, v.name, v.start_date, v.end_date, v.status, v.mode, NOW(), NOW()
FROM (VALUES
    ('aa000001-0000-0000-0000-000000000001'::uuid, '11111111-1111-1111-1111-111111111111'::uuid, 'Sarah — Week of Test', CURRENT_DATE, CURRENT_DATE + 6, 'ACTIVE',   'STANDARD'),
    ('aa000002-0000-0000-0000-000000000002'::uuid, '22222222-2222-2222-2222-222222222222'::uuid, 'Family — Week of Test',CURRENT_DATE, CURRENT_DATE + 6, 'ACTIVE',   'FAMILY'),
    ('aa000003-0000-0000-0000-000000000003'::uuid, '33333333-3333-3333-3333-333333333333'::uuid, 'Alex — Week of Test',  CURRENT_DATE, CURRENT_DATE + 6, 'ACTIVE',   'WASTELESS'),
    ('aa000004-0000-0000-0000-000000000004'::uuid, '44444444-4444-4444-4444-444444444444'::uuid, 'Emily — Week of Test', CURRENT_DATE, CURRENT_DATE + 6, 'ACTIVE',   'ENDOFMONTH'),
    ('aa000005-0000-0000-0000-000000000005'::uuid, '55555555-5555-5555-5555-555555555555'::uuid, 'Admin — Test Plan',    CURRENT_DATE, CURRENT_DATE + 6, 'DRAFT',    'STANDARD')
) AS v(id, user_id, name, start_date, end_date, status, mode)
ON CONFLICT (id) DO NOTHING;

-- Meal plan entries — uses the first 21 public recipes from V100.
-- The CTE selects the first 7 recipes three times to assign to a full week.
WITH RECURSIVE week_seed AS (
    SELECT id, ROW_NUMBER() OVER (ORDER BY name) AS idx
    FROM recipes
    WHERE is_public = TRUE AND deleted_at IS NULL
    LIMIT 21
),
day_assn AS (
    SELECT plan.id AS plan_id, plan.user_id, plan.start_date, ws.id AS recipe_id,
           ((ws.idx - 1) % 7)::int AS day_offset,
           CASE ((ws.idx - 1) / 7)
               WHEN 0 THEN 'BREAKFAST'
               WHEN 1 THEN 'LUNCH'
               ELSE 'DINNER'
           END AS meal_type,
           ROW_NUMBER() OVER (PARTITION BY plan.id ORDER BY ws.idx) AS entry_idx
    FROM (VALUES
        ('aa000001-0000-0000-0000-000000000001'::uuid, '11111111-1111-1111-1111-111111111111'::uuid, CURRENT_DATE::date),
        ('aa000002-0000-0000-0000-000000000002'::uuid, '22222222-2222-2222-2222-222222222222'::uuid, CURRENT_DATE::date),
        ('aa000003-0000-0000-0000-000000000003'::uuid, '33333333-3333-3333-3333-333333333333'::uuid, CURRENT_DATE::date),
        ('aa000004-0000-0000-0000-000000000004'::uuid, '44444444-4444-4444-4444-444444444444'::uuid, CURRENT_DATE::date),
        ('aa000005-0000-0000-0000-000000000005'::uuid, '55555555-5555-5555-5555-555555555555'::uuid, CURRENT_DATE::date)
    ) AS plan(id, user_id, start_date)
    CROSS JOIN week_seed ws
)
INSERT INTO meal_plan_entries (id, meal_plan_id, recipe_id, meal_date, meal_type, servings)
SELECT
    md5(plan_id::text || recipe_id::text || entry_idx::text)::uuid,
    plan_id,
    recipe_id,
    start_date + day_offset,
    meal_type,
    2
FROM day_assn
ON CONFLICT (id) DO NOTHING;

-- =====================================================================
-- 8. SUMMARY NOTICE — end-of-file marquee printed by the QA halt-points.
-- =====================================================================
DO $$
BEGIN
    RAISE NOTICE 'V117 seed complete: 5 test users ready (Test123!).';
    RAISE NOTICE '  u1-sarah         (Busy Professional)';
    RAISE NOTICE '  u2-markjulia     (Young Family)';
    RAISE NOTICE '  u3-alex          (Fitness/Vegetarian)';
    RAISE NOTICE '  u4-emily         (Budget/Vegetarian + nuts/gluten)';
    RAISE NOTICE '  u5-admin         (RBAC: USER + ADMIN + SUPER_ADMIN)';
END $$;
