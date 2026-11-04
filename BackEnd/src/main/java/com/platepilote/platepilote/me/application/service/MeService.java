package com.platepilote.platepilote.me.application.service;

import com.platepilote.platepilote.authentication.domain.entity.OurUser;
import com.platepilote.platepilote.authentication.domain.repository.UserRepository;
import com.platepilote.platepilote.authentication.domain.repository.RefreshTokenRepository;
import com.platepilote.platepilote.budget.domain.entity.Budget;
import com.platepilote.platepilote.budget.domain.repository.BudgetRepository;
import com.platepilote.platepilote.grocery.domain.entity.PurchaseRecord;
import com.platepilote.platepilote.grocery.domain.repository.PurchaseRecordRepository;
import com.platepilote.platepilote.notification.domain.entity.Notification;
import com.platepilote.platepilote.notification.domain.repository.NotificationRepository;
import com.platepilote.platepilote.subscription.domain.entity.Subscription;
import com.platepilote.platepilote.subscription.domain.repository.SubscriptionRepository;
import com.platepilote.platepilote.me.application.dto.BudgetExportDto;
import com.platepilote.platepilote.me.application.dto.NotificationExportDto;
import com.platepilote.platepilote.me.application.dto.PurchaseRecordExportDto;
import com.platepilote.platepilote.me.application.dto.SubscriptionExportDto;

import com.platepilote.platepilote.billing.application.service.BillingService;
import com.platepilote.platepilote.notification.domain.repository.DeviceRegistrationRepository;
import com.platepilote.platepilote.common.kernel.ResourceNotFoundException;
import com.platepilote.platepilote.grocery.domain.entity.GroceryList;
import com.platepilote.platepilote.grocery.domain.repository.GroceryListRepository;
import com.platepilote.platepilote.me.application.dto.DataExportResponse;
import com.platepilote.platepilote.me.application.dto.DeleteAccountResponse;
import com.platepilote.platepilote.me.application.dto.GroceryListExportDto;
import com.platepilote.platepilote.me.application.dto.MealPlanExportDto;
import com.platepilote.platepilote.me.application.dto.RightsActionResponse;
import com.platepilote.platepilote.mealplanning.domain.entity.MealPlan;
import com.platepilote.platepilote.mealplanning.domain.repository.MealPlanRepository;
import com.platepilote.platepilote.pantry.application.dto.PantryItemResponse;
import com.platepilote.platepilote.pantry.domain.entity.PantryItem;
import com.platepilote.platepilote.pantry.domain.repository.PantryItemRepository;
import com.platepilote.platepilote.preferences.application.dto.UserPreferencesResponse;
import com.platepilote.platepilote.preferences.application.service.PreferencesService;
import com.platepilote.platepilote.recipes.application.dto.RecipeResponse;
import com.platepilote.platepilote.recipes.domain.entity.Recipe;
import com.platepilote.platepilote.recipes.domain.repository.RecipeFavoriteRepository;
import com.platepilote.platepilote.recipes.domain.repository.RecipeRepository;
import com.platepilote.platepilote.userprofile.application.dto.UserProfileResponse;
import com.platepilote.platepilote.userprofile.application.service.UserProfileService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.UUID;

@Service
public class MeService {
    private static final Logger log = LoggerFactory.getLogger(MeService.class);
    private static final int GRACE_PERIOD_DAYS = 30;
    private static final Pageable EXPORT_LIMIT = Pageable.unpaged();

    private final UserRepository userRepository;
    private final RefreshTokenRepository refreshTokenRepository;
    private final UserProfileService userProfileService;
    private final PreferencesService preferencesService;
    private final MealPlanRepository mealPlanRepository;
    private final GroceryListRepository groceryListRepository;
    private final PantryItemRepository pantryItemRepository;
    private final RecipeFavoriteRepository recipeFavoriteRepository;
    private final RecipeRepository recipeRepository;
    private final BillingService billingService;
    private final DeviceRegistrationRepository deviceRegistrationRepository;
    private final BudgetRepository budgetRepository;
    private final NotificationRepository notificationRepository;
    private final PurchaseRecordRepository purchaseRecordRepository;
    private final SubscriptionRepository subscriptionRepository;

    public MeService(UserRepository userRepository,
                     RefreshTokenRepository refreshTokenRepository,
                     UserProfileService userProfileService,
                     PreferencesService preferencesService,
                     MealPlanRepository mealPlanRepository,
                     GroceryListRepository groceryListRepository,
                     PantryItemRepository pantryItemRepository,
                     RecipeFavoriteRepository recipeFavoriteRepository,
                     RecipeRepository recipeRepository,
                     BillingService billingService,
                     DeviceRegistrationRepository deviceRegistrationRepository,
                     BudgetRepository budgetRepository,
                     NotificationRepository notificationRepository,
                     PurchaseRecordRepository purchaseRecordRepository,
                     SubscriptionRepository subscriptionRepository) {
        this.userRepository = userRepository;
        this.refreshTokenRepository = refreshTokenRepository;
        this.userProfileService = userProfileService;
        this.preferencesService = preferencesService;
        this.mealPlanRepository = mealPlanRepository;
        this.groceryListRepository = groceryListRepository;
        this.pantryItemRepository = pantryItemRepository;
        this.recipeFavoriteRepository = recipeFavoriteRepository;
        this.recipeRepository = recipeRepository;
        this.billingService = billingService;
        this.deviceRegistrationRepository = deviceRegistrationRepository;
        this.budgetRepository = budgetRepository;
        this.notificationRepository = notificationRepository;
        this.purchaseRecordRepository = purchaseRecordRepository;
        this.subscriptionRepository = subscriptionRepository;
    }

    @Transactional(readOnly = true)
    public DataExportResponse exportUserData(UUID userId) {
        OurUser user = loadUser(userId);
        log.info("Exporting user data for {}", userId);

        UserProfileResponse profile = userProfileService.getProfileByUserId(userId);
        UserPreferencesResponse preferences = preferencesService.getAllPreferences(userId);

        var plans = mealPlanRepository.findByUserIdAndDeletedAtIsNull(userId, EXPORT_LIMIT)
                .map(this::toMealPlanExport)
                .getContent();
        var groceryLists = groceryListRepository.findByUserIdAndDeletedAtIsNull(userId, EXPORT_LIMIT)
                .map(this::toGroceryListExport)
                .getContent();
        var pantryItems = pantryItemRepository.findByUserIdAndDeletedAtIsNull(userId, EXPORT_LIMIT)
                .map(this::toPantryItemResponse)
                .getContent();
        var favorites = recipeFavoriteRepository.findByUserIdOrderByCreatedAtDesc(userId, EXPORT_LIMIT)
                .stream()
                .map(fav -> recipeRepository.findById(fav.getRecipeId()).orElse(null))
                .filter(recipe -> recipe != null)
                .map(this::toRecipeResponse)
                .toList();
        var personalRecipes = recipeRepository.findByUserIdAndDeletedAtIsNull(userId, EXPORT_LIMIT)
                .map(this::toRecipeResponse)
                .getContent();
        var budgets = budgetRepository.findByUserIdAndDeletedAtIsNull(userId).stream()
                .map(this::toBudgetExport)
                .toList();
        var notifications = notificationRepository.findByUserIdAndDeletedAtIsNull(userId, EXPORT_LIMIT)
                .map(this::toNotificationExport)
                .getContent();
        var purchaseRecords = purchaseRecordRepository
                .findByUserIdAndDeletedAtIsNullOrderByPurchasedAtDesc(userId, EXPORT_LIMIT)
                .map(this::toPurchaseRecordExport)
                .getContent();
        var subscription = subscriptionRepository.findByUserId(userId)
                .map(this::toSubscriptionExport)
                .orElse(null);

        return DataExportResponse.builder()
                .userId(user.getId())
                .email(user.getEmail())
                .firstName(user.getFirstName())
                .lastName(user.getLastName())
                .accountCreatedAt(user.getCreatedAt())
                .exportedAt(Instant.now())
                .analyticsOptOut(user.getAnalyticsOptOut())
                .processingRestricted(user.getProcessingRestricted())
                .profile(profile)
                .preferences(preferences)
                .mealPlans(plans)
                .groceryLists(groceryLists)
                .pantryItems(pantryItems)
                .recipeFavorites(favorites)
                .personalRecipes(personalRecipes)
                .budgets(budgets)
                .notifications(notifications)
                .purchaseRecords(purchaseRecords)
                .subscription(subscription)
                .build();
    }

    @Transactional
    public DeleteAccountResponse deleteUserAccount(UUID userId) {
        OurUser user = loadUser(userId);
        Instant now = Instant.now();

        // Stop billing and push delivery before disabling the account.
        billingService.cancelForAccountDeletion(userId);
        refreshTokenRepository.revokeAllActiveForUser(userId);
        deviceRegistrationRepository.deactivateAllForUser(userId, now);

        user.setDeletedAt(now);
        user.setEnabled(false);
        userRepository.save(user);

        Instant purgeAt = now.plus(GRACE_PERIOD_DAYS, ChronoUnit.DAYS);
        return DeleteAccountResponse.builder()
                .userId(userId)
                .deletionDateAt(now)
                .scheduledPurgeAt(purgeAt)
                .scheduledAnonymizationAt(purgeAt)
                .gracePeriodDays(GRACE_PERIOD_DAYS)
                .message("Account disabled. Personal data is scheduled for anonymization in 30 days; legally required billing records may be retained.")
                .build();
    }

    @Transactional
    public RightsActionResponse restrictProcessing(UUID userId) {
        OurUser user = loadUser(userId);
        user.setProcessingRestricted(true);
        userRepository.save(user);
        return rightsResponse(userId, "restrict-processing", "Processing restriction recorded.");
    }

    @Transactional
    public RightsActionResponse optOutAnalytics(UUID userId) {
        OurUser user = loadUser(userId);
        user.setAnalyticsOptOut(true);
        userRepository.save(user);
        return rightsResponse(userId, "opt-out-analytics", "Analytics opt-out recorded.");
    }

    private OurUser loadUser(UUID userId) {
        return userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User", "id", userId));
    }

    private RightsActionResponse rightsResponse(UUID userId, String action, String message) {
        return RightsActionResponse.builder()
                .userId(userId)
                .action(action)
                .processedAt(Instant.now())
                .message(message)
                .build();
    }

    private BudgetExportDto toBudgetExport(Budget budget) {
        return new BudgetExportDto(
                budget.getId(),
                budget.getAmount(),
                budget.getCurrency(),
                budget.getPeriod(),
                budget.getStartDate(),
                budget.getEndDate(),
                budget.getSpent(),
                budget.getCreatedAt(),
                budget.getUpdatedAt()
        );
    }

    private NotificationExportDto toNotificationExport(Notification notification) {
        return new NotificationExportDto(
                notification.getId(),
                notification.getType(),
                notification.getTitle(),
                notification.getBody(),
                notification.getData(),
                notification.getRead(),
                notification.getReadAt(),
                notification.getCreatedAt()
        );
    }

    private PurchaseRecordExportDto toPurchaseRecordExport(PurchaseRecord purchase) {
        return new PurchaseRecordExportDto(
                purchase.getId(),
                purchase.getGroceryListId(),
                purchase.getItemName(),
                purchase.getCategory(),
                purchase.getQuantity(),
                purchase.getUnit(),
                purchase.getUnitPrice(),
                purchase.getTotalPrice(),
                purchase.getIngredientId(),
                purchase.getPurchasedAt()
        );
    }

    private SubscriptionExportDto toSubscriptionExport(Subscription subscription) {
        return new SubscriptionExportDto(
                subscription.getPlanType(),
                subscription.getStatus(),
                subscription.getProvider(),
                subscription.getStartDate(),
                subscription.getEndDate(),
                subscription.getTrialEndDate(),
                subscription.getCancelAtPeriodEnd(),
                subscription.getExpiresAt(),
                subscription.getLastVerifiedAt()
        );
    }

    private MealPlanExportDto toMealPlanExport(MealPlan plan) {
        return MealPlanExportDto.builder()
                .id(plan.getId())
                .name(plan.getName())
                .startDate(plan.getStartDate())
                .endDate(plan.getEndDate())
                .status(plan.getStatus())
                .mode(plan.getMode())
                .createdAt(plan.getCreatedAt())
                .updatedAt(plan.getUpdatedAt())
                .build();
    }

    private GroceryListExportDto toGroceryListExport(GroceryList list) {
        return GroceryListExportDto.builder()
                .id(list.getId())
                .name(list.getName())
                .status(list.getStatus())
                .mealPlanId(list.getMealPlanId())
                .createdAt(list.getCreatedAt())
                .build();
    }

    private PantryItemResponse toPantryItemResponse(PantryItem item) {
        return PantryItemResponse.builder()
                .id(item.getId())
                .name(item.getName())
                .category(item.getCategory())
                .quantity(item.getQuantity())
                .unit(item.getUnit())
                .expirationDate(item.getExpirationDate())
                .ingredientId(item.getIngredientId())
                .isExpired(item.getExpirationDate() != null && item.getExpirationDate().isBefore(java.time.LocalDate.now()))
                .createdAt(item.getCreatedAt())
                .updatedAt(item.getUpdatedAt())
                .build();
    }

    private RecipeResponse toRecipeResponse(Recipe recipe) {
        return RecipeResponse.builder()
                .id(recipe.getId())
                .name(recipe.getName())
                .description(recipe.getDescription())
                .prepTimeMinutes(recipe.getPrepTimeMinutes())
                .cookTimeMinutes(recipe.getCookTimeMinutes())
                .totalTimeMinutes(recipe.getTotalTimeMinutes())
                .servings(recipe.getServings())
                .difficulty(recipe.getDifficulty())
                .cuisineType(recipe.getCuisineType())
                .mealType(recipe.getMealType())
                .estimatedCost(recipe.getEstimatedCost())
                .imageUrl(recipe.getImageUrl())
                .build();
    }

    private static <T> T safe(java.util.function.Supplier<T> supplier, T fallback) {
        try {
            return supplier.get();
        } catch (Exception ex) {
            log.warn("Optional submodule unavailable during export: {}", ex.getMessage());
            return fallback;
        }
    }
}
