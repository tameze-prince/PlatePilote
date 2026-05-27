import csv
import uuid
import os
import shutil
import re
from pathlib import Path

BASE_DIR = Path(__file__).parent
RECIPES_CSV = BASE_DIR / "recipes.csv"
INGREDIENTS_CSV = BASE_DIR / "ingredients.csv"
RECIPE_INGREDIENTS_CSV = BASE_DIR / "recipe_ingredients.csv"
NUTRITION_CSV = BASE_DIR / "nutrition.csv"
IMAGES_SRC = BASE_DIR / "recipe_images"
IMAGES_DST = BASE_DIR / ".." / "BackEnd" / "src" / "main" / "resources" / "db" / "migration" / "recipe_images"

OUT_SQL = BASE_DIR / ".." / "BackEnd" / "src" / "main" / "resources" / "db" / "migration" / "V101__merge_food_dataset.sql"
MAPPING_CSV = BASE_DIR / "uuid_mapping.csv"

os.makedirs(IMAGES_DST, exist_ok=True)

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
    return "TRUE" if v else "FALSE"

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
    renamed = 0
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

        contains_gluten = "gluten_free" not in tags
        contains_lactose = "dairy_free" not in tags
        contains_nuts = "nut_free" not in tags
        contains_soy = False
        contains_eggs = False
        contains_fish = False
        contains_shellfish = False

        local_img = r.get("local_image", "").strip()
        if local_img:
            src_path = BASE_DIR.parent / local_img.replace("\\", "/")
            if src_path.exists():
                dst_name = f"{recipe_uuid}.jpg"
                dst_path = IMAGES_DST / dst_name
                if not dst_path.exists():
                    shutil.copy2(src_path, dst_path)
                    renamed += 1
                image_url = f"cloudflare_url/recipe_images/{dst_name}"
            else:
                image_url = ""
        else:
            image_url = ""

        source = "PlatePilot generated from public food references"
        source_url = r.get("image_url", "").strip() or "NULL"

        name_esc = esc(name)
        desc_esc = esc(desc)
        src_url = "NULL" if source_url == "NULL" else f"'{esc(source_url)}'"
        recipe_sql_parts.append(f"('{recipe_uuid}', '{name_esc}', '{desc_esc}', {prep_time}, {cook_time}, {total_time}, {servings}, '{difficulty}', '{cuisine}', '{meal_type}', '{image_url}', '{source}', TRUE, NULL, {calories}, {protein}, {carbs}, {fat}, {fiber}, {b(contains_gluten)}, {b(contains_lactose)}, {b(contains_nuts)}, {b(contains_soy)}, {b(contains_eggs)}, {b(contains_fish)}, {b(contains_shellfish)}, {b(vegan)}, {b(vegetarian)}, {b(halal)}, {b(kosher)}, {b(low_carb)}, {b(keto)}, {estimated_cost}, {src_url})")

        ri_list = ri_by_recipe.get(rid, [])
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

    print(f"\nCopying images... {renamed} new, {len(recipes) - renamed} already existed")
    print("Writing SQL...")

    with open(OUT_SQL, "w", encoding="utf-8") as f:
        f.write("-- V101__merge_food_dataset.sql\n")
        f.write("-- Generated from food_dataset_v2 (2000 recipes)\n\n")

        f.write("INSERT INTO recipes (id, name, description, prep_time_minutes, cook_time_minutes, total_time_minutes, servings, difficulty, cuisine_type, meal_type, image_url, source, is_public, user_id, calories_per_serving, protein_per_serving, carbs_per_serving, fat_per_serving, fiber_per_serving, contains_gluten, contains_lactose, contains_nuts, contains_soy, contains_eggs, contains_fish, contains_shellfish, vegan, vegetarian, halal_friendly, kosher_friendly, low_carb, keto_friendly, estimated_cost, source_url) VALUES\n")
        for i, part in enumerate(recipe_sql_parts):
            f.write(part)
            if i < len(recipe_sql_parts) - 1:
                f.write(",\n")
            else:
                f.write("\n")
        f.write("ON CONFLICT (id) DO UPDATE SET updated_at = NOW(), name = EXCLUDED.name, description = EXCLUDED.description, prep_time_minutes = EXCLUDED.prep_time_minutes, cook_time_minutes = EXCLUDED.cook_time_minutes, total_time_minutes = EXCLUDED.total_time_minutes, servings = EXCLUDED.servings, difficulty = EXCLUDED.difficulty, cuisine_type = EXCLUDED.cuisine_type, meal_type = EXCLUDED.meal_type, image_url = EXCLUDED.image_url, source = EXCLUDED.source, is_public = EXCLUDED.is_public, calories_per_serving = EXCLUDED.calories_per_serving, protein_per_serving = EXCLUDED.protein_per_serving, carbs_per_serving = EXCLUDED.carbs_per_serving, fat_per_serving = EXCLUDED.fat_per_serving, fiber_per_serving = EXCLUDED.fiber_per_serving, contains_gluten = EXCLUDED.contains_gluten, contains_lactose = EXCLUDED.contains_lactose, contains_nuts = EXCLUDED.contains_nuts, contains_soy = EXCLUDED.contains_soy, contains_eggs = EXCLUDED.contains_eggs, contains_fish = EXCLUDED.contains_fish, contains_shellfish = EXCLUDED.contains_shellfish, vegan = EXCLUDED.vegan, vegetarian = EXCLUDED.vegetarian, halal_friendly = EXCLUDED.halal_friendly, kosher_friendly = EXCLUDED.kosher_friendly, low_carb = EXCLUDED.low_carb, keto_friendly = EXCLUDED.keto_friendly, estimated_cost = EXCLUDED.estimated_cost;\n\n")

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

    print(f"SQL written: {OUT_SQL}")

    with open(MAPPING_CSV, "w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=["recipe_id", "uuid", "name", "local_image", "image_url"])
        w.writeheader()
        w.writerows(mapping)
    print(f"Mapping CSV: {MAPPING_CSV}")

    print(f"\nSummary:")
    print(f"  Recipes: {len(recipe_sql_parts)}")
    print(f"  Ingredients: {len(ingredient_sql_parts)}")
    print(f"  Steps: {len(step_sql_parts)}")
    print(f"  Images copied: {renamed}")

if __name__ == "__main__":
    main()
