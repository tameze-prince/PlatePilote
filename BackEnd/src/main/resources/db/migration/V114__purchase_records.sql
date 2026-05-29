-- Persist actual purchase history from grocery checkouts
-- Enables spend analytics, price learning, and reorder suggestions

CREATE TABLE IF NOT EXISTS purchase_records (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES our_user(id),
    grocery_list_id UUID REFERENCES grocery_lists(id),
    item_name VARCHAR(255) NOT NULL,
    category VARCHAR(100),
    quantity NUMERIC(10,3),
    unit VARCHAR(50),
    unit_price NUMERIC(10,2),       -- price per unit at purchase time
    total_price NUMERIC(10,2) NOT NULL,
    ingredient_id UUID REFERENCES ingredients(id),
    purchased_at TIMESTAMP NOT NULL DEFAULT NOW(),
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMP
);

CREATE INDEX idx_purchase_records_user_date ON purchase_records(user_id, purchased_at DESC) WHERE deleted_at IS NULL;
CREATE INDEX idx_purchase_records_ingredient ON purchase_records(ingredient_id) WHERE ingredient_id IS NOT NULL AND deleted_at IS NULL;
