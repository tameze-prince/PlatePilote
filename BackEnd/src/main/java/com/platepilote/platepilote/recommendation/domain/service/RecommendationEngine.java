package com.platepilote.platepilote.recommendation.domain.service;

import com.platepilote.platepilote.budget.domain.entity.Budget;
import com.platepilote.platepilote.budget.domain.repository.BudgetRepository;
import com.platepilote.platepilote.ingredients.domain.entity.Ingredient;
import com.platepilote.platepilote.ingredients.domain.repository.IngredientRepository;
import com.platepilote.platepilote.optimization.application.service.BudgetOptimizer;
import com.platepilote.platepilote.optimization.application.service.PantryUtilizationScorer;
import com.platepilote.platepilote.pantry.domain.entity.PantryItem;
import com.platepilote.platepilote.pantry.domain.repository.PantryItemRepository;
import com.platepilote.platepilote.preferences.domain.entity.Allergy;
import com.platepilote.platepilote.preferences.domain.entity.DietaryPreference;
import com.platepilote.platepilote.preferences.domain.repository.AllergyRepository;
import com.platepilote.platepilote.preferences.domain.repository.DietaryPreferenceRepository;
import com.platepilote.platepilote.recipes.domain.entity.Recipe;
import com.platepilote.platepilote.recipes.domain.entity.RecipeIngredient;
import com.platepilote.platepilote.recipes.domain.repository.RecipeIngredientRepository;
import com.platepilote.platepilote.recipes.domain.repository.RecipeRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class RecommendationEngine {

    private final RecipeRepository recipeRepository;
    private final RecipeIngredientRepository recipeIngredientRepository;
    private final DietaryPreferenceRepository dietaryPreferenceRepository;
    private final AllergyRepository allergyRepository;
    private final PantryItemRepository pantryItemRepository;
    private final BudgetRepository budgetRepository;
    private final IngredientRepository ingredientRepository;
    private final BudgetOptimizer budgetOptimizer;
    private final PantryUtilizationScorer pantryUtilizationScorer;

    @Transactional(readOnly = true)
    public List<RecommendationResult> getRecommendations(UUID userId, int limit) {
        List<DietaryPreference> preferences = dietaryPreferenceRepository.findByUserId(userId);
        List<Allergy> allergies = allergyRepository.findByUserId(userId);
        List<PantryItem> pantryItems = pantryItemRepository
                .findByUserIdAndDeletedAtIsNull(userId, PageRequest.of(0, 100))
                .getContent();
        BigDecimal weeklyBudget = getWeeklyBudget(userId);
        Map<UUID, String> preferredCuisines = getPreferredCuisines(preferences);

        List<Recipe> allPublicRecipes = recipeRepository
                .findByIsPublicTrueAndDeletedAtIsNull(PageRequest.of(0, 200))
                .getContent();

        List<ScoredRecipe> scored = new ArrayList<>();

        for (Recipe recipe : allPublicRecipes) {
            if (isExcludedByAllergies(recipe, allergies)) continue;
            if (isExcludedByDiet(recipe, preferences)) continue;

            double budgetScore = calculateBudgetScore(recipe, weeklyBudget);
            double pantryScore = pantryUtilizationScorer.calculatePantryScore(userId, recipe.getId());
            double timeScore = calculateTimeScore(recipe);
            double skillScore = calculateSkillScore(recipe);
            double preferenceScore = calculatePreferenceScore(recipe, preferences, preferredCuisines);
            double varietyScore = calculateVarietyScore(recipe, preferences);

            double finalScore = budgetScore * 0.25 +
                                pantryScore * 0.25 +
                                timeScore * 0.15 +
                                skillScore * 0.10 +
                                preferenceScore * 0.15 +
                                varietyScore * 0.10;

            if (finalScore > 0) {
                scored.add(new ScoredRecipe(recipe, finalScore, budgetScore, pantryScore,
                        timeScore, skillScore, preferenceScore, varietyScore));
            }
        }

        return scored.stream()
                .sorted(Comparator.<ScoredRecipe>comparingDouble(s -> s.finalScore).reversed())
                .limit(limit)
                .map(s -> new RecommendationResult(s.recipe, s.finalScore, s.budgetScore,
                        s.pantryScore, s.timeScore, s.skillScore, s.preferenceScore, s.varietyScore))
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<RecommendationResult> getQuickMeals(UUID userId, int maxTime, int limit) {
        List<Recipe> quickRecipes = recipeRepository
                .findQuickMeals(maxTime, PageRequest.of(0, 50))
                .getContent();

        List<DietaryPreference> preferences = dietaryPreferenceRepository.findByUserId(userId);
        List<Allergy> allergies = allergyRepository.findByUserId(userId);
        List<PantryItem> pantryItems = pantryItemRepository
                .findByUserIdAndDeletedAtIsNull(userId, PageRequest.of(0, 100))
                .getContent();

        List<ScoredRecipe> scored = new ArrayList<>();
        for (Recipe recipe : quickRecipes) {
            if (isExcludedByAllergies(recipe, allergies)) continue;
            if (isExcludedByDiet(recipe, preferences)) continue;

            double pantryScore = pantryUtilizationScorer.calculatePantryScore(userId, recipe.getId());
            double preferenceScore = calculatePreferenceScore(recipe, preferences, getPreferredCuisines(preferences));

            double finalScore = pantryScore * 0.50 + preferenceScore * 0.50;

            if (finalScore > 0) {
                scored.add(new ScoredRecipe(recipe, finalScore, 1.0, pantryScore,
                        1.0, 1.0, preferenceScore, 0.5));
            }
        }

        return scored.stream()
                .sorted(Comparator.<ScoredRecipe>comparingDouble(s -> s.finalScore).reversed())
                .limit(limit)
                .map(s -> new RecommendationResult(s.recipe, s.finalScore, s.budgetScore,
                        s.pantryScore, s.timeScore, s.skillScore, s.preferenceScore, s.varietyScore))
                .collect(Collectors.toList());
    }

    private boolean isExcludedByAllergies(Recipe recipe, List<Allergy> allergies) {
        if (allergies.isEmpty()) return false;
        for (Allergy allergy : allergies) {
            String allergen = allergy.getAllergen().toLowerCase();
            switch (allergen) {
                case "gluten": if (Boolean.TRUE.equals(recipe.getContainsGluten())) return true; break;
                case "lactose":
                case "dairy": if (Boolean.TRUE.equals(recipe.getContainsLactose())) return true; break;
                case "nuts": if (Boolean.TRUE.equals(recipe.getContainsNuts())) return true; break;
                case "soy": if (Boolean.TRUE.equals(recipe.getContainsSoy())) return true; break;
                case "eggs": if (Boolean.TRUE.equals(recipe.getContainsEggs())) return true; break;
                case "fish": if (Boolean.TRUE.equals(recipe.getContainsFish())) return true; break;
                case "shellfish": if (Boolean.TRUE.equals(recipe.getContainsShellfish())) return true; break;
                default:
                    if (recipe.getDescription() != null &&
                        recipe.getDescription().toLowerCase().contains(allergen)) return true;
            }
        }
        return false;
    }

    private boolean isExcludedByDiet(Recipe recipe, List<DietaryPreference> preferences) {
        for (DietaryPreference pref : preferences) {
            String diet = pref.getDietType().toLowerCase();
            switch (diet) {
                case "vegetarian": if (Boolean.FALSE.equals(recipe.getVegetarian())) return true; break;
                case "vegan": if (Boolean.FALSE.equals(recipe.getVegan())) return true; break;
                case "gluten-free": if (Boolean.TRUE.equals(recipe.getContainsGluten())) return true; break;
                case "dairy-free": if (Boolean.TRUE.equals(recipe.getContainsLactose())) return true; break;
                case "nut-free": if (Boolean.TRUE.equals(recipe.getContainsNuts())) return true; break;
                case "keto":
                case "ketogenic": if (Boolean.FALSE.equals(recipe.getKetoFriendly())) return true; break;
                case "low-carb": if (Boolean.FALSE.equals(recipe.getLowCarb())) return true; break;
                case "halal": if (Boolean.FALSE.equals(recipe.getHalalFriendly())) return true; break;
            }
        }
        return false;
    }

    private BigDecimal getWeeklyBudget(UUID userId) {
        return budgetRepository.findByUserIdAndDeletedAtIsNull(userId, PageRequest.of(0, 1))
                .stream()
                .findFirst()
                .map(Budget::getAmount)
                .orElse(BigDecimal.valueOf(200));
    }

    private double calculateBudgetScore(Recipe recipe, BigDecimal weeklyBudget) {
        if (recipe.getEstimatedCost() == null || weeklyBudget == null) return 0.8;
        if (weeklyBudget.compareTo(BigDecimal.ZERO) <= 0) return 0.0;
        double ratio = recipe.getEstimatedCost().doubleValue() / weeklyBudget.doubleValue();
        if (ratio > 0.5) return 0.0;
        return Math.max(0, 1.0 - ratio);
    }

    private double calculateTimeScore(Recipe recipe) {
        if (recipe.getTotalTimeMinutes() == null) return 0.8;
        if (recipe.getTotalTimeMinutes() <= 15) return 1.0;
        if (recipe.getTotalTimeMinutes() <= 30) return 0.8;
        if (recipe.getTotalTimeMinutes() <= 60) return 0.5;
        if (recipe.getTotalTimeMinutes() <= 120) return 0.2;
        return 0.0;
    }

    private double calculateSkillScore(Recipe recipe) {
        if (recipe.getDifficulty() == null) return 0.8;
        return switch (recipe.getDifficulty().toLowerCase()) {
            case "easy" -> 1.0;
            case "medium" -> 0.6;
            case "hard" -> 0.2;
            default -> 0.8;
        };
    }

    private double calculatePreferenceScore(Recipe recipe, List<DietaryPreference> preferences,
                                             Map<UUID, String> preferredCuisines) {
        double score = 0.5;
        for (DietaryPreference pref : preferences) {
            String diet = pref.getDietType().toLowerCase();
            if (matchesDietaryFlag(recipe, diet)) score += 0.1;
        }
        if (recipe.getCuisineType() != null && preferredCuisines.containsValue(recipe.getCuisineType())) {
            score += 0.3;
        }
        return Math.min(1.0, score);
    }

    private double calculateVarietyScore(Recipe recipe, List<DietaryPreference> preferences) {
        if (recipe.getCuisineType() == null && recipe.getMealType() == null) return 0.5;
        return 0.8;
    }

    private boolean matchesDietaryFlag(Recipe recipe, String dietType) {
        return switch (dietType) {
            case "vegetarian" -> Boolean.TRUE.equals(recipe.getVegetarian());
            case "vegan" -> Boolean.TRUE.equals(recipe.getVegan());
            case "gluten-free" -> Boolean.FALSE.equals(recipe.getContainsGluten());
            case "dairy-free" -> Boolean.FALSE.equals(recipe.getContainsLactose());
            case "nut-free" -> Boolean.FALSE.equals(recipe.getContainsNuts());
            case "keto", "ketogenic" -> Boolean.TRUE.equals(recipe.getKetoFriendly());
            case "low-carb" -> Boolean.TRUE.equals(recipe.getLowCarb());
            case "halal" -> Boolean.TRUE.equals(recipe.getHalalFriendly());
            default -> false;
        };
    }

    private Map<UUID, String> getPreferredCuisines(List<DietaryPreference> preferences) {
        Map<UUID, String> cuisines = new HashMap<>();
        for (DietaryPreference pref : preferences) {
            String diet = pref.getDietType().toLowerCase();
            if (diet.equals("italian") || diet.equals("mexican") || diet.equals("asian") ||
                diet.equals("american") || diet.equals("indian") || diet.equals("japanese") ||
                diet.equals("chinese") || diet.equals("mediterranean")) {
                cuisines.put(pref.getId(), diet);
            }
        }
        return cuisines;
    }

    public List<List<RecommendationResult>> generateWeeklyMealPlan(UUID userId) {
        List<RecommendationResult> allRecommendations = getRecommendations(userId, 50);
        List<List<RecommendationResult>> weeklyPlan = new ArrayList<>();

        List<String> mealTypes = List.of("Breakfast", "Lunch", "Dinner");
        int recipeIndex = 0;

        for (int day = 0; day < 7; day++) {
            List<RecommendationResult> dayMeals = new ArrayList<>();
            for (String mealType : mealTypes) {
                if (recipeIndex < allRecommendations.size()) {
                    RecommendationResult result = allRecommendations.get(recipeIndex);
                    dayMeals.add(result);
                    recipeIndex++;
                }
            }
            weeklyPlan.add(dayMeals);
        }
        return weeklyPlan;
    }

    private record ScoredRecipe(
            Recipe recipe,
            double finalScore,
            double budgetScore,
            double pantryScore,
            double timeScore,
            double skillScore,
            double preferenceScore,
            double varietyScore
    ) {}

    public record RecommendationResult(
            Recipe recipe,
            double finalScore,
            double budgetScore,
            double pantryScore,
            double timeScore,
            double skillScore,
            double preferenceScore,
            double varietyScore
    ) {}
}
