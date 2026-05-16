-- V3__food_intelligence.sql
-- Add food intelligence database tables and extend recipes

-- ============================================
-- INGREDIENTS CATALOG
-- ============================================
CREATE TABLE IF NOT EXISTS ingredients (
    id UUID PRIMARY KEY,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMP,
    canonical_name VARCHAR(255) NOT NULL UNIQUE,
    slug VARCHAR(255) NOT NULL UNIQUE,
    category VARCHAR(255) NOT NULL,
    description TEXT,
    default_unit VARCHAR(50) NOT NULL,
    calories_per_100g DOUBLE PRECISION,
    protein_per_100g DOUBLE PRECISION,
    carbohydrates_per_100g DOUBLE PRECISION,
    fat_per_100g DOUBLE PRECISION,
    fiber_per_100g DOUBLE PRECISION,
    sugar_per_100g DOUBLE PRECISION,
    sodium_mg_per_100g DOUBLE PRECISION,
    cholesterol_mg_per_100g DOUBLE PRECISION,
    contains_gluten BOOLEAN DEFAULT FALSE,
    contains_lactose BOOLEAN DEFAULT FALSE,
    contains_nuts BOOLEAN DEFAULT FALSE,
    contains_soy BOOLEAN DEFAULT FALSE,
    contains_eggs BOOLEAN DEFAULT FALSE,
    contains_fish BOOLEAN DEFAULT FALSE,
    contains_shellfish BOOLEAN DEFAULT FALSE,
    vegan BOOLEAN DEFAULT FALSE,
    vegetarian BOOLEAN DEFAULT FALSE,
    halal_friendly BOOLEAN DEFAULT FALSE,
    kosher_friendly BOOLEAN DEFAULT FALSE,
    low_carb BOOLEAN DEFAULT FALSE,
    keto_friendly BOOLEAN DEFAULT FALSE,
    average_price_per_kg DECIMAL(10,2),
    usda_fdc_id VARCHAR(100),
    open_food_facts_code VARCHAR(100),
    source_name VARCHAR(255),
    source_url VARCHAR(500)
);

-- ============================================
-- INGREDIENT ALIASES
-- ============================================
CREATE TABLE IF NOT EXISTS ingredient_aliases (
    id UUID PRIMARY KEY,
    alias VARCHAR(255) NOT NULL,
    normalized_alias VARCHAR(255) NOT NULL,
    ingredient_id UUID NOT NULL REFERENCES ingredients(id),
    UNIQUE(alias, ingredient_id)
);

CREATE INDEX idx_ingredient_aliases_normalized ON ingredient_aliases(normalized_alias);
CREATE INDEX idx_ingredient_aliases_ingredient ON ingredient_aliases(ingredient_id);

-- ============================================
-- INGREDIENT PRICES
-- ============================================
CREATE TABLE IF NOT EXISTS ingredient_prices (
    id UUID PRIMARY KEY,
    ingredient_id UUID NOT NULL REFERENCES ingredients(id),
    country_code VARCHAR(2),
    currency_code VARCHAR(3) NOT NULL,
    average_price_per_unit DECIMAL(10,2) NOT NULL,
    unit VARCHAR(50) NOT NULL,
    source VARCHAR(255) NOT NULL,
    effective_date DATE NOT NULL
);

CREATE INDEX idx_ingredient_prices_ingredient ON ingredient_prices(ingredient_id);
CREATE INDEX idx_ingredient_prices_date ON ingredient_prices(effective_date);

-- ============================================
-- BARCODE PRODUCT MAPPING
-- ============================================
CREATE TABLE IF NOT EXISTS barcode_products (
    id UUID PRIMARY KEY,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMP,
    barcode VARCHAR(50) NOT NULL UNIQUE,
    product_name VARCHAR(255) NOT NULL,
    brand VARCHAR(255),
    ingredient_id UUID REFERENCES ingredients(id),
    open_food_facts_code VARCHAR(100)
);

CREATE INDEX idx_barcode_products_barcode ON barcode_products(barcode);

-- ============================================
-- IMPORT JOBS
-- ============================================
CREATE TABLE IF NOT EXISTS import_jobs (
    id UUID PRIMARY KEY,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMP,
    source VARCHAR(255) NOT NULL,
    status VARCHAR(50) NOT NULL,
    total_records INT DEFAULT 0,
    successful_records INT DEFAULT 0,
    failed_records INT DEFAULT 0,
    error_message TEXT,
    started_at TIMESTAMP,
    completed_at TIMESTAMP
);

-- ============================================
-- EXTEND RECIPES TABLE
-- ============================================
ALTER TABLE recipes ADD COLUMN IF NOT EXISTS calories_per_serving INT;
ALTER TABLE recipes ADD COLUMN IF NOT EXISTS protein_per_serving DOUBLE PRECISION;
ALTER TABLE recipes ADD COLUMN IF NOT EXISTS carbs_per_serving DOUBLE PRECISION;
ALTER TABLE recipes ADD COLUMN IF NOT EXISTS fat_per_serving DOUBLE PRECISION;
ALTER TABLE recipes ADD COLUMN IF NOT EXISTS fiber_per_serving DOUBLE PRECISION;
ALTER TABLE recipes ADD COLUMN IF NOT EXISTS contains_gluten BOOLEAN DEFAULT FALSE;
ALTER TABLE recipes ADD COLUMN IF NOT EXISTS contains_lactose BOOLEAN DEFAULT FALSE;
ALTER TABLE recipes ADD COLUMN IF NOT EXISTS contains_nuts BOOLEAN DEFAULT FALSE;
ALTER TABLE recipes ADD COLUMN IF NOT EXISTS contains_soy BOOLEAN DEFAULT FALSE;
ALTER TABLE recipes ADD COLUMN IF NOT EXISTS contains_eggs BOOLEAN DEFAULT FALSE;
ALTER TABLE recipes ADD COLUMN IF NOT EXISTS contains_fish BOOLEAN DEFAULT FALSE;
ALTER TABLE recipes ADD COLUMN IF NOT EXISTS contains_shellfish BOOLEAN DEFAULT FALSE;
ALTER TABLE recipes ADD COLUMN IF NOT EXISTS vegan BOOLEAN DEFAULT FALSE;
ALTER TABLE recipes ADD COLUMN IF NOT EXISTS vegetarian BOOLEAN DEFAULT FALSE;
ALTER TABLE recipes ADD COLUMN IF NOT EXISTS halal_friendly BOOLEAN DEFAULT FALSE;
ALTER TABLE recipes ADD COLUMN IF NOT EXISTS kosher_friendly BOOLEAN DEFAULT FALSE;
ALTER TABLE recipes ADD COLUMN IF NOT EXISTS low_carb BOOLEAN DEFAULT FALSE;
ALTER TABLE recipes ADD COLUMN IF NOT EXISTS keto_friendly BOOLEAN DEFAULT FALSE;
ALTER TABLE recipes ADD COLUMN IF NOT EXISTS estimated_cost DECIMAL(10,2);
ALTER TABLE recipes ADD COLUMN IF NOT EXISTS source_url VARCHAR(500);
