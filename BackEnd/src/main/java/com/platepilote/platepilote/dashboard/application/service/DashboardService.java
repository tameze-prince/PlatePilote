package com.platepilote.platepilote.dashboard.application.service;

import com.platepilote.platepilote.authentication.domain.repository.UserRepository;
import com.platepilote.platepilote.budget.domain.repository.BudgetRepository;
import com.platepilote.platepilote.common.kernel.BusinessRuleViolationException;
import com.platepilote.platepilote.grocery.domain.entity.GroceryItem;
import com.platepilote.platepilote.grocery.domain.entity.GroceryList;
import com.platepilote.platepilote.grocery.domain.repository.GroceryItemRepository;
import com.platepilote.platepilote.grocery.domain.repository.GroceryListRepository;
import com.platepilote.platepilote.mealplanning.domain.entity.MealPlan;
import com.platepilote.platepilote.mealplanning.domain.repository.MealPlanRepository;
import com.platepilote.platepilote.notification.application.service.NotificationService;
import com.platepilote.platepilote.pantry.domain.entity.PantryItem;
import com.platepilote.platepilote.pantry.domain.repository.PantryItemRepository;
import com.platepilote.platepilote.recommendation.domain.service.RecommendationEngine;
import com.platepilote.platepilote.recommendation.domain.service.RecommendationEngine.RecommendationResult;
import com.platepilote.platepilote.subscription.domain.repository.SubscriptionRepository;
import com.platepilote.platepilote.userprofile.domain.repository.UserProfileRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class DashboardService {

    private final UserRepository userRepository;
    private final UserProfileRepository userProfileRepository;
    private final MealPlanRepository mealPlanRepository;
    private final GroceryListRepository groceryListRepository;
    private final GroceryItemRepository groceryItemRepository;
    private final PantryItemRepository pantryItemRepository;
    private final BudgetRepository budgetRepository;
    private final NotificationService notificationService;
    private final SubscriptionRepository subscriptionRepository;
    private final RecommendationEngine recommendationEngine;

    public DashboardResponse getHomeDashboard(UUID userId) {
        // Greeting - firstName is on OurUser entity, not UserProfile
        String firstName = userRepository.findById(userId)
                .map(user -> user.getFirstName())
                .orElse(null);

        // Subscription status
        String planType = subscriptionRepository.findByUserId(userId)
                .map(sub -> sub.getPlanType())
                .orElse("FREE");

        // Active meal plan (find most recent, check if ACTIVE)
        MealPlanSummary activePlan = mealPlanRepository
                .findByUserIdAndDeletedAtIsNull(userId, PageRequest.of(0, 10))
                .stream()
                .filter(p -> "ACTIVE".equals(p.getStatus()))
                .findFirst()
                .map(this::toMealPlanSummary)
                .orElse(null);

        // Active grocery list
        GrocerySummary grocerySummary = groceryListRepository
                .findByUserIdAndStatusAndDeletedAtIsNull(userId, "ACTIVE", PageRequest.of(0, 1))
                .stream()
                .findFirst()
                .map(this::toGrocerySummary)
                .orElse(null);

        // Pantry alerts
        PantrySummary pantrySummary = getPantrySummary(userId);

        // Budget summary
        BudgetSummary budgetSummary = budgetRepository
                .findByUserIdAndDeletedAtIsNull(userId, PageRequest.of(0, 1))
                .stream()
                .findFirst()
                .map(b -> new BudgetSummary(
                        b.getAmount(),
                        b.getSpent() != null ? b.getSpent() : BigDecimal.ZERO,
                        b.getCurrency() != null ? b.getCurrency() : "USD"
                ))
                .orElse(null);

        // Unread notifications count
        long unreadCount = notificationService.getUnreadCount(userId);

        // Top recommendations (limit 3) — gracefully skip if quota reached
        List<RecommendationDTO> recDTOs = List.of();
        try {
            List<RecommendationResult> recommendations = recommendationEngine.getRecommendations(userId, 3);
            recDTOs = recommendations.stream()
                    .map(r -> new RecommendationDTO(
                            r.recipe().getId(),
                            r.recipe().getName(),
                            r.recipe().getDescription(),
                            r.recipe().getImageUrl(),
                            r.recipe().getTotalTimeMinutes(),
                            r.recipe().getServings(),
                            r.recipe().getCuisineType(),
                            r.recipe().getMealType(),
                            r.estimatedCost(),
                            r.finalScore()
                    ))
                    .toList();
        } catch (BusinessRuleViolationException e) {
            // Recommendation quota reached — dashboard still works
        }

        // Determine next best action
        String nextAction = determineNextAction(activePlan, grocerySummary, pantrySummary);

        return new DashboardResponse(
                firstName,
                planType,
                activePlan,
                grocerySummary,
                pantrySummary,
                budgetSummary,
                unreadCount,
                recDTOs,
                nextAction
        );
    }

    private String determineNextAction(MealPlanSummary plan, GrocerySummary grocery, PantrySummary pantry) {
        if (plan == null) return "generate_plan";
        if (!"ACTIVE".equals(plan.status)) return "activate_plan";
        if (grocery == null) return "generate_grocery";
        if (grocery.checkedItems < grocery.totalItems) return "shop_grocery";
        if (pantry.expiringSoon > 0) return "use_pantry";
        return "explore_recipes";
    }

    private MealPlanSummary toMealPlanSummary(MealPlan plan) {
        return new MealPlanSummary(
                plan.getId(),
                plan.getName(),
                plan.getStatus(),
                plan.getStartDate() != null ? plan.getStartDate().toString() : null,
                plan.getEndDate() != null ? plan.getEndDate().toString() : null,
                0 // entries are in a separate table, not directly on MealPlan
        );
    }

    private GrocerySummary toGrocerySummary(GroceryList list) {
        List<GroceryItem> items = groceryItemRepository.findByGroceryListIdOrderBySortOrderAsc(list.getId());
        int total = items.size();
        int checked = (int) items.stream().filter(GroceryItem::getChecked).count();
        BigDecimal totalEstimate = items.stream()
                .map(GroceryItem::getEstimatedPrice)
                .filter(java.util.Objects::nonNull)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
        BigDecimal checkedEstimate = items.stream()
                .filter(GroceryItem::getChecked)
                .map(GroceryItem::getEstimatedPrice)
                .filter(java.util.Objects::nonNull)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        return new GrocerySummary(
                list.getId(),
                list.getName(),
                total,
                checked,
                totalEstimate,
                checkedEstimate
        );
    }

    private PantrySummary getPantrySummary(UUID userId) {
        List<PantryItem> allItems = pantryItemRepository.findByUserIdAndDeletedAtIsNull(
                userId, PageRequest.of(0, 200)).getContent();
        int total = allItems.size();
        LocalDate now = LocalDate.now();
        int expiringSoon = (int) allItems.stream()
                .filter(item -> item.getExpirationDate() != null)
                .filter(item -> {
                    long days = ChronoUnit.DAYS.between(now, item.getExpirationDate());
                    return days >= 0 && days <= 3;
                })
                .count();
        int expired = (int) allItems.stream()
                .filter(item -> item.getExpirationDate() != null && item.getExpirationDate().isBefore(now))
                .count();
        int lowStock = (int) allItems.stream()
                .filter(item -> item.getQuantity() != null && item.getQuantity().compareTo(BigDecimal.ONE) < 0)
                .count();

        return new PantrySummary(total, expiringSoon, expired, lowStock);
    }

    // DTO records
    public record DashboardResponse(
            String firstName,
            String planType,
            MealPlanSummary activePlan,
            GrocerySummary groceryList,
            PantrySummary pantry,
            BudgetSummary budget,
            long unreadNotifications,
            List<RecommendationDTO> recommendations,
            String nextAction
    ) {}

    public record MealPlanSummary(
            UUID id,
            String name,
            String status,
            String startDate,
            String endDate,
            int entryCount
    ) {}

    public record GrocerySummary(
            UUID id,
            String name,
            int totalItems,
            int checkedItems,
            BigDecimal totalEstimate,
            BigDecimal checkedEstimate
    ) {}

    public record PantrySummary(
            int totalItems,
            int expiringSoon,
            int expired,
            int lowStock
    ) {}

    public record BudgetSummary(
            BigDecimal amount,
            BigDecimal spent,
            String currency
    ) {}

    public record RecommendationDTO(
            UUID id,
            String name,
            String description,
            String imageUrl,
            Integer totalTimeMinutes,
            Integer servings,
            String cuisineType,
            String mealType,
            BigDecimal estimatedCost,
            double score
    ) {}
}
