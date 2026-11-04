-- V122__derive_recipe_allergens_from_canonical_ingredient_ids.sql
-- V101 introduced recipe_ingredients.ingredient_id and backfilled it from canonical
-- names/aliases. Use that FK as the source of truth; notes are free-form text.

WITH recipe_allergen_rollup AS (
    SELECT
        ri.recipe_id,
        COUNT(*) AS ingredient_count,
        COUNT(i.id) AS matched_ingredient_count,
        COUNT(i.contains_gluten) AS gluten_known_count,
        BOOL_OR(i.contains_gluten) AS contains_gluten,
        COUNT(i.contains_lactose) AS lactose_known_count,
        BOOL_OR(i.contains_lactose) AS contains_lactose,
        COUNT(i.contains_nuts) AS nuts_known_count,
        BOOL_OR(i.contains_nuts) AS contains_nuts,
        COUNT(i.contains_soy) AS soy_known_count,
        BOOL_OR(i.contains_soy) AS contains_soy,
        COUNT(i.contains_eggs) AS eggs_known_count,
        BOOL_OR(i.contains_eggs) AS contains_eggs,
        COUNT(i.contains_fish) AS fish_known_count,
        BOOL_OR(i.contains_fish) AS contains_fish,
        COUNT(i.contains_shellfish) AS shellfish_known_count,
        BOOL_OR(i.contains_shellfish) AS contains_shellfish
    FROM recipe_ingredients ri
    LEFT JOIN ingredients i ON i.id = ri.ingredient_id
    GROUP BY ri.recipe_id
)
UPDATE recipes r
SET
    contains_gluten = CASE
        WHEN a.ingredient_count > 0
         AND a.matched_ingredient_count = a.ingredient_count
         AND a.gluten_known_count = a.ingredient_count
        THEN a.contains_gluten ELSE NULL END,
    contains_lactose = CASE
        WHEN a.ingredient_count > 0
         AND a.matched_ingredient_count = a.ingredient_count
         AND a.lactose_known_count = a.ingredient_count
        THEN a.contains_lactose ELSE NULL END,
    contains_nuts = CASE
        WHEN a.ingredient_count > 0
         AND a.matched_ingredient_count = a.ingredient_count
         AND a.nuts_known_count = a.ingredient_count
        THEN a.contains_nuts ELSE NULL END,
    contains_soy = CASE
        WHEN a.ingredient_count > 0
         AND a.matched_ingredient_count = a.ingredient_count
         AND a.soy_known_count = a.ingredient_count
        THEN a.contains_soy ELSE NULL END,
    contains_eggs = CASE
        WHEN a.ingredient_count > 0
         AND a.matched_ingredient_count = a.ingredient_count
         AND a.eggs_known_count = a.ingredient_count
        THEN a.contains_eggs ELSE NULL END,
    contains_fish = CASE
        WHEN a.ingredient_count > 0
         AND a.matched_ingredient_count = a.ingredient_count
         AND a.fish_known_count = a.ingredient_count
        THEN a.contains_fish ELSE NULL END,
    contains_shellfish = CASE
        WHEN a.ingredient_count > 0
         AND a.matched_ingredient_count = a.ingredient_count
         AND a.shellfish_known_count = a.ingredient_count
        THEN a.contains_shellfish ELSE NULL END,
    allergen_source = CASE
        WHEN a.matched_ingredient_count = a.ingredient_count
        THEN 'Canonical ingredient metadata; automated; verify labels'
        ELSE 'Incomplete canonical ingredient mapping; unknown'
    END,
    verified = FALSE,
    verification_status = 'UNREVIEWED',
    confidence_score = LEAST(confidence_score, 0.500)
FROM recipe_allergen_rollup a
WHERE r.id = a.recipe_id;

UPDATE recipes r
SET
    contains_gluten = NULL,
    contains_lactose = NULL,
    contains_nuts = NULL,
    contains_soy = NULL,
    contains_eggs = NULL,
    contains_fish = NULL,
    contains_shellfish = NULL,
    allergen_source = 'No ingredient data; unknown',
    verified = FALSE,
    verification_status = 'UNREVIEWED',
    confidence_score = LEAST(confidence_score, 0.500)
WHERE NOT EXISTS (
    SELECT 1 FROM recipe_ingredients ri WHERE ri.recipe_id = r.id
);
