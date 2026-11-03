import unittest

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


if __name__ == "__main__":
    unittest.main()
