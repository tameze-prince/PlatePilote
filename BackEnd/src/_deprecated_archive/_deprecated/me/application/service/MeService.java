package com.platepilote.platepilote.me.application.service;

import com.platepilote.platepilote.authentication.domain.entity.OurUser;
import com.platepilote.platepilote.authentication.domain.repository.UserRepository;
import com.platepilote.platepilote.common.kernel.ResourceNotFoundException;
import com.platepilote.platepilote.me.application.dto.DataExportResponse;
import com.platepilote.platepilote.me.application.dto.DeleteAccountResponse;
import com.platepilote.platepilote.me.application.dto.GroceryListExportDto;
import com.platepilote.platepilote.me.application.dto.MealPlanExportDto;
import com.platepilote.platepilote.mealplanning.domain.entity.MealPlan;
import com.platepilote.platepilote.mealplanning.domain.entity.MealPlanEntry;
import com.platepilote.platepilote.mealplanning.domain.repository.MealPlanEntryRepository;
import com.platepilote.platepilote.mealplanning.domain.repository.MealPlanRepository;
import com.platepilote.platepilote.pantry.application.dto.PantryItemResponse;
import com.platepilote.platepilote.pantry.domain.entity.PantryItem;
import com.platepilote.platepilote.pantry.domain.repository.PantryItemRepository;
import com.platepilote.platepilote.preferences.application.dto.UserPreferencesResponse;
import com.platepilote.platepilote.preferences.application.service.PreferencesService;
import com.platepilote.platepilote.recipes.application.dto.RecipeResponse;
import com.platepilote.platepilote.recipes.domain.entity.Recipe;
import com.platepilote.platepilote.recipes.domain.entity.RecipeFavorite;
import com.platepilote.platepilote.recipes.domain.repository.RecipeFavoriteRepository;
import com.platepilote.platepilote.recipes.domain.repository.RecipeRepository;
import com.platepilote.platepilote.userprofile.application.dto.UserProfileResponse;
import com.platepilote.platepilote.userprofile.application.service.UserProfileService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

/**
 * Service for Data Subject Access Rights (RGPD art. 15, art. 17, art. 20).
 *
 * <p>The Service exposes two operations to satisfy the PRD §9.2 BR-008:
 * <ul>
 *   <li>{@link #exportUserData(UUID)} — produce a portable JSON aggregate of every
 *       personal datum PlatePilot retains for the user.</li>
 *   <li>{@link #deleteUserAccount(UUID)} — soft-delete immediately, then schedule
 *       a hard-purge after a 30-day grace window.</li>
 * </ul>
 *
 * <p>Inline DTO mappers live here as private helpers to keep the {@code me}
 * module self-contained. Public DTOs from third-party modules (e.g.
 * {@link UserProfileResponse}, {@link UserPreferencesResponse}) are reused
 * wherever the upstream module exposes a stable contract.
 */
@Service
public class MeService {

    private static final Logger log = LoggerFactory.getLogger(MeService.class);
    private static final int GRACE_PERIOD_DAYS = 30;

    private final UserRepository userRepository;
    private final UserProfileService userProfileService;
    private final PreferencesService preferencesService;
    private final MealPlanRepository mealPlanRepository;
    private final MealPlanEntryRepository mealPlanEntryRepository;
    private final com.platepilote.platepilote.grocery.domain.repository.GroceryListRepository groceryListRepository;
    private final PantryItemRepository pantryItemRepository;
    private final RecipeFavoriteRepository recipeFavoriteRepository;
    private final RecipeRepository recipeRepository;

    public MeService(UserRepository userRepository,
                     UserProfileService userProfileService,
                     PreferencesService preferencesService,
                     MealPlanRepository mealPlanRepository,
                     MealPlanEntryRepository mealPlanEntryRepository,
                     com.platepilote.platepilote.grocery.domain.repository.GroceryListRepository groceryListRepository,
                     PantryItemRepository pantryItemRepository,
                     RecipeFavoriteRepository recipeFavoriteRepository,
                     RecipeRepository recipeRepository) {
        this.userRepository = userRepository;
        this.userProfileService = userProfileService;
        this.preferencesService = preferencesService;
        this.mealPlanRepository = mealPlanRepository;
        this.mealPlanEntryRepository = mealPlanEntryRepository;
        this.groceryListRepository = groceryListRepository;
        this.pantryItemRepository = pantryItemRepository;
        this.recipeFavoriteRepository = recipeFavoriteRepository;
        this.recipeRepository = recipeRepository;
    }

    /**
     * Aggregate every personal datum PlatePilot retains for {@code userId} into a
     * portable JSON document (RGPD art. 15 + art. 20). Read-only; no side effects.
     */
    @Transactional(readOnly = true)
    public DataExportResponse exportUserData(UUID userId) {
        OurUser user = loadUser(userId);
        log.info("Exporting user data for {}", userId);

        UserProfileResponse profile = safe(() -> userProfileService.getProfile(userId), null);
        UserPreferencesResponse preferences = safe(() -> preferencesService.getPreferences(userId), null);

        List<MealPlan> plans = mealPlanRepository.findByUserIdAndDeletedAtIsNull(userId);
        List<MealPlanExportDto> planDtos = plans.stream().map(this::toMealPlanExport).toList();

        List<com.platepilote.platepilote.grocery.domain.entity.GroceryList> lists =
                groceryListRepository.findByUserIdAndDeletedAtIsNull(userId, org.springframework.data.domain.Pageable.unpaged())
                        .getContent();
        List<GroceryListExportDto> listDtos = lists.stream().map(this::toGroceryListExport).toList();

        List<PantryItem> pantryItems = pantryItemRepository.findByUserIdAndDeletedAtIsNull(userId);
        List<PantryItemResponse> pantryDtos = pantryItems.stream().map(this::toPantryItemResponse).toList();

        List<RecipeFavorite> favorites = recipeFavoriteRepository.findByUserId(userId);
        List<RecipeResponse> favoriteRecipes = favorites.stream()
                .map(fav -> recipeRepository.findById(fav.getRecipeId()).orElse(null))
                .filter(recipe -> recipe != null)
                .map(this::toRecipeResponse)
                .toList();

        List<Recipe> personalRecipes = recipeRepository.findByUserIdAndDeletedAtIsNull(userId);
        List<RecipeResponse> personalDtos = personalRecipes.stream()
                .map(this::toRecipeResponse)
                .toList();

        return DataExportResponse.builder()
                .userId(user.getId())
                .email(user.getEmail())
                .firstName(user.getFirstName())
                .lastName(user.getLastName())
                .accountCreatedAt(user.getCreatedAt())
                .exportedAt(Instant.now())
                .profile(profile)
                .preferences(preferences)
                .mealPlans(planDtos)
                .groceryLists(listDtos)
                .pantryItems(pantryDtos)
                .recipeFavorites(favoriteRecipes)
                .personalRecipes(personalDtos)
                .build();
    }

    /**
     * Soft-delete the account immediately and schedule a hard-purge after
     * {@value #GRACE_PERIOD_DAYS} days (RGPD art. 17). Returns the schedule so
     * the user-facing controller can communicate the timeline.
     */
    @Transactional
    public DeleteAccountResponse deleteUserAccount(UUID userId) {
        OurUser user = loadUser(userId);
        Instant now = Instant.now();
        user.setDeletedAt(now);
        user.setEnabled(false);
        userRepository.save(user);

        Instant purgeAt = now.plus(GRACE_PERIOD_DAYS, ChronoUnit.DAYS);
        log.info("User {} soft-deleted at {}; hard-purge scheduled for {}", userId, now, purgeAt);

        return DeleteAccountResponse.builder()
                .userId(userId)
                .deletionDateAt(now)
                .scheduledPurgeAt(purgeAt)
                .gracePeriodDays(GRACE_PERIOD_DAYS)
                .message("Account soft-deleted. Hard-purge in 30 days. Contact support to reactivate before then.")
                .build();
    }

    private OurUser loadUser(UUID userId) {
        return userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User", userId.toString()));
    }

    private MealPlanExportDto toMealPlanExport(MealPlan plan) {
        List<MealPlanEntry> entries = mealPlanEntryRepository.findByMealPlanId(plan.getId());
        return MealPlanExportDto.builder()
                .id(plan.getId())
                .name(plan.getName())
                .startDate(plan.getStartDate())
                .endDate(plan.getEndDate())
                .status(plan.getStatus())
                .entries(entries.stream().map(e -> e.getId().toString()).toList())
                .build();
    }

    private GroceryListExportDto toGroceryListExport(com.platepilote.platepilote.grocery.domain.entity.GroceryList list) {
        return GroceryListExportDto.builder()
                .id(list.getId())
                .name(list.getName())
                .createdAt(list.getCreatedAt())
                .updatedAt(list.getUpdatedAt())
                .status(list.getStatus())
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
                .id(recipe.getId() != null ? recipe.getId().toString() : null)
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
