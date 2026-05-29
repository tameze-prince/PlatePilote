-- Workflow performance indexes: home -> plan -> grocery -> checkout.

CREATE INDEX IF NOT EXISTS idx_meal_plans_user_status_recent
ON meal_plans(user_id, status, deleted_at, start_date DESC);

CREATE INDEX IF NOT EXISTS idx_meal_plan_entries_plan_date_type
ON meal_plan_entries(meal_plan_id, meal_date, meal_type);

CREATE INDEX IF NOT EXISTS idx_grocery_lists_user_status_recent
ON grocery_lists(user_id, status, deleted_at, updated_at DESC);

CREATE INDEX IF NOT EXISTS idx_grocery_items_list_checked_sort
ON grocery_items(grocery_list_id, checked, sort_order);

CREATE INDEX IF NOT EXISTS idx_ingredient_prices_latest
ON ingredient_prices(ingredient_id, country_code, effective_date DESC);

CREATE INDEX IF NOT EXISTS idx_dietary_preferences_user
ON dietary_preferences(user_id) WHERE deleted_at IS NULL;

CREATE INDEX IF NOT EXISTS idx_allergies_user
ON allergies(user_id) WHERE deleted_at IS NULL;

CREATE INDEX IF NOT EXISTS idx_cuisine_preferences_user
ON cuisine_preferences(user_id) WHERE deleted_at IS NULL;

CREATE INDEX IF NOT EXISTS idx_subscriptions_user
ON subscriptions(user_id);

CREATE INDEX IF NOT EXISTS idx_recipes_recommendation_pool
ON recipes(total_time_minutes, estimated_cost, cuisine_type, meal_type)
WHERE is_public = TRUE AND deleted_at IS NULL AND enabled = TRUE;

CREATE INDEX IF NOT EXISTS idx_recipes_dashboard_quality
ON recipes(verified DESC, confidence_score DESC, updated_at DESC)
WHERE is_public = TRUE AND deleted_at IS NULL AND enabled = TRUE AND image_url IS NOT NULL;
