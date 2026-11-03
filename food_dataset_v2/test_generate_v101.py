import shutil
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

from generate_v101 import b, infer_allergen_flag, next_migration_output


class FoodDatasetGeneratorTest(unittest.TestCase):
    def test_unknown_allergen_value_is_written_as_sql_null(self):
        self.assertEqual(b(None), "NULL")

    def test_known_negative_allergen_value_is_written_as_false(self):
        self.assertEqual(b(False), "FALSE")

    def test_missing_or_incomplete_ingredient_links_remain_unknown(self):
        self.assertIsNone(infer_allergen_flag([]))
        self.assertIsNone(infer_allergen_flag([{"name": "rice", "category": "grain"}, None]))

    def test_allergen_is_inferred_from_ingredient_category(self):
        ingredients = [{"name": "almond", "category": "nut"}]
        self.assertIs(infer_allergen_flag(ingredients, categories={"nut"}), True)

    def test_complete_ingredient_list_without_match_is_negative(self):
        ingredients = [
            {"name": "rice", "category": "grain"},
            {"name": "tomato", "category": "vegetable"},
        ]
        self.assertIs(infer_allergen_flag(ingredients, categories={"nut"}), False)

    def test_generated_migration_uses_a_free_flyway_version(self):
        generated_path = next_migration_output()
        self.assertGreater(int(generated_path.name.split("__", maxsplit=1)[0][1:]), 120)

    def test_full_dataset_generates_valid_versioned_migration_without_fake_steps(self):
        repository_root = Path(__file__).resolve().parent.parent
        with tempfile.TemporaryDirectory() as temp_dir:
            temp_root = Path(temp_dir) / "project"
            food_dir = temp_root / "food_dataset_v2"
            migration_dir = (
                temp_root
                / "BackEnd"
                / "src"
                / "main"
                / "resources"
                / "db"
                / "migration"
            )
            food_dir.mkdir(parents=True)
            migration_dir.mkdir(parents=True)
            (migration_dir / "V120__existing.sql").write_text("-- existing", encoding="utf-8")

            for filename in (
                "generate_v101.py",
                "recipes.csv",
                "ingredients.csv",
                "recipe_ingredients.csv",
                "nutrition.csv",
            ):
                shutil.copy2(repository_root / "food_dataset_v2" / filename, food_dir / filename)

            result = subprocess.run(
                [sys.executable, str(food_dir / "generate_v101.py")],
                check=True,
                capture_output=True,
                text=True,
            )

            generated_sql = migration_dir / "V121__merge_food_dataset.sql"
            self.assertTrue(generated_sql.is_file())
            sql = generated_sql.read_text(encoding="utf-8")
            self.assertIn("INSERT INTO recipes", sql)
            self.assertIn("INSERT INTO recipe_ingredients", sql)
            self.assertIn("INSERT INTO recipe_steps", sql)
            self.assertNotIn("cloudflare_url", sql)
            self.assertNotIn("Prepare all ingredients", sql)
            self.assertIn("UNREVIEWED", sql)
            self.assertIn("Recipes: 2000", result.stdout)


if __name__ == "__main__":
    unittest.main()
