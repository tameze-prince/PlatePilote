package com.platepilote.platepilote.recommendation.domain.service;

import com.platepilote.platepilote.admin.domain.entity.SystemSetting;
import com.platepilote.platepilote.admin.domain.repository.SystemSettingRepository;
import com.platepilote.platepilote.authentication.domain.entity.OurUser;
import com.platepilote.platepilote.authentication.domain.repository.UserRepository;
import com.platepilote.platepilote.budget.domain.entity.Budget;
import com.platepilote.platepilote.budget.domain.repository.BudgetRepository;
import com.platepilote.platepilote.common.kernel.BusinessRuleViolationException;
import com.platepilote.platepilote.ingredients.application.service.IngredientResolutionService;
import com.platepilote.platepilote.optimization.application.service.BudgetOptimizer;
import com.platepilote.platepilote.optimization.application.service.PantryUtilizationScorer;
import com.platepilote.platepilote.preferences.domain.entity.Allergy;
import com.platepilote.platepilote.preferences.domain.entity.DietaryPreference;
import com.platepilote.platepilote.preferences.domain.repository.AllergyRepository;
import com.platepilote.platepilote.preferences.domain.repository.DietaryPreferenceRepository;
import com.platepilote.platepilote.recipes.domain.entity.Recipe;
import com.platepilote.platepilote.recipes.domain.entity.RecipeIngredient;
import com.platepilote.platepilote.recipes.domain.repository.RecipeIngredientRepository;
import com.platepilote.platepilote.recipes.domain.repository.RecipeRepository;
import com.platepilote.platepilote.recommendation.domain.entity.RecommendationEvent;
import com.platepilote.platepilote.recommendation.domain.repository.RecommendationEventRepository;
import com.platepilote.platepilote.subscription.application.service.EntitlementService;
import com.platepilote.platepilote.userprofile.domain.entity.UserProfile;
import com.platepilote.platepilote.userprofile.domain.repository.UserProfileRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.Duration;
import java.time.Instant;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class RecommendationEngine {

    private static final int DEFAULT_FREE_WEEKLY_LIMIT = 20;

    private final RecipeRepository recipeRepository;
    private final RecipeIngredientRepository recipeIngredientRepository;
    private final DietaryPreferenceRepository dietaryPreferenceRepository;
    private final AllergyRepository allergyRepository;
    private final BudgetRepository budgetRepository;
    private final UserProfileRepository userProfileRepository;
    private final UserRepository userRepository;
    private final SystemSettingRepository systemSettingRepository;
    private final RecommendationEventRepository recommendationEventRepository;
    private final BudgetOptimizer budgetOptimizer;
    private final PantryUtilizationScorer pantryUtilizationScorer;
    private final IngredientResolutionService ingredientResolutionService;
    private final EntitlementService entitlementService;

    @Transactional
    public List<RecommendationResult> getRecommendations(UUID userId, int limit) {
        return recommend(userId, "STANDARD", null, limit);
    }

    @Transactional
    public List<RecommendationResult> getQuickMeals(UUID userId, int maxTime, int limit) {
        return recommend(userId, "QUICK_MEAL", maxTime, limit);
    }

    @Transactional
    public List<List<RecommendationResult>> generateWeeklyMealPlan(UUID userId) {
        List<RecommendationResult> allRecommendations = recommend(userId, "WEEKLY_PLAN", null, 50);
        List<List<RecommendationResult>> weeklyPlan = new ArrayList<>();

        int recipeIndex = 0;
        for (int day = 0; day < 7; day++) {
            List<RecommendationResult> dayMeals = new ArrayList<>();
            for (int meal = 0; meal < 3; meal++) {
                if (recipeIndex < allRecommendations.size()) {
                    dayMeals.add(allRecommendations.get(recipeIndex++));
                }
            }
            weeklyPlan.add(dayMeals);
        }
        return weeklyPlan;
    }

    private List<RecommendationResult> recommend(UUID userId, String requestType, Integer maxTime, int limit) {
        Instant started = Instant.now();
        UserContext context = loadContext(userId);
        enforceQuota(context, requestType);

        List<Recipe> candidates = maxTime == null
                ? recipeRepository.findByIsPublicTrueAndDeletedAtIsNull(PageRequest.of(0, 500)).getContent()
                : recipeRepository.findQuickMeals(maxTime, PageRequest.of(0, 200)).getContent();

        List<RecommendationResult> results = candidates.stream()
                .filter(this::isEligibleForRecommendation)
                .filter(recipe -> !isExcludedByAllergies(recipe, context.allergies()))
                .filter(recipe -> !isExcludedByDiet(recipe, context.preferences()))
                .map(recipe -> score(recipe, context))
                .filter(result -> result.finalScore() > 0)
                .sorted(Comparator.comparingDouble(RecommendationResult::finalScore).reversed())
                .limit(Math.max(1, Math.min(limit, 50)))
                .collect(Collectors.toList());

        recordEvent(userId, requestType, context, results.size(), started, false);
        return results;
    }

    private UserContext loadContext(UUID userId) {
        UserProfile profile = userProfileRepository.findByUserId(userId).orElse(null);
        return new UserContext(
                userId,
                profile == null || profile.getCountryCode() == null ? "US" : profile.getCountryCode().toUpperCase(Locale.ROOT),
                profile == null || profile.getCurrencyCode() == null ? "USD" : profile.getCurrencyCode().toUpperCase(Locale.ROOT),
                profile == null ? "en-US" : valueOrDefault(profile.getLocale(), "en-US"),
                profile == null ? "BEGINNER" : valueOrDefault(profile.getCookingSkill(), "BEGINNER").toUpperCase(Locale.ROOT),
                profile == null ? 1 : Math.max(1, profile.getHouseholdSize() == null ? 1 : profile.getHouseholdSize()),
                profile == null ? "" : valueOrDefault(profile.getHealthGoals(), ""),
                dietaryPreferenceRepository.findByUserId(userId),
                allergyRepository.findByUserId(userId),
                getWeeklyBudget(userId),
                isPremium(userId)
        );
    }

    private void enforceQuota(UserContext context, String requestType) {
        if (context.premium()) {
            return;
        }
        int limit = systemSettingRepository.findBySettingKey("free_weekly_recommendation_limit")
                .map(SystemSetting::getSettingValue)
                .map(value -> {
                    try {
                        return Integer.parseInt(value);
                    } catch (NumberFormatException ignored) {
                        return DEFAULT_FREE_WEEKLY_LIMIT;
                    }
                })
                .orElse(DEFAULT_FREE_WEEKLY_LIMIT);
        long used = recommendationEventRepository.countByUserIdAndCreatedAtAfterAndQuotaLimitedFalse(
                context.userId(), Instant.now().minus(Duration.ofDays(7)));
        if (used >= limit) {
            recordEvent(context.userId(), requestType, context, 0, Instant.now(), true);
            throw new BusinessRuleViolationException("Free recommendation limit reached for this week");
        }
    }

    private RecommendationResult score(Recipe recipe, UserContext context) {
        RecommendationWeights weights = loadWeights();
        BigDecimal estimatedCost = estimateCost(recipe, context.countryCode());
        double pantryScore = pantryUtilizationScorer.calculatePantryScore(context.userId(), recipe.getId());
        double budgetScore = calculateBudgetScore(estimatedCost, context.weeklyBudget());
        double preferenceScore = calculatePreferenceScore(recipe, context.preferences());
        double nutritionScore = calculateNutritionScore(recipe, context.healthGoals());
        double timeScore = calculateTimeScore(recipe);
        double varietyScore = calculateVarietyScore(recipe);
        double locationScore = calculateLocationScore(recipe, context.countryCode());

        double finalScore = pantryScore * weights.pantry()
                + budgetScore * weights.budget()
                + preferenceScore * weights.preference()
                + nutritionScore * weights.nutrition()
                + timeScore * weights.time()
                + varietyScore * weights.variety()
                + locationScore * weights.location();

        List<String> reasons = buildReasons(recipe, pantryScore, budgetScore, preferenceScore,
                nutritionScore, timeScore, locationScore, context);
        List<String> warnings = buildWarnings(recipe);

        return new RecommendationResult(recipe, round(finalScore), round(budgetScore), round(pantryScore),
                round(timeScore), round(preferenceScore), round(nutritionScore), round(varietyScore),
                round(locationScore), estimatedCost, context.currencyCode(), context.countryCode(),
                reasons, warnings);
    }

    private boolean isExcludedByAllergies(Recipe recipe, List<Allergy> allergies) {
        if (allergies.isEmpty()) {
            return false;
        }
        List<RecipeIngredient> ingredients = recipeIngredientRepository.findByRecipeIdOrderBySortOrderAsc(recipe.getId());
        for (Allergy allergy : allergies) {
            String allergen = ingredientResolutionService.normalize(allergy.getAllergen());
            if (allergen.isBlank()) {
                continue;
            }
            if (matchesAllergenFlag(recipe, allergen)) {
                return true;
            }
            for (RecipeIngredient ingredient : ingredients) {
                String recipeIngredient = ingredientResolutionService.normalize(ingredient.getName());
                if (recipeIngredient.contains(allergen) || allergen.contains(recipeIngredient)) {
                    return true;
                }
            }
        }
        return false;
    }

    private boolean isEligibleForRecommendation(Recipe recipe) {
        if (Boolean.FALSE.equals(recipe.getEnabled())) {
            return false;
        }
        String status = recipe.getVerificationStatus();
        return status == null
                || !"REJECTED".equalsIgnoreCase(status)
                && !"DISABLED".equalsIgnoreCase(status);
    }

    private boolean matchesAllergenFlag(Recipe recipe, String allergen) {
        return switch (allergen) {
            case "gluten", "wheat", "barley" -> Boolean.TRUE.equals(recipe.getContainsGluten());
            case "lactose", "dairy", "milk", "cheese" -> Boolean.TRUE.equals(recipe.getContainsLactose());
            case "nut", "nuts", "peanut", "groundnut", "almond", "cashew", "walnut" -> Boolean.TRUE.equals(recipe.getContainsNuts());
            case "soy", "soya" -> Boolean.TRUE.equals(recipe.getContainsSoy());
            case "egg", "eggs" -> Boolean.TRUE.equals(recipe.getContainsEggs());
            case "fish" -> Boolean.TRUE.equals(recipe.getContainsFish());
            case "shellfish", "shrimp", "prawn", "crab" -> Boolean.TRUE.equals(recipe.getContainsShellfish());
            default -> false;
        };
    }

    private boolean isExcludedByDiet(Recipe recipe, List<DietaryPreference> preferences) {
        for (DietaryPreference pref : preferences) {
            String diet = ingredientResolutionService.normalize(pref.getDietType());
            switch (diet) {
                case "vegetarian" -> {
                    if (Boolean.FALSE.equals(recipe.getVegetarian())) return true;
                }
                case "vegan" -> {
                    if (Boolean.FALSE.equals(recipe.getVegan())) return true;
                }
                case "gluten free" -> {
                    if (Boolean.TRUE.equals(recipe.getContainsGluten())) return true;
                }
                case "dairy free" -> {
                    if (Boolean.TRUE.equals(recipe.getContainsLactose())) return true;
                }
                case "nut free" -> {
                    if (Boolean.TRUE.equals(recipe.getContainsNuts())) return true;
                }
                case "keto", "ketogenic" -> {
                    if (Boolean.FALSE.equals(recipe.getKetoFriendly())) return true;
                }
                case "low carb" -> {
                    if (Boolean.FALSE.equals(recipe.getLowCarb())) return true;
                }
                case "halal" -> {
                    if (Boolean.FALSE.equals(recipe.getHalalFriendly())) return true;
                }
                default -> {
                    // Cuisine preferences are scored softly, not excluded.
                }
            }
        }
        return false;
    }

    private BigDecimal estimateCost(Recipe recipe, String countryCode) {
        BigDecimal local = budgetOptimizer.estimateRecipeCost(recipe.getId(), countryCode);
        if (local.compareTo(BigDecimal.ZERO) > 0) {
            return local;
        }
        return recipe.getEstimatedCost() == null ? BigDecimal.ZERO : recipe.getEstimatedCost();
    }

    private BigDecimal getWeeklyBudget(UUID userId) {
        return budgetRepository.findByUserIdAndDeletedAtIsNull(userId, PageRequest.of(0, 1))
                .stream()
                .findFirst()
                .map(Budget::getAmount)
                .orElse(BigDecimal.valueOf(200));
    }

    private boolean isPremium(UUID userId) {
        if (entitlementService.hasActiveEntitlement(userId, EntitlementService.PREMIUM_ENTITLEMENT)) {
            return true;
        }
        return userRepository.findById(userId)
                .map(OurUser::getRoles)
                .orElseGet(java.util.Set::of)
                .stream()
                .anyMatch(role -> "ROLE_PREMIUM_USER".equals(role.getName())
                        || "ROLE_ADMIN".equals(role.getName())
                        || "ROLE_SUPER_ADMIN".equals(role.getName()));
    }

    private RecommendationWeights loadWeights() {
        RecommendationWeights configured = new RecommendationWeights(
                getWeight("recommendation_weight_pantry", 0.25),
                getWeight("recommendation_weight_budget", 0.20),
                getWeight("recommendation_weight_preference", 0.20),
                getWeight("recommendation_weight_nutrition", 0.15),
                getWeight("recommendation_weight_time", 0.10),
                getWeight("recommendation_weight_variety", 0.05),
                getWeight("recommendation_weight_location", 0.05)
        );
        double total = configured.total();
        if (total <= 0) {
            return new RecommendationWeights(0.25, 0.20, 0.20, 0.15, 0.10, 0.05, 0.05);
        }
        return configured.normalize(total);
    }

    private double getWeight(String key, double fallback) {
        return systemSettingRepository.findBySettingKey(key)
                .map(SystemSetting::getSettingValue)
                .map(value -> {
                    try {
                        return Double.parseDouble(value);
                    } catch (NumberFormatException ignored) {
                        return fallback;
                    }
                })
                .filter(value -> value >= 0)
                .orElse(fallback);
    }

    private double calculateBudgetScore(BigDecimal estimatedCost, BigDecimal weeklyBudget) {
        if (estimatedCost == null || weeklyBudget == null || weeklyBudget.compareTo(BigDecimal.ZERO) <= 0) {
            return 0.5;
        }
        double ratio = estimatedCost.doubleValue() / weeklyBudget.doubleValue();
        if (ratio > 0.50) {
            return 0.0;
        }
        return Math.max(0.0, 1.0 - ratio);
    }

    private double calculatePreferenceScore(Recipe recipe, List<DietaryPreference> preferences) {
        double score = 0.5;
        for (DietaryPreference pref : preferences) {
            String preference = ingredientResolutionService.normalize(pref.getDietType());
            if (matchesDietaryFlag(recipe, preference)) {
                score += 0.15;
            }
            if (recipe.getCuisineType() != null
                    && ingredientResolutionService.normalize(recipe.getCuisineType()).contains(preference)) {
                score += 0.25;
            }
        }
        return Math.min(1.0, score);
    }

    private boolean matchesDietaryFlag(Recipe recipe, String dietType) {
        return switch (dietType) {
            case "vegetarian" -> Boolean.TRUE.equals(recipe.getVegetarian());
            case "vegan" -> Boolean.TRUE.equals(recipe.getVegan());
            case "gluten free" -> Boolean.FALSE.equals(recipe.getContainsGluten());
            case "dairy free" -> Boolean.FALSE.equals(recipe.getContainsLactose());
            case "nut free" -> Boolean.FALSE.equals(recipe.getContainsNuts());
            case "keto", "ketogenic" -> Boolean.TRUE.equals(recipe.getKetoFriendly());
            case "low carb" -> Boolean.TRUE.equals(recipe.getLowCarb());
            case "halal" -> Boolean.TRUE.equals(recipe.getHalalFriendly());
            default -> false;
        };
    }

    private double calculateNutritionScore(Recipe recipe, String goals) {
        String normalizedGoals = ingredientResolutionService.normalize(goals);
        if (normalizedGoals.isBlank()) {
            return 0.7;
        }
        double score = 0.5;
        if (normalizedGoals.contains("protein") || normalizedGoals.contains("muscle")) {
            score += recipe.getProteinPerServing() != null && recipe.getProteinPerServing() >= 25 ? 0.3 : 0;
        }
        if (normalizedGoals.contains("weight") || normalizedGoals.contains("loss")) {
            score += recipe.getCaloriesPerServing() != null && recipe.getCaloriesPerServing() <= 650 ? 0.2 : 0;
        }
        if (normalizedGoals.contains("low carb")) {
            score += Boolean.TRUE.equals(recipe.getLowCarb()) ? 0.3 : 0;
        }
        if (normalizedGoals.contains("fiber")) {
            score += recipe.getFiberPerServing() != null && recipe.getFiberPerServing() >= 6 ? 0.2 : 0;
        }
        return Math.min(1.0, score);
    }

    private double calculateTimeScore(Recipe recipe) {
        if (recipe.getTotalTimeMinutes() == null) {
            return 0.7;
        }
        if (recipe.getTotalTimeMinutes() <= 15) return 1.0;
        if (recipe.getTotalTimeMinutes() <= 30) return 0.85;
        if (recipe.getTotalTimeMinutes() <= 60) return 0.60;
        return 0.30;
    }

    private double calculateVarietyScore(Recipe recipe) {
        return recipe.getCuisineType() != null && recipe.getMealType() != null ? 0.8 : 0.5;
    }

    private double calculateLocationScore(Recipe recipe, String countryCode) {
        if (recipe.getCuisineType() == null) {
            return 0.5;
        }
        String cuisine = ingredientResolutionService.normalize(recipe.getCuisineType());
        Map<String, List<String>> regionalCuisines = Map.of(
                "CM", List.of("cameroonian", "west african", "african"),
                "FR", List.of("french", "mediterranean"),
                "DE", List.of("german", "european"),
                "GB", List.of("british", "indian"),
                "US", List.of("american", "mexican"),
                "IN", List.of("indian"),
                "CN", List.of("chinese", "asian"),
                "JP", List.of("japanese", "asian")
        );
        return regionalCuisines.getOrDefault(countryCode, List.of()).stream()
                .anyMatch(cuisine::contains) ? 1.0 : 0.55;
    }

    private List<String> buildReasons(Recipe recipe, double pantryScore, double budgetScore,
                                      double preferenceScore, double nutritionScore, double timeScore,
                                      double locationScore, UserContext context) {
        List<String> reasons = new ArrayList<>();
        if (pantryScore >= 0.5) reasons.add("Uses ingredients that match your pantry");
        if (budgetScore >= 0.75) reasons.add("Fits your weekly budget");
        if (preferenceScore >= 0.75) reasons.add("Matches your food preferences");
        if (nutritionScore >= 0.75) reasons.add("Supports your nutrition goals");
        if (timeScore >= 0.85) reasons.add("Ready quickly");
        if (locationScore >= 0.9) reasons.add("Relevant to your location");
        if (reasons.isEmpty()) reasons.add("Balanced option for your current profile");
        if (recipe.getCuisineType() != null) reasons.add("Cuisine: " + recipe.getCuisineType());
        reasons.add("Pricing region: " + context.countryCode() + " (" + context.currencyCode() + ")");
        return reasons;
    }

    private List<String> buildWarnings(Recipe recipe) {
        List<String> warnings = new ArrayList<>();
        if (Boolean.TRUE.equals(recipe.getContainsGluten())) warnings.add("Contains gluten");
        if (Boolean.TRUE.equals(recipe.getContainsLactose())) warnings.add("Contains lactose/dairy");
        if (Boolean.TRUE.equals(recipe.getContainsNuts())) warnings.add("Contains nuts");
        if (Boolean.TRUE.equals(recipe.getContainsSoy())) warnings.add("Contains soy");
        if (Boolean.TRUE.equals(recipe.getContainsEggs())) warnings.add("Contains eggs");
        if (Boolean.TRUE.equals(recipe.getContainsFish())) warnings.add("Contains fish");
        if (Boolean.TRUE.equals(recipe.getContainsShellfish())) warnings.add("Contains shellfish");
        if (!Boolean.TRUE.equals(recipe.getVerified())) warnings.add("Recipe has not been professionally verified");
        if (recipe.getConfidenceScore() != null && recipe.getConfidenceScore() < 0.7) {
            warnings.add("Nutrition and allergen details are estimates");
        }
        return warnings;
    }

    private void recordEvent(UUID userId, String requestType, UserContext context, int resultCount,
                             Instant started, boolean quotaLimited) {
        int durationMs = (int) Duration.between(started, Instant.now()).toMillis();
        recommendationEventRepository.save(RecommendationEvent.builder()
                .userId(userId)
                .requestType(requestType)
                .countryCode(context.countryCode())
                .currencyCode(context.currencyCode())
                .resultCount(resultCount)
                .durationMs(durationMs)
                .quotaLimited(quotaLimited)
                .build());
    }

    private String valueOrDefault(String value, String fallback) {
        return value == null || value.isBlank() ? fallback : value.trim();
    }

    private double round(double value) {
        return Math.round(value * 100.0) / 100.0;
    }

    private record UserContext(
            UUID userId,
            String countryCode,
            String currencyCode,
            String locale,
            String cookingSkill,
            int householdSize,
            String healthGoals,
            List<DietaryPreference> preferences,
            List<Allergy> allergies,
            BigDecimal weeklyBudget,
            boolean premium
    ) {}

    private record RecommendationWeights(
            double pantry,
            double budget,
            double preference,
            double nutrition,
            double time,
            double variety,
            double location
    ) {
        double total() {
            return pantry + budget + preference + nutrition + time + variety + location;
        }

        RecommendationWeights normalize(double total) {
            return new RecommendationWeights(
                    pantry / total,
                    budget / total,
                    preference / total,
                    nutrition / total,
                    time / total,
                    variety / total,
                    location / total
            );
        }
    }

    public record RecommendationResult(
            Recipe recipe,
            double finalScore,
            double budgetScore,
            double pantryScore,
            double timeScore,
            double preferenceScore,
            double nutritionScore,
            double varietyScore,
            double locationScore,
            BigDecimal estimatedCost,
            String currencyCode,
            String countryCode,
            List<String> reasons,
            List<String> warnings
    ) {}
}
