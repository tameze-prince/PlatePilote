import csv
import re
import uuid
from pathlib import Path

BASE_DIR = Path(__file__).parent
RECIPES_CSV = BASE_DIR / "recipes.csv"
INGREDIENTS_CSV = BASE_DIR / "ingredients.csv"
RECIPE_INGREDIENTS_CSV = BASE_DIR / "recipe_ingredients.csv"
NUTRITION_CSV = BASE_DIR / "nutrition.csv"
MIGRATION_DIR = BASE_DIR / ".." / "BackEnd" / "src" / "main" / "resources" / "db" / "migration"
MAPPING_CSV = BASE_DIR / "uuid_mapping.csv"


def next_migration_output():
    """Choose the next free Flyway version instead of colliding with an existing migration."""
    versions = []
    for path in MIGRATION_DIR.glob("V*__*.sql"):
        match = re.match(r"V(\d+)__", path.name)
        if match:
            versions.append(int(match.group(1)))
    next_version = max(versions, default=0) + 1
    return MIGRATION_DIR / f"V{next_version}__merge_food_dataset.sql"

CUISINE_NUTRITION = {
    "african": {"carbs_pct": 0.60, "fat_pct": 0.25, "fiber": 4.0, "cost": 5.50},
    "american": {"carbs_pct": 0.45, "fat_pct": 0.35, "fiber": 3.0, "cost": 8.00},
    "brazilian": {"carbs_pct": 0.50, "fat_pct": 0.30, "fiber": 3.5, "cost": 6.50},
    "caribbean": {"carbs_pct": 0.55, "fat_pct": 0.25, "fiber": 4.0, "cost": 6.00},
    "french": {"carbs_pct": 0.40, "fat_pct": 0.38, "fiber": 3.0, "cost": 10.00},
    "greek": {"carbs_pct": 0.40, "fat_pct": 0.35, "fiber": 4.5, "cost": 7.50},
    "italian": {"carbs_pct": 0.50, "fat_pct": 0.30, "fiber": 3.5, "cost": 8.00},
    "japanese": {"carbs_pct": 0.55, "fat_pct": 0.25, "fiber": 3.0, "cost": 9.00},
    "mexican": {"carbs_pct": 0.50, "fat_pct": 0.30, "fiber": 4.5, "cost": 6.00},
    "portuguese": {"carbs_pct": 0.45, "fat_pct": 0.33, "fiber": 3.5, "cost": 7.00},
    "south_american": {"carbs_pct": 0.50, "fat_pct": 0.30, "fiber": 3.5, "cost": 6.00},
    "spanish": {"carbs_pct": 0.45, "fat_pct": 0.33, "fiber": 3.5, "cost": 7.50},
    "thai": {"carbs_pct": 0.50, "fat_pct": 0.30, "fiber": 3.5, "cost": 7.00},
    "turkish": {"carbs_pct": 0.50, "fat_pct": 0.30, "fiber": 4.0, "cost": 6.50},
}

DIFFICULTY_MAP = {"easy": "Easy", "medium": "Medium", "hard": "Hard"}
CUISINE_MAP = {
    "african": "African", "american": "American", "brazilian": "Brazilian",
    "caribbean": "Caribbean", "french": "French", "greek": "Greek",
    "italian": "Italian", "japanese": "Japanese", "mexican": "Mexican",
    "portuguese": "Portuguese", "south_american": "South American",
    "spanish": "Spanish", "thai": "Thai", "turkish": "Turkish",
}
MEAL_MAP = {
    "appetizer": "Appetizer", "breakfast": "Breakfast", "dessert": "Dessert",
    "drink": "Drink", "main": "Main Course", "sauce": "Sauce",
    "side_dish": "Side Dish", "snack": "Snack", "soup": "Soup", "starter": "Starter",
}

def generate_uuid(name, original_id):
    ns = uuid.UUID("6ba7b810-9dad-11d1-80b4-00c04fd430c8")
    return str(uuid.uuid5(ns, f"food_dataset_v2_{original_id}_{name}"))

def parse_dietary_tags(tag_str):
    tags = set()
    if tag_str:
        for t in tag_str.split("|"):
            tags.add(t.strip().lower())
    return tags

SQ = chr(39)
def esc(s):
    return str(s).replace(SQ, SQ * 2)
def b(v):
    if v is None:
        return "NULL"
    return "TRUE" if v else "FALSE"


def infer_allergen_flag(ingredient_rows, categories=(), pattern=None):
    """Return True/False only when every linked ingredient is available; otherwise unknown."""
    if not ingredient_rows or any(ingredient is None for ingredient in ingredient_rows):
        return None

    for ingredient in ingredient_rows:
        category = ingredient.get("category", "").strip().lower()
        name = ingredient.get("name", "").strip().lower()
        if category in categories or (pattern and re.search(pattern, name)):
            return True
    return False

def main():
    print("Reading recipes...")
    with open(RECIPES_CSV, "r", encoding="utf-8") as f:
        recipes = list(csv.DictReader(f))
    print(f"  {len(recipes)} recipes loaded")

    print("Reading ingredients...")
    with open(INGREDIENTS_CSV, "r", encoding="utf-8") as f:
        ingredients = {r["id"]: r for r in csv.DictReader(f)}
    print(f"  {len(ingredients)} ingredients loaded")

    print("Reading recipe-ingredient links...")
    with open(RECIPE_INGREDIENTS_CSV, "r", encoding="utf-8") as f:
        ri_links = list(csv.DictReader(f))
    ri_by_recipe = {}
    for link in ri_links:
        ri_by_recipe.setdefault(link["recipe_id"], []).append(link)
    print(f"  {len(ri_links)} links loaded")

    print("Reading nutrition...")
    with open(NUTRITION_CSV, "r", encoding="utf-8") as f:
        nutrition_rows = list(csv.DictReader(f))
    nutrition_by_recipe = {r["recipe_id"]: r for r in nutrition_rows}
    print(f"  {len(nutrition_rows)} entries loaded")

    mapping = []
    recipe_sql_parts = []
    ingredient_sql_parts = []
    step_sql_parts = []
    step_uuid_counter = [1]

    for r in recipes:
        rid = r["id"]
        name = r["name"].strip()
        recipe_uuid = generate_uuid(name, rid)
        cuisine = CUISINE_MAP.get(r["cuisine"], "International")
        meal_type = MEAL_MAP.get(r["meal_type"], "Main Course")
        difficulty = DIFFICULTY_MAP.get(r["difficulty"], "Medium")
        servings = int(r["servings"]) if r["servings"] and r["servings"].strip() else 4
        prep_time = int(r["prep_time"]) if r["prep_time"] and r["prep_time"].strip() else 10
        cook_time = int(r["cook_time"]) if r["cook_time"] and r["cook_time"].strip() else 20
        total_time = prep_time + cook_time
        desc = r.get("description", "").strip() or f"{name} is a delicious {cuisine} {meal_type.lower()} dish."

        calories = float(r["calories_per_serving"]) if r.get("calories_per_serving") and r["calories_per_serving"].strip() else 0
        protein = float(r["protein"]) if r.get("protein") and r["protein"].strip() else 0

        n = nutrition_by_recipe.get(rid, {})
        nut_cal = float(n.get("calories", 0)) if n.get("calories") else 0
        nut_prot = float(n.get("protein", 0)) if n.get("protein") else 0
        if nut_cal > 0:
            calories = nut_cal
        if nut_prot > 0:
            protein = nut_prot

        cuisine_nut = CUISINE_NUTRITION.get(r["cuisine"], {"carbs_pct": 0.50, "fat_pct": 0.30, "fiber": 3.5, "cost": 7.0})
        if calories > 0 and protein > 0:
            non_protein_cals = calories - (protein * 4)
            if non_protein_cals < 0:
                non_protein_cals = calories * 0.7
            carbs = round((non_protein_cals * cuisine_nut["carbs_pct"]) / 4, 1)
            fat = round((non_protein_cals * cuisine_nut["fat_pct"]) / 9, 1)
        elif calories > 0:
            carbs = round((calories * cuisine_nut["carbs_pct"]) / 4, 1)
            fat = round((calories * cuisine_nut["fat_pct"]) / 9, 1)
        else:
            carbs = 30.0
            fat = 15.0
        fiber = cuisine_nut["fiber"]
        estimated_cost = cuisine_nut["cost"]

        tags = parse_dietary_tags(r.get("dietary_tags", ""))

        vegan = "vegan" in tags
        vegetarian = "vegetarian" in tags or vegan
        halal = "halal" in tags
        kosher = "kosher" in tags
        low_carb = carbs < 20
        keto = carbs < 10 and fat > 30

        ri_list = ri_by_recipe.get(rid, [])
        linked_ingredients = [
            ingredients.get(link.get("ingredient_id", ""))
            for link in ri_list
        ]
        contains_gluten = infer_allergen_flag(
            linked_ingredients,
            pattern=r"\\b(wheat|barley|rye|semolina|couscous|pasta|noodle|bread|flour|bulgur|seitan|malt|spelt|farro|soy sauce)\\b",
        )
        contains_lactose = infer_allergen_flag(
            linked_ingredients,
            categories={"dairy"},
            pattern=r"\\b(milk|cheese|butter|yogurt|cream|whey|casein|ghee)\\b",
        )
        contains_nuts = infer_allergen_flag(
            linked_ingredients,
            categories={"nut"},
            pattern=r"\\b(peanut|almond|cashew|walnut|pistachio|hazelnut|pecan|macadamia|sesame|coconut)\\b",
        )
        contains_soy = infer_allergen_flag(
            linked_ingredients,
            pattern=r"\\b(soy|soya|tofu|edamame|tempeh|miso)\\b",
        )
        contains_eggs = infer_allergen_flag(
            linked_ingredients,
            categories={"egg"},
            pattern=r"\\b(egg|eggs|mayonnaise|meringue)\\b",
        )
        contains_fish = infer_allergen_flag(
            linked_ingredients,
            categories={"fish"},
            pattern=r"\\b(salmon|tuna|cod|tilapia|sardine|anchovy)\\b",
        )
        contains_shellfish = infer_allergen_flag(
            linked_ingredients,
            categories={"seafood"},
            pattern=r"\\b(shellfish|shrimp|prawn|crab|lobster|scallop|oyster|mussel|clam)\\b",
        )

        local_img = r.get("local_image", "").strip()
        candidate_image_url = r.get("image_url", "").strip()
        image_url = candidate_image_url if candidate_image_url.startswith("https://") else ""

        source = r.get("external_source", "").strip() or "PlatePilot dataset; source not verified"
        source_esc = esc(source)
        source_url = r.get("source_url", "").strip() or "NULL"

        name_esc = esc(name)
        desc_esc = esc(desc)
        src_url = "NULL" if source_url == "NULL" else f"'{esc(source_url)}'"
        recipe_sql_parts.append(f"('{recipe_uuid}', '{name_esc}', '{desc_esc}', {prep_time}, {cook_time}, {total_time}, {servings}, '{difficulty}', '{cuisine}', '{meal_type}', '{image_url}', '{source_esc}', TRUE, NULL, {calories}, {protein}, {carbs}, {fat}, {fiber}, {b(contains_gluten)}, {b(contains_lactose)}, {b(contains_nuts)}, {b(contains_soy)}, {b(contains_eggs)}, {b(contains_fish)}, {b(contains_shellfish)}, {b(vegan)}, {b(vegetarian)}, {b(halal)}, {b(kosher)}, {b(low_carb)}, {b(keto)}, {estimated_cost}, {src_url}, 'Ingredient category/name heuristic; verify labels', 'Carbs/fat/fiber estimated from cuisine averages', FALSE, 'UNREVIEWED', 0.350)")

        for ri in ri_list:
            ing = ingredients.get(ri["ingredient_id"], {})
            ing_name = ing.get("name", "unknown") if ing else "unknown"
            ing_name_esc = esc(ing_name)
            ing_uuid = str(uuid.uuid5(uuid.UUID(recipe_uuid), f"ing_{ri['ingredient_id']}_{ri.get('quantity', '0')}"))
            qty = ri.get("quantity", "0").strip() or "0"
            try:
                qty_num = round(float(qty), 2)
            except ValueError:
                qty_num = 0
            unit = ri.get("unit", "").strip() or "piece"
            notes = f"canonical ingredient: {ing_name_esc}"
            sort_order = ri.get("sort_order", "1") if "sort_order" in ri else "1"
            ingredient_sql_parts.append(f"('{ing_uuid}', '{recipe_uuid}', '{ing_name_esc}', {qty_num}, '{unit}', '{notes}', {sort_order})")

        instructions_raw = r.get("instructions", "").strip()
        if instructions_raw:
            steps = [s.strip().lstrip("|").strip() for s in instructions_raw.replace("\n", "|").split("|") if s.strip().lstrip("|").strip()]
        else:
            steps = [f"Prepare all ingredients for {name}.", f"Cook according to {cuisine} {meal_type.lower()} method.", "Adjust seasoning and serve warm."]

        for idx, step_text in enumerate(steps, 1):
            step_id = str(uuid.uuid5(uuid.UUID(recipe_uuid), f"step_{idx}"))
            step_text_esc = esc(step_text)
            step_sql_parts.append(f"('{step_id}', '{recipe_uuid}', {idx}, '{step_text_esc}', NULL)")

        mapping.append({"recipe_id": rid, "uuid": recipe_uuid, "name": name, "local_image": local_img, "image_url": image_url})

    print("Writing SQL...")

    out_sql = next_migration_output()
    with open(out_sql, "w", encoding="utf-8") as f:
        f.write(f"-- {out_sql.name}\\n")
        f.write(f"-- Generated from food_dataset_v2 ({len(recipes)} recipes)\\n\\n")

        f.write("INSERT INTO recipes (id, name, description, prep_time_minutes, cook_time_minutes, total_time_minutes, servings, difficulty, cuisine_type, meal_type, image_url, source, is_public, user_id, calories_per_serving, protein_per_serving, carbs_per_serving, fat_per_serving, fiber_per_serving, contains_gluten, contains_lactose, contains_nuts, contains_soy, contains_eggs, contains_fish, contains_shellfish, vegan, vegetarian, halal_friendly, kosher_friendly, low_carb, keto_friendly, estimated_cost, source_url, allergen_source, nutrition_source, verified, verification_status, confidence_score) VALUES\n")
        for i, part in enumerate(recipe_sql_parts):
            f.write(part)
            if i < len(recipe_sql_parts) - 1:
                f.write(",\n")
            else:
                f.write("\n")
        f.write("ON CONFLICT (id) DO UPDATE SET updated_at = NOW(), name = EXCLUDED.name, description = EXCLUDED.description, prep_time_minutes = EXCLUDED.prep_time_minutes, cook_time_minutes = EXCLUDED.cook_time_minutes, total_time_minutes = EXCLUDED.total_time_minutes, servings = EXCLUDED.servings, difficulty = EXCLUDED.difficulty, cuisine_type = EXCLUDED.cuisine_type, meal_type = EXCLUDED.meal_type, image_url = EXCLUDED.image_url, source = EXCLUDED.source, is_public = EXCLUDED.is_public, calories_per_serving = EXCLUDED.calories_per_serving, protein_per_serving = EXCLUDED.protein_per_serving, carbs_per_serving = EXCLUDED.carbs_per_serving, fat_per_serving = EXCLUDED.fat_per_serving, fiber_per_serving = EXCLUDED.fiber_per_serving, contains_gluten = EXCLUDED.contains_gluten, contains_lactose = EXCLUDED.contains_lactose, contains_nuts = EXCLUDED.contains_nuts, contains_soy = EXCLUDED.contains_soy, contains_eggs = EXCLUDED.contains_eggs, contains_fish = EXCLUDED.contains_fish, contains_shellfish = EXCLUDED.contains_shellfish, vegan = EXCLUDED.vegan, vegetarian = EXCLUDED.vegetarian, halal_friendly = EXCLUDED.halal_friendly, kosher_friendly = EXCLUDED.kosher_friendly, low_carb = EXCLUDED.low_carb, keto_friendly = EXCLUDED.keto_friendly, estimated_cost = EXCLUDED.estimated_cost, allergen_source = EXCLUDED.allergen_source, nutrition_source = EXCLUDED.nutrition_source, verified = EXCLUDED.verified, verification_status = EXCLUDED.verification_status, confidence_score = EXCLUDED.confidence_score;\n\n")

        f.write("INSERT INTO recipe_ingredients (id, recipe_id, name, quantity, unit, notes, sort_order) VALUES\n")
        for i, part in enumerate(ingredient_sql_parts):
            f.write(part)
            if i < len(ingredient_sql_parts) - 1:
                f.write(",\n")
            else:
                f.write("\n")
        f.write("ON CONFLICT (id) DO NOTHING;\n\n")

        f.write("INSERT INTO recipe_steps (id, recipe_id, step_number, instruction, duration_minutes) VALUES\n")
        for i, part in enumerate(step_sql_parts):
            f.write(part)
            if i < len(step_sql_parts) - 1:
                f.write(",\n")
            else:
                f.write("\n")
        f.write("ON CONFLICT (id) DO NOTHING;\n")

    print(f"SQL written: {out_sql}")

    with open(MAPPING_CSV, "w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=["recipe_id", "uuid", "name", "local_image", "image_url"])
        w.writeheader()
        w.writerows(mapping)
    print(f"Mapping CSV: {MAPPING_CSV}")

    print(f"\nSummary:")
    print(f"  Recipes: {len(recipe_sql_parts)}")
    print(f"  Ingredients: {len(ingredient_sql_parts)}")
    print(f"  Steps: {len(step_sql_parts)}")
    print(f"  Recipes with external HTTPS images: {sum(1 for item in mapping if item[\"image_url\"])}")

if __name__ == "__main__":
    main()
