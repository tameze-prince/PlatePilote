ALTER TABLE grocery_lists
ADD COLUMN IF NOT EXISTS meal_plan_id UUID REFERENCES meal_plans(id);

CREATE INDEX IF NOT EXISTS idx_grocery_lists_plan_active
ON grocery_lists(user_id, meal_plan_id, status)
WHERE deleted_at IS NULL;
