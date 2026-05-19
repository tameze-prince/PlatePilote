-- V105__grocery_canonical_ingredients.sql
-- Preserve canonical ingredient identity on generated grocery list items.

ALTER TABLE grocery_items ADD COLUMN IF NOT EXISTS ingredient_id UUID REFERENCES ingredients(id);
CREATE INDEX IF NOT EXISTS idx_grocery_items_ingredient ON grocery_items(ingredient_id);
