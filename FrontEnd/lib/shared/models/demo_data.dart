import 'package:flutter/material.dart';

/// Représente un repas dans les données de démonstration.
class Meal {
  const Meal({
    required this.day,
    required this.type,
    required this.title,
    required this.minutes,
    required this.kcal,
    required this.icon,
    required this.tint,
    this.locked = false,
    this.imageUrl,
    this.recipeId,
  });

  /// Jour de la semaine.
  final String day;
  /// Type de repas (Breakfast, Lunch, Dinner).
  final String type;
  /// Titre du repas.
  final String title;
  /// Temps de préparation en minutes.
  final int minutes;
  /// Calories du repas.
  final int kcal;
  /// Icône représentative.
  final IconData icon;
  /// Couleur d'accentuation.
  final Color tint;
  /// Indique si le repas est verrouillé.
  final bool locked;
  /// URL de l'image.
  final String? imageUrl;
  /// Identifiant de la recette associée.
  final String? recipeId;
}

/// Article de liste de courses (démo).
class GroceryItem {
  const GroceryItem({
    required this.name,
    required this.quantity,
    required this.price,
    required this.category,
    this.checked = false,
  });

  /// Nom de l'article.
  final String name;
  /// Quantité.
  final String quantity;
  /// Prix.
  final String price;
  /// Catégorie.
  final String category;
  /// Indique si l'article est coché.
  final bool checked;
}

/// Article du garde-manger (démo).
class PantryItem {
  const PantryItem({
    required this.name,
    required this.quantity,
    required this.expires,
    required this.category,
    required this.icon,
    required this.urgent,
  });

  /// Nom de l'article.
  final String name;
  /// Quantité.
  final String quantity;
  /// Date d'expiration.
  final String expires;
  /// Catégorie.
  final String category;
  /// Icône représentative.
  final IconData icon;
  /// Indique si l'article est urgent.
  final bool urgent;
}

/// Liste de repas de démonstration pour la semaine.
const demoMeals = <Meal>[
  Meal(
    day: 'Mon',
    type: 'Dinner',
    title: 'Mediterranean Quinoa Bowl',
    minutes: 15,
    kcal: 450,
    icon: Icons.rice_bowl,
    tint: Color(0xFF22C55E),
  ),
  Meal(
    day: 'Tue',
    type: 'Dinner',
    title: 'Grilled Salmon & Asparagus',
    minutes: 25,
    kcal: 520,
    icon: Icons.set_meal,
    tint: Color(0xFF3B82F6),
    locked: true,
  ),
  Meal(
    day: 'Wed',
    type: 'Dinner',
    title: 'Zucchini Pesto Penne',
    minutes: 20,
    kcal: 380,
    icon: Icons.dinner_dining,
    tint: Color(0xFFF59E0B),
  ),
  Meal(
    day: 'Thu',
    type: 'Dinner',
    title: 'Turkey Taco Lettuce Cups',
    minutes: 18,
    kcal: 410,
    icon: Icons.local_dining,
    tint: Color(0xFFEF4444),
  ),
  Meal(
    day: 'Fri',
    type: 'Dinner',
    title: 'Coconut Chickpea Curry',
    minutes: 28,
    kcal: 560,
    icon: Icons.soup_kitchen,
    tint: Color(0xFF22C55E),
  ),
  Meal(
    day: 'Sat',
    type: 'Dinner',
    title: 'Sheet Pan Chicken Fajitas',
    minutes: 30,
    kcal: 610,
    icon: Icons.restaurant,
    tint: Color(0xFF3B82F6),
  ),
  Meal(
    day: 'Sun',
    type: 'Dinner',
    title: 'Spinach Mushroom Frittata',
    minutes: 22,
    kcal: 390,
    icon: Icons.egg_alt,
    tint: Color(0xFFF59E0B),
  ),
];

/// Liste des repas du jour (démo).
const todayMeals = <Meal>[
  Meal(
    day: 'Today',
    type: 'Breakfast',
    title: 'Honey Yogurt Bowl',
    minutes: 5,
    kcal: 320,
    icon: Icons.breakfast_dining,
    tint: Color(0xFF22C55E),
  ),
  Meal(
    day: 'Today',
    type: 'Lunch',
    title: 'Chicken Caesar Salad',
    minutes: 15,
    kcal: 450,
    icon: Icons.lunch_dining,
    tint: Color(0xFF3B82F6),
  ),
  Meal(
    day: 'Today',
    type: 'Dinner',
    title: 'Lemon Herb Salmon',
    minutes: 25,
    kcal: 580,
    icon: Icons.dinner_dining,
    tint: Color(0xFFF59E0B),
  ),
];

/// Liste d'articles de courses de démonstration.
const groceryItems = <GroceryItem>[
  GroceryItem(
    name: 'Organic Honeycrisp Apples',
    quantity: '5 count',
    price: r'$7.50',
    category: 'Produce',
  ),
  GroceryItem(
    name: 'Fresh Spinach',
    quantity: '1 bag',
    price: r'$3.99',
    category: 'Produce',
  ),
  GroceryItem(
    name: 'Asparagus',
    quantity: '1 bunch',
    price: r'$4.50',
    category: 'Produce',
  ),
  GroceryItem(
    name: 'Greek Yogurt',
    quantity: '32 oz',
    price: r'$5.49',
    category: 'Dairy & Eggs',
  ),
  GroceryItem(
    name: 'Free Range Eggs',
    quantity: '12 count',
    price: r'$4.75',
    category: 'Dairy & Eggs',
  ),
  GroceryItem(
    name: 'Atlantic Salmon',
    quantity: '1.5 lb',
    price: r'$18.90',
    category: 'Protein',
  ),
  GroceryItem(
    name: 'Chicken Breast',
    quantity: '2 lb',
    price: r'$13.80',
    category: 'Protein',
  ),
  GroceryItem(
    name: 'Quinoa',
    quantity: '1 box',
    price: r'$6.25',
    category: 'Pantry Staples',
  ),
];

/// Liste d'articles de garde-manger de démonstration.
const pantryItems = <PantryItem>[
  PantryItem(
    name: 'Fresh Spinach',
    quantity: '1 bag',
    expires: 'Expires in 2 days',
    category: 'Produce',
    icon: Icons.eco,
    urgent: true,
  ),
  PantryItem(
    name: 'Greek Yogurt',
    quantity: '32 oz',
    expires: 'Expires in 4 days',
    category: 'Dairy',
    icon: Icons.icecream,
    urgent: true,
  ),
  PantryItem(
    name: 'Quinoa',
    quantity: '2 cups',
    expires: 'Shelf stable',
    category: 'Staples',
    icon: Icons.grain,
    urgent: false,
  ),
  PantryItem(
    name: 'Cherry Tomatoes',
    quantity: '1 pint',
    expires: 'Expires in 6 days',
    category: 'Produce',
    icon: Icons.local_florist,
    urgent: false,
  ),
];
