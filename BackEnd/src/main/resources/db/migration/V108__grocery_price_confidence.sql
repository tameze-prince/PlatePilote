-- V108__grocery_price_confidence.sql
-- Track confidence for generated local grocery price estimates.

ALTER TABLE grocery_items ADD COLUMN IF NOT EXISTS price_confidence DECIMAL(4,3);
