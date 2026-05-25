package com.plateplate.ai.application.service;

import com.plateplate.ai.domain.model.EstimatedNutrition;
import com.plateplate.ai.domain.model.ParsedIngredientLine;
import com.plateplate.ai.domain.model.ParsedRecipe;
import com.plateplate.common.util.StringNormalizer;
import com.plateplate.common.util.UnitConverter;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

public class DefaultNutritionEstimator implements NutritionEstimator {
    private static final Logger log = LoggerFactory.getLogger(DefaultNutritionEstimator.class);
    private static final double FALLBACK_DENSITY = 1.0;

    private static final Map<String, double[]> NUTRITION_DB = new HashMap<>();
    private static final Map<String, Double> DENSITY_MAP = new HashMap<>();
    static {
        NUTRITION_DB.put("chicken breast",  new double[]{165, 31, 0, 3.6, 0, 0, 0.07});
        NUTRITION_DB.put("chicken thigh",  new double[]{209, 26, 0, 11, 0, 0, 0.08});
        NUTRITION_DB.put("chicken",        new double[]{165, 31, 0, 3.6, 0, 0, 0.07});
        NUTRITION_DB.put("beef",           new double[]{250, 26, 0, 15, 0, 0, 0.06});
        NUTRITION_DB.put("ground beef",    new double[]{250, 26, 0, 15, 0, 0, 0.06});
        NUTRITION_DB.put("pork",           new double[]{242, 27, 0, 14, 0, 0, 0.06});
        NUTRITION_DB.put("bacon",          new double[]{541, 37, 1.4, 42, 0, 0, 0.17});
        NUTRITION_DB.put("salmon",         new double[]{208, 20, 0, 13, 0, 0, 0.06});
        NUTRITION_DB.put("tuna",           new double[]{184, 30, 0, 6.3, 0, 0, 0.04});
        NUTRITION_DB.put("shrimp",         new double[]{85, 20, 0, 0.5, 0, 0, 0.15});
        NUTRITION_DB.put("fish",           new double[]{200, 22, 0, 12, 0, 0, 0.08});
        NUTRITION_DB.put("egg",            new double[]{155, 13, 1.1, 11, 0, 0.56, 0.14});
        NUTRITION_DB.put("eggs",           new double[]{155, 13, 1.1, 11, 0, 0.56, 0.14});
        NUTRITION_DB.put("milk",           new double[]{42, 3.4, 5, 1, 0, 5, 0.04});
        NUTRITION_DB.put("whole milk",     new double[]{61, 3.2, 4.8, 3.3, 0, 5, 0.04});
        NUTRITION_DB.put("butter",         new double[]{717, 0.9, 0, 81, 0, 0, 0.02});
        NUTRITION_DB.put("cheese",         new double[]{402, 25, 1.3, 33, 0, 0.5, 0.06});
        NUTRITION_DB.put("cheddar",        new double[]{402, 25, 1.3, 33, 0, 0.5, 0.06});
        NUTRITION_DB.put("mozzarella",     new double[]{280, 28, 3.1, 17, 0, 0.5, 0.06});
        NUTRITION_DB.put("parmesan",       new double[]{431, 38, 4.1, 29, 0, 0.8, 0.12});
        NUTRITION_DB.put("cream",          new double[]{340, 2.8, 2.8, 36, 0, 2.8, 0.03});
        NUTRITION_DB.put("yogurt",         new double[]{59, 10, 3.6, 0.7, 0, 3.6, 0.05});
        NUTRITION_DB.put("greek yogurt",   new double[]{97, 19, 3.6, 0.7, 0, 3.6, 0.05});
        NUTRITION_DB.put("olive oil",      new double[]{884, 0, 0, 100, 0, 0, 0});
        NUTRITION_DB.put("vegetable oil",  new double[]{884, 0, 0, 100, 0, 0, 0});
        NUTRITION_DB.put("canola oil",     new double[]{884, 0, 0, 100, 0, 0, 0});
        NUTRITION_DB.put("coconut oil",    new double[]{862, 0, 0, 100, 0, 0, 0});
        NUTRITION_DB.put("rice",           new double[]{130, 2.7, 28, 0.3, 0.4, 0.1, 0});
        NUTRITION_DB.put("white rice",     new double[]{130, 2.7, 28, 0.3, 0.4, 0.1, 0});
        NUTRITION_DB.put("brown rice",     new double[]{111, 2.6, 23, 0.9, 1.8, 0.4, 0});
        NUTRITION_DB.put("pasta",          new double[]{131, 5, 25, 1.1, 0, 0.6, 0});
        NUTRITION_DB.put("spaghetti",      new double[]{131, 5, 25, 1.1, 0, 0.6, 0});
        NUTRITION_DB.put("bread",          new double[]{265, 9, 49, 3.2, 2.7, 5, 0.06});
        NUTRITION_DB.put("flour",          new double[]{364, 10, 76, 1, 2.7, 0.3, 0});
        NUTRITION_DB.put("all purpose flour", new double[]{364, 10, 76, 1, 2.7, 0.3, 0});
        NUTRITION_DB.put("sugar",          new double[]{387, 0, 100, 0, 0, 100, 0});
        NUTRITION_DB.put("brown sugar",    new double[]{380, 0, 98, 0, 0, 97, 0});
        NUTRITION_DB.put("honey",          new double[]{304, 0.3, 82, 0, 0.2, 82, 0});
        NUTRITION_DB.put("salt",           new double[]{0, 0, 0, 0, 0, 0, 38.8});
        NUTRITION_DB.put("garlic",         new double[]{149, 6.4, 33, 0.5, 2.1, 1, 0});
        NUTRITION_DB.put("onion",          new double[]{40, 1.1, 9.3, 0.1, 1.7, 4.7, 0});
        NUTRITION_DB.put("tomato",         new double[]{18, 0.9, 3.9, 0.2, 1.2, 2.6, 0});
        NUTRITION_DB.put("tomatoes",       new double[]{18, 0.9, 3.9, 0.2, 1.2, 2.6, 0});
        NUTRITION_DB.put("potato",         new double[]{77, 2, 17, 0.1, 2.2, 0.8, 0});
        NUTRITION_DB.put("potatoes",       new double[]{77, 2, 17, 0.1, 2.2, 0.8, 0});
        NUTRITION_DB.put("carrot",         new double[]{41, 0.9, 9.6, 0.2, 2.8, 4.7, 0.07});
        NUTRITION_DB.put("carrots",        new double[]{41, 0.9, 9.6, 0.2, 2.8, 4.7, 0.07});
        NUTRITION_DB.put("broccoli",       new double[]{34, 2.8, 7, 0.4, 2.6, 1.7, 0.03});
        NUTRITION_DB.put("spinach",        new double[]{23, 2.9, 3.6, 0.4, 2.2, 0.4, 0.08});
        NUTRITION_DB.put("lettuce",        new double[]{15, 1.4, 2.9, 0.2, 1.3, 0.8, 0});
        NUTRITION_DB.put("cucumber",       new double[]{15, 0.7, 3.6, 0.1, 0.5, 1.7, 0});
        NUTRITION_DB.put("bell pepper",    new double[]{31, 1, 6, 0.3, 2.1, 3, 0});
        NUTRITION_DB.put("bell peppers",   new double[]{31, 1, 6, 0.3, 2.1, 3, 0});
        NUTRITION_DB.put("mushroom",       new double[]{22, 3.1, 3.3, 0.3, 1, 2, 0});
        NUTRITION_DB.put("mushrooms",      new double[]{22, 3.1, 3.3, 0.3, 1, 2, 0});
        NUTRITION_DB.put("avocado",        new double[]{160, 2, 8.5, 15, 6.7, 1, 0});
        NUTRITION_DB.put("lemon",          new double[]{29, 1.1, 9.3, 0.3, 2.8, 2.5, 0});
        NUTRITION_DB.put("lime",           new double[]{30, 0.7, 11, 0.2, 2.8, 1.7, 0});
        NUTRITION_DB.put("apple",          new double[]{52, 0.3, 14, 0.2, 2.4, 10, 0});
        NUTRITION_DB.put("banana",         new double[]{89, 1.1, 23, 0.3, 2.6, 12, 0});
        NUTRITION_DB.put("orange",         new double[]{47, 0.9, 12, 0.1, 2.4, 9.4, 0});
        NUTRITION_DB.put("strawberry",     new double[]{32, 0.7, 7.7, 0.3, 2, 4.9, 0});
        NUTRITION_DB.put("strawberries",   new double[]{32, 0.7, 7.7, 0.3, 2, 4.9, 0});
        NUTRITION_DB.put("blueberry",      new double[]{57, 0.7, 14, 0.3, 2.4, 10, 0});
        NUTRITION_DB.put("blueberries",    new double[]{57, 0.7, 14, 0.3, 2.4, 10, 0});
        NUTRITION_DB.put("beans",          new double[]{132, 8.7, 24, 0.5, 6.4, 2, 0});
        NUTRITION_DB.put("black beans",    new double[]{132, 8.7, 24, 0.5, 6.4, 2, 0});
        NUTRITION_DB.put("kidney beans",   new double[]{127, 8.7, 23, 0.5, 6.4, 2, 0});
        NUTRITION_DB.put("lentils",        new double[]{116, 9, 20, 0.4, 7.9, 1.8, 0});
        NUTRITION_DB.put("chickpea",       new double[]{139, 7.6, 23, 2.1, 6.4, 4.8, 0});
        NUTRITION_DB.put("tofu",           new double[]{76, 8, 1.9, 4.8, 0.3, 0, 0});
        NUTRITION_DB.put("corn",           new double[]{96, 3.4, 21, 1.5, 2.4, 4.5, 0});
        NUTRITION_DB.put("peas",           new double[]{81, 5.4, 14, 0.4, 5.1, 5.7, 0});
        NUTRITION_DB.put("soy sauce",      new double[]{53, 8, 4.7, 0, 0, 0.4, 5.5});
        NUTRITION_DB.put("ketchup",        new double[]{101, 1, 28, 0.1, 0, 22, 0.9});
        NUTRITION_DB.put("mustard",        new double[]{66, 3.6, 5.8, 3, 1.5, 1, 1.1});
        NUTRITION_DB.put("mayonnaise",     new double[]{700, 1, 0.6, 75, 0, 0.6, 0.7});
        NUTRITION_DB.put("vinegar",        new double[]{18, 0, 0.6, 0, 0, 0.4, 0});
        NUTRITION_DB.put("tomato sauce",   new double[]{24, 1.2, 5.3, 0.3, 1.5, 3.6, 0.04});
        NUTRITION_DB.put("tomato paste",   new double[]{82, 4.3, 19, 0.5, 4.1, 13, 0.06});
        NUTRITION_DB.put("chicken broth",  new double[]{4, 0.5, 0.4, 0.1, 0, 0, 0.07});
        NUTRITION_DB.put("water",          new double[]{0, 0, 0, 0, 0, 0, 0});
        NUTRITION_DB.put("wine",           new double[]{85, 0.1, 2.7, 0, 0, 0.8, 0});
        NUTRITION_DB.put("beer",           new double[]{43, 0.5, 3.6, 0, 0, 0, 0});
        NUTRITION_DB.put("chocolate",      new double[]{546, 4.9, 61, 31, 3.4, 48, 0.02});
        NUTRITION_DB.put("cocoa powder",   new double[]{228, 20, 58, 14, 33, 1.8, 0});
        NUTRITION_DB.put("vanilla extract", new double[]{288, 0, 13, 0, 0, 13, 0});
        NUTRITION_DB.put("cinnamon",       new double[]{247, 4, 81, 1.2, 53, 2, 0});
        NUTRITION_DB.put("pepper",         new double[]{251, 10, 64, 3.3, 27, 0.6, 0});
        NUTRITION_DB.put("basil",          new double[]{44, 3.2, 8, 0.6, 1.6, 0, 0});
        NUTRITION_DB.put("oregano",        new double[]{265, 9, 69, 4.3, 43, 0, 0.03});
        NUTRITION_DB.put("parsley",        new double[]{36, 3, 6, 0.8, 3.3, 0.9, 0.05});
        NUTRITION_DB.put("cilantro",       new double[]{23, 2.1, 3.7, 0.5, 2.8, 0.9, 0});
        NUTRITION_DB.put("bay leaf",       new double[]{313, 7.6, 75, 8.4, 27, 0, 0});
        NUTRITION_DB.put("thyme",          new double[]{101, 5.6, 24, 1.7, 14, 0, 0.01});
        NUTRITION_DB.put("rosemary",       new double[]{131, 3.3, 21, 5.9, 14, 0, 0.03});
        NUTRITION_DB.put("ginger",         new double[]{80, 1.8, 18, 0.8, 2, 1.7, 0.01});
        NUTRITION_DB.put("turmeric",       new double[]{354, 7.8, 65, 10, 22, 3.2, 0});
        NUTRITION_DB.put("almond",         new double[]{579, 21, 22, 50, 12.5, 4.4, 0});
        NUTRITION_DB.put("almonds",        new double[]{579, 21, 22, 50, 12.5, 4.4, 0});
        NUTRITION_DB.put("walnut",         new double[]{654, 15, 14, 65, 6.7, 2.6, 0});
        NUTRITION_DB.put("walnuts",        new double[]{654, 15, 14, 65, 6.7, 2.6, 0});
        NUTRITION_DB.put("peanut",         new double[]{567, 26, 16, 49, 8.5, 4.7, 0});
        NUTRITION_DB.put("peanuts",        new double[]{567, 26, 16, 49, 8.5, 4.7, 0});
        NUTRITION_DB.put("cashew",         new double[]{553, 18, 30, 44, 3.3, 5, 0});
        NUTRITION_DB.put("olive",          new double[]{115, 0.8, 6.3, 10.5, 3.2, 0.5, 0.08});
        NUTRITION_DB.put("olives",         new double[]{115, 0.8, 6.3, 10.5, 3.2, 0.5, 0.08});
        NUTRITION_DB.put("pickle",         new double[]{11, 0.3, 2.3, 0.2, 1, 1, 0.12});
        NUTRITION_DB.put("pickles",        new double[]{11, 0.3, 2.3, 0.2, 1, 1, 0.12});
        NUTRITION_DB.put("worcestershire", new double[]{78, 0, 20, 0, 0, 10, 0.9});

        DENSITY_MAP.put("olive oil", 0.92);
        DENSITY_MAP.put("vegetable oil", 0.92);
        DENSITY_MAP.put("canola oil", 0.92);
        DENSITY_MAP.put("coconut oil", 0.92);
        DENSITY_MAP.put("honey", 1.42);
        DENSITY_MAP.put("milk", 1.03);
        DENSITY_MAP.put("whole milk", 1.03);
        DENSITY_MAP.put("cream", 1.01);
        DENSITY_MAP.put("butter", 0.96);
        DENSITY_MAP.put("yogurt", 1.04);
        DENSITY_MAP.put("greek yogurt", 1.04);
        DENSITY_MAP.put("flour", 0.59);
        DENSITY_MAP.put("all purpose flour", 0.59);
        DENSITY_MAP.put("sugar", 0.85);
        DENSITY_MAP.put("brown sugar", 0.77);
        DENSITY_MAP.put("salt", 1.22);
        DENSITY_MAP.put("rice", 0.78);
        DENSITY_MAP.put("white rice", 0.78);
        DENSITY_MAP.put("brown rice", 0.78);
        DENSITY_MAP.put("bread", 0.45);
        DENSITY_MAP.put("honey", 1.42);
        DENSITY_MAP.put("cocoa powder", 0.53);
        DENSITY_MAP.put("almond", 0.58);
        DENSITY_MAP.put("almonds", 0.58);
        DENSITY_MAP.put("walnut", 0.58);
        DENSITY_MAP.put("walnuts", 0.58);
        DENSITY_MAP.put("peanut", 0.65);
        DENSITY_MAP.put("peanuts", 0.65);
        DENSITY_MAP.put("cashew", 0.65);
    }

    @Override
    public EstimatedNutrition estimate(List<ParsedIngredientLine> ingredients) {
        if (ingredients == null || ingredients.isEmpty()) {
            return emptyNutrition();
        }

        double totalCalories = 0, totalProtein = 0, totalCarbs = 0, totalFat = 0;
        double totalFiber = 0, totalSugar = 0, totalSodium = 0;
        int matchedCount = 0;
        Map<String, Double> perIngredientCalories = new HashMap<>();

        for (ParsedIngredientLine ing : ingredients) {
            if (ing.getName() == null || ing.getName().isBlank()) continue;

            double[] per100g = lookupNutrition(ing.getName());
            double grams = estimateGrams(ing);

            if (per100g != null && grams > 0) {
                double factor = grams / 100.0;
                double cals = per100g[0] * factor;
                totalCalories += cals;
                totalProtein += per100g[1] * factor;
                totalCarbs += per100g[2] * factor;
                totalFat += per100g[3] * factor;
                totalFiber += per100g[4] * factor;
                totalSugar += per100g[5] * factor;
                totalSodium += per100g[6] * factor;
                perIngredientCalories.put(ing.getName(), cals);
                matchedCount++;
            } else {
                log.debug("No nutrition data for: {}", ing.getName());
            }
        }

        EstimatedNutrition nutrition = new EstimatedNutrition();
        nutrition.setCalories(round(totalCalories));
        nutrition.setProteinGrams(round(totalProtein));
        nutrition.setCarbsGrams(round(totalCarbs));
        nutrition.setFatGrams(round(totalFat));
        nutrition.setFiberGrams(round(totalFiber));
        nutrition.setSugarGrams(round(totalSugar));
        nutrition.setSodiumGrams(round(totalSodium));
        nutrition.setPerIngredientCalories(perIngredientCalories);

        double confidence = ingredients.isEmpty() ? 0 : (double) matchedCount / ingredients.size();
        confidence = Math.min(confidence + 0.2, 1.0);
        nutrition.setConfidenceScore(round(confidence));

        return nutrition;
    }

    @Override
    public EstimatedNutrition estimate(ParsedRecipe recipe) {
        if (recipe == null || recipe.getIngredients() == null || recipe.getIngredients().isEmpty()) {
            return emptyNutrition();
        }
        EstimatedNutrition nutrition = estimate(recipe.getIngredients());
        if (recipe.getServings() != null && recipe.getServings() > 0) {
            nutrition.setServings(recipe.getServings());
        }
        return nutrition;
    }

    @Override
    public boolean canEstimate(List<ParsedIngredientLine> ingredients) {
        if (ingredients == null || ingredients.isEmpty()) return false;
        return ingredients.stream().anyMatch(i -> i.getName() != null && !i.getName().isBlank());
    }

    private double[] lookupNutrition(String ingredientName) {
        if (ingredientName == null) return null;
        String normalized = StringNormalizer.normalize(ingredientName);

        if (NUTRITION_DB.containsKey(normalized)) return NUTRITION_DB.get(normalized);

        String[] words = normalized.split("\\s+");
        Optional<String> match = NUTRITION_DB.keySet().stream()
            .filter(key -> {
                String[] keyWords = key.split("\\s+");
                for (String kw : keyWords) {
                    for (String w : words) {
                        if (w.equals(kw)) return true;
                    }
                }
                return false;
            })
            .findFirst();
        if (match.isPresent()) return NUTRITION_DB.get(match.get());

        for (String key : NUTRITION_DB.keySet()) {
            if (StringNormalizer.isSimilar(normalized, key, 0.7)) {
                return NUTRITION_DB.get(key);
            }
        }

        return null;
    }

    private double estimateGrams(ParsedIngredientLine ing) {
        if (ing.getQuantity() == null || ing.getQuantity() <= 0) {
            return estimateDefaultServing(ing.getName());
        }

        if (ing.getUnit() == null || ing.getUnit().isBlank()) {
            return ing.getQuantity() * estimateDefaultServing(ing.getName()) / 100.0;
        }

        Double grams = UnitConverter.convertToGrams(ing.getQuantity(), ing.getUnit());
        if (grams != null) return grams;

        Double ml = UnitConverter.convertToMilliliters(ing.getQuantity(), ing.getUnit());
        if (ml != null) {
            double density = DENSITY_MAP.getOrDefault(
                StringNormalizer.normalize(ing.getName()), FALLBACK_DENSITY);
            return ml * density;
        }

        if (ing.getUnit().equalsIgnoreCase("clove") || ing.getUnit().equalsIgnoreCase("cloves")) {
            return ing.getQuantity() * 4;
        }
        if (ing.getUnit().equalsIgnoreCase("piece") || ing.getUnit().equalsIgnoreCase("pieces")) {
            return ing.getQuantity() * 50;
        }
        if (ing.getUnit().equalsIgnoreCase("slice") || ing.getUnit().equalsIgnoreCase("slices")) {
            return ing.getQuantity() * 20;
        }
        if (ing.getUnit().equalsIgnoreCase("whole")) {
            return ing.getQuantity() * 100;
        }

        return ing.getQuantity() * 30;
    }

    private double estimateDefaultServing(String name) {
        if (name == null) return 30;
        String n = name.toLowerCase();
        if (n.contains("oil") || n.contains("butter")) return 15;
        if (n.contains("salt") || n.contains("pepper") || n.contains("spice") || n.contains("herb")) return 2;
        if (n.contains("garlic") || n.contains("ginger")) return 5;
        if (n.contains("egg")) return 50;
        if (n.contains("milk") || n.contains("cream") || n.contains("yogurt")) return 100;
        if (n.contains("cheese")) return 30;
        if (n.contains("chicken") || n.contains("beef") || n.contains("pork") || n.contains("fish")) return 150;
        if (n.contains("rice") || n.contains("pasta") || n.contains("bread") || n.contains("flour")) return 80;
        if (n.contains("vegetable") || n.contains("lettuce") || n.contains("spinach")) return 50;
        if (n.contains("fruit") || n.contains("apple") || n.contains("banana") || n.contains("orange")) return 100;
        if (n.contains("sauce") || n.contains("broth")) return 30;
        return 30;
    }

    private EstimatedNutrition emptyNutrition() {
        EstimatedNutrition nutrition = new EstimatedNutrition();
        nutrition.setCalories(0.0);
        nutrition.setProteinGrams(0.0);
        nutrition.setCarbsGrams(0.0);
        nutrition.setFatGrams(0.0);
        nutrition.setFiberGrams(0.0);
        nutrition.setSugarGrams(0.0);
        nutrition.setSodiumGrams(0.0);
        nutrition.setConfidenceScore(0.0);
        return nutrition;
    }

    private double round(double value) {
        return Math.round(value * 100.0) / 100.0;
    }
}
