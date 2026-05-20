-- Increase all currency_code columns to VARCHAR(4) to support codes like FCFA
ALTER TABLE user_profiles ALTER COLUMN currency_code TYPE VARCHAR(4);
ALTER TABLE recommendation_events ALTER COLUMN currency_code TYPE VARCHAR(4);
ALTER TABLE ingredient_prices ALTER COLUMN currency_code TYPE VARCHAR(4);
