-- PERFORMANCE INDEXES
-- ====================
-- Critical indexes for the most frequent query patterns.
-- These reduce full table scans to index lookups.

-- Recipe ingredients: fetched for every recipe detail + allergen check + grocery generation
CREATE INDEX IF NOT EXISTS idx_ri_recipe_id ON recipe_ingredients(recipe_id);

-- Meal plan entries: fetched for every meal plan detail view
CREATE INDEX IF NOT EXISTS idx_mpe_plan_id ON meal_plan_entries(meal_plan_id);

-- Grocery items: fetched for every grocery list view
CREATE INDEX IF NOT EXISTS idx_gi_list_id ON grocery_items(grocery_list_id);

-- Pantry: filtered by user + ingredient for grocery pantry subtraction
CREATE INDEX IF NOT EXISTS idx_pantry_user_ingredient ON pantry_items(user_id, ingredient_id) WHERE deleted_at IS NULL;

-- Pantry: filtered by user + expiration for expiring items query
CREATE INDEX IF NOT EXISTS idx_pantry_user_expiring ON pantry_items(user_id, expiration_date) WHERE deleted_at IS NULL AND expiration_date IS NOT NULL;

-- Recipes: filtered by public + not deleted for browsing + recommendations
CREATE INDEX IF NOT EXISTS idx_recipe_public_active ON recipes(is_public, deleted_at);

-- Recipes: filtered by user + not deleted for "my recipes"
CREATE INDEX IF NOT EXISTS idx_recipe_user_active ON recipes(user_id, deleted_at);

-- Budgets: filtered by user + not deleted
CREATE INDEX IF NOT EXISTS idx_budget_user_active ON budgets(user_id, deleted_at);

-- Notifications: filtered by user + read status + not deleted
CREATE INDEX IF NOT EXISTS idx_notification_user_read ON notifications(user_id, is_read, deleted_at);

-- Grocery lists: filtered by user + not deleted
CREATE INDEX IF NOT EXISTS idx_grocery_list_user ON grocery_lists(user_id, deleted_at);

-- Meal plans: filtered by user + not deleted
CREATE INDEX IF NOT EXISTS idx_meal_plan_user ON meal_plans(user_id, deleted_at);

-- Refresh tokens: hashed token lookup during authentication
CREATE INDEX IF NOT EXISTS idx_refresh_token_hash ON refresh_tokens(token_hash);

-- User interactions: filtered by user + date for recommendation feedback
CREATE INDEX IF NOT EXISTS idx_user_interaction_user_date ON user_interactions(user_id, created_at);

-- Recommendation events: filtered by user + date for quota enforcement
CREATE INDEX IF NOT EXISTS idx_rec_event_user_date ON recommendation_events(user_id, created_at) WHERE quota_limited = false;
