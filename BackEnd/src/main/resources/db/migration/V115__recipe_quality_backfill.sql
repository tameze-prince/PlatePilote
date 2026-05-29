-- Backfill recipe quality/confidence score based on data completeness
-- Higher score = more reliable for recommendations and surfaces

UPDATE recipes SET confidence_score = ROUND((
    CASE WHEN image_url IS NOT NULL AND image_url != '' THEN 0.20 ELSE 0 END +
    CASE WHEN calories_per_serving IS NOT NULL THEN 0.15 ELSE 0 END +
    CASE WHEN total_time_minutes IS NOT NULL THEN 0.10 ELSE 0 END +
    CASE WHEN difficulty IS NOT NULL THEN 0.05 ELSE 0 END +
    CASE WHEN cuisine_type IS NOT NULL THEN 0.05 ELSE 0 END +
    CASE WHEN meal_type IS NOT NULL THEN 0.05 ELSE 0 END +
    CASE WHEN prep_time_minutes IS NOT NULL AND cook_time_minutes IS NOT NULL THEN 0.05 ELSE 0 END +
    CASE WHEN EXISTS (SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id = id) THEN 0.15 ELSE 0 END +
    CASE WHEN EXISTS (SELECT 1 FROM recipe_steps rs WHERE rs.recipe_id = id) THEN 0.10 ELSE 0 END +
    CASE WHEN enabled = true THEN 0.05 ELSE 0 END +
    CASE WHEN verified = true THEN 0.05 ELSE 0 END
), 2) WHERE confidence_score IS NULL OR confidence_score < 0.1;
