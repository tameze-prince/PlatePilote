package com.platepilote.platepilote.dashboard.application.service;

import com.platepilote.platepilote.authentication.domain.repository.UserRepository;
import com.platepilote.platepilote.budget.domain.repository.BudgetRepository;
import com.platepilote.platepilote.grocery.domain.entity.GroceryItem;
import com.platepilote.platepilote.grocery.domain.entity.GroceryList;
import com.platepilote.platepilote.grocery.domain.repository.GroceryItemRepository;
import com.platepilote.platepilote.grocery.domain.repository.GroceryListRepository;
import com.platepilote.platepilote.mealplanning.domain.entity.MealPlan;
import com.platepilote.platepilote.mealplanning.domain.repository.MealPlanEntryRepository;
import com.platepilote.platepilote.mealplanning.domain.repository.MealPlanRepository;
import com.platepilote.platepilote.notification.application.service.NotificationService;
import com.platepilote.platepilote.pantry.domain.entity.PantryItem;
import com.platepilote.platepilote.pantry.domain.repository.PantryItemRepository;
import com.platepilote.platepilote.recipes.domain.repository.RecipeRepository;
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

/**
 * Service de construction du tableau de bord d'accueil.
 * <p>
 * Agrège les données des différents domaines (profil, abonnement, plans de repas,
 * listes de courses, placard, budget, notifications, recettes) pour fournir
 * une vue synthétique et actionnable à l'utilisateur dès sa connexion.
 */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class DashboardService {

    /** Repository des utilisateurs. */
    private final UserRepository userRepository;

    /** Repository des profils utilisateur. */
    private final UserProfileRepository userProfileRepository;
    private final MealPlanRepository mealPlanRepository;
    private final MealPlanEntryRepository mealPlanEntryRepository;
    private final GroceryListRepository groceryListRepository;
    private final GroceryItemRepository groceryItemRepository;
    private final PantryItemRepository pantryItemRepository;
    private final BudgetRepository budgetRepository;
    private final NotificationService notificationService;
    private final SubscriptionRepository subscriptionRepository;
    private final RecipeRepository recipeRepository;

    /**
     * Construit le tableau de bord d'accueil pour un utilisateur.
     * <p>
     * Agrège les informations suivantes : prénom, type d'abonnement, plan de repas actif,
     * liste de courses active, résumé du placard (ruptures, expirations), budget,
     * nombre de notifications non lues, recettes recommandées et prochaine action suggérée.
     *
     * @param userId identifiant de l'utilisateur
     * @return tableau de bord complet
     */
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

        // Top recipes: keep dashboard fast.
        List<RecommendationDTO> recDTOs = recipeRepository
                .findDashboardRecipes(PageRequest.of(0, 3))
                .stream()
                .map(recipe -> new RecommendationDTO(
                        recipe.getId(),
                        recipe.getName(),
                        recipe.getDescription(),
                        recipe.getImageUrl(),
                        recipe.getTotalTimeMinutes(),
                        recipe.getServings(),
                        recipe.getCuisineType(),
                        recipe.getMealType(),
                        recipe.getEstimatedCost(),
                        0.0
                ))
                .toList();
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
                (int) mealPlanEntryRepository.countByMealPlanId(plan.getId())
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

    /**
     * DTO représentant le tableau de bord d'accueil complet.
     *
     * @param firstName          prénom de l'utilisateur
     * @param planType           type d'abonnement (FREE, PREMIUM, etc.)
     * @param activePlan         plan de repas actif (ou null)
     * @param groceryList        liste de courses active (ou null)
     * @param pantry             résumé du placard
     * @param budget             résumé du budget (ou null)
     * @param unreadNotifications nombre de notifications non lues
     * @param recommendations    liste des recettes recommandées
     * @param nextAction         prochaine action suggérée
     */
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

    /**
     * Résumé d'un plan de repas.
     *
     * @param id         identifiant du plan
     * @param name       nom du plan
     * @param status     statut (ACTIVE, etc.)
     * @param startDate  date de début
     * @param endDate    date de fin
     * @param entryCount nombre d'entrées du plan
     */
    public record MealPlanSummary(
            UUID id,
            String name,
            String status,
            String startDate,
            String endDate,
            int entryCount
    ) {}

    /**
     * Résumé d'une liste de courses.
     *
     * @param id              identifiant de la liste
     * @param name            nom de la liste
     * @param totalItems      nombre total d'articles
     * @param checkedItems    nombre d'articles cochés
     * @param totalEstimate   estimation du coût total
     * @param checkedEstimate estimation du coût des articles cochés
     */
    public record GrocerySummary(
            UUID id,
            String name,
            int totalItems,
            int checkedItems,
            BigDecimal totalEstimate,
            BigDecimal checkedEstimate
    ) {}

    /**
     * Résumé de l'état du placard.
     *
     * @param totalItems   nombre total d'articles
     * @param expiringSoon articles proches de l'expiration (≤ 3 jours)
     * @param expired      articles expirés
     * @param lowStock     articles en stock faible
     */
    public record PantrySummary(
            int totalItems,
            int expiringSoon,
            int expired,
            int lowStock
    ) {}

    /**
     * Résumé du budget hebdomadaire.
     *
     * @param amount   montant du budget
     * @param spent    montant déjà dépensé
     * @param currency devise
     */
    public record BudgetSummary(
            BigDecimal amount,
            BigDecimal spent,
            String currency
    ) {}

    /**
     * DTO d'une recette recommandée affichée dans le tableau de bord.
     *
     * @param id               identifiant de la recette
     * @param name             nom
     * @param description      description
     * @param imageUrl         URL de l'image
     * @param totalTimeMinutes temps de préparation total
     * @param servings         nombre de portions
     * @param cuisineType      type de cuisine
     * @param mealType         type de repas
     * @param estimatedCost    coût estimé
     * @param score            score de recommandation
     */
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
