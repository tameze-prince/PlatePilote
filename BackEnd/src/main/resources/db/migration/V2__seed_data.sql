-- V2__seed_data.sql
-- Seed data for roles and default values

-- Roles
INSERT INTO roles (id, name, description) VALUES
    (uuid_generate_v4(), 'ROLE_USER', 'Standard user role'),
    (uuid_generate_v4(), 'ROLE_ADMIN', 'Administrator role'),
    (uuid_generate_v4(), 'ROLE_PREMIUM', 'Premium subscriber role');

-- Default pantry categories
INSERT INTO pantry_categories (id, name, description) VALUES
    (uuid_generate_v4(), 'fruits', 'Fresh and dried fruits'),
    (uuid_generate_v4(), 'vegetables', 'Fresh and frozen vegetables'),
    (uuid_generate_v4(), 'dairy', 'Milk, cheese, yogurt, and other dairy products'),
    (uuid_generate_v4(), 'meat', 'Beef, pork, lamb, and other meats'),
    (uuid_generate_v4(), 'poultry', 'Chicken, turkey, and other poultry'),
    (uuid_generate_v4(), 'seafood', 'Fish, shellfish, and other seafood'),
    (uuid_generate_v4(), 'grains', 'Rice, pasta, bread, and other grains'),
    (uuid_generate_v4(), 'legumes', 'Beans, lentils, peas, and other legumes'),
    (uuid_generate_v4(), 'spices', 'Herbs, spices, and seasonings'),
    (uuid_generate_v4(), 'oils', 'Cooking oils and fats'),
    (uuid_generate_v4(), 'condiments', 'Sauces, dressings, and condiments'),
    (uuid_generate_v4(), 'snacks', 'Chips, crackers, and other snacks'),
    (uuid_generate_v4(), 'beverages', 'Drinks and liquids'),
    (uuid_generate_v4(), 'baking', 'Flour, sugar, and baking supplies'),
    (uuid_generate_v4(), 'frozen', 'Frozen foods and meals'),
    (uuid_generate_v4(), 'canned', 'Canned and preserved goods');

-- Default recipe tags
INSERT INTO recipe_tags (id, name, slug) VALUES
    (uuid_generate_v4(), 'Quick & Easy', 'quick-easy'),
    (uuid_generate_v4(), 'Healthy', 'healthy'),
    (uuid_generate_v4(), 'Vegetarian', 'vegetarian'),
    (uuid_generate_v4(), 'Vegan', 'vegan'),
    (uuid_generate_v4(), 'Gluten-Free', 'gluten-free'),
    (uuid_generate_v4(), 'Dairy-Free', 'dairy-free'),
    (uuid_generate_v4(), 'High Protein', 'high-protein'),
    (uuid_generate_v4(), 'Low Carb', 'low-carb'),
    (uuid_generate_v4(), 'Kid-Friendly', 'kid-friendly'),
    (uuid_generate_v4(), 'Budget-Friendly', 'budget-friendly'),
    (uuid_generate_v4(), 'Meal Prep', 'meal-prep'),
    (uuid_generate_v4(), 'One Pot', 'one-pot'),
    (uuid_generate_v4(), 'Slow Cooker', 'slow-cooker'),
    (uuid_generate_v4(), 'Air Fryer', 'air-fryer'),
    (uuid_generate_v4(), 'Comfort Food', 'comfort-food'),
    (uuid_generate_v4(), 'Mediterranean', 'mediterranean');
