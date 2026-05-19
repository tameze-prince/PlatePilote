package com.platepilote.platepilote.recommendation.domain.service;

import com.platepilote.platepilote.admin.domain.entity.SystemSetting;
import com.platepilote.platepilote.admin.domain.repository.SystemSettingRepository;
import com.platepilote.platepilote.authentication.domain.entity.OurUser;
import com.platepilote.platepilote.authentication.domain.entity.Role;
import com.platepilote.platepilote.authentication.domain.repository.UserRepository;
import com.platepilote.platepilote.budget.domain.repository.BudgetRepository;
import com.platepilote.platepilote.common.kernel.BusinessRuleViolationException;
import com.platepilote.platepilote.ingredients.application.service.IngredientResolutionService;
import com.platepilote.platepilote.optimization.application.service.BudgetOptimizer;
import com.platepilote.platepilote.optimization.application.service.PantryUtilizationScorer;
import com.platepilote.platepilote.preferences.domain.entity.Allergy;
import com.platepilote.platepilote.preferences.domain.repository.AllergyRepository;
import com.platepilote.platepilote.preferences.domain.repository.DietaryPreferenceRepository;
import com.platepilote.platepilote.recipes.domain.entity.Recipe;
import com.platepilote.platepilote.recipes.domain.entity.RecipeIngredient;
import com.platepilote.platepilote.recipes.domain.repository.RecipeIngredientRepository;
import com.platepilote.platepilote.recipes.domain.repository.RecipeRepository;
import com.platepilote.platepilote.recommendation.domain.entity.RecommendationEvent;
import com.platepilote.platepilote.recommendation.domain.repository.RecommendationEventRepository;
import com.platepilote.platepilote.subscription.application.service.EntitlementService;
import com.platepilote.platepilote.userprofile.domain.repository.UserProfileRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.Pageable;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;
import java.util.Optional;
import java.util.Set;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.lenient;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class RecommendationEngineTest {

    @Mock
    private RecipeRepository recipeRepository;
    @Mock
    private RecipeIngredientRepository recipeIngredientRepository;
    @Mock
    private DietaryPreferenceRepository dietaryPreferenceRepository;
    @Mock
    private AllergyRepository allergyRepository;
    @Mock
    private BudgetRepository budgetRepository;
    @Mock
    private UserProfileRepository userProfileRepository;
    @Mock
    private UserRepository userRepository;
    @Mock
    private SystemSettingRepository systemSettingRepository;
    @Mock
    private RecommendationEventRepository recommendationEventRepository;
    @Mock
    private BudgetOptimizer budgetOptimizer;
    @Mock
    private PantryUtilizationScorer pantryUtilizationScorer;
    @Mock
    private IngredientResolutionService ingredientResolutionService;
    @Mock
    private EntitlementService entitlementService;

    private RecommendationEngine engine;

    @BeforeEach
    void setUp() {
        engine = new RecommendationEngine(
                recipeRepository,
                recipeIngredientRepository,
                dietaryPreferenceRepository,
                allergyRepository,
                budgetRepository,
                userProfileRepository,
                userRepository,
                systemSettingRepository,
                recommendationEventRepository,
                budgetOptimizer,
                pantryUtilizationScorer,
                ingredientResolutionService,
                entitlementService
        );

        lenient().when(userProfileRepository.findByUserId(any())).thenReturn(Optional.empty());
        lenient().when(dietaryPreferenceRepository.findByUserId(any())).thenReturn(List.of());
        lenient().when(allergyRepository.findByUserId(any())).thenReturn(List.of());
        lenient().when(budgetRepository.findByUserIdAndDeletedAtIsNull(any(), any()))
                .thenReturn(new PageImpl<>(List.of()));
        lenient().when(userRepository.findById(any())).thenReturn(Optional.empty());
        lenient().when(entitlementService.hasActiveEntitlement(any(), anyString())).thenReturn(false);
        lenient().when(systemSettingRepository.findBySettingKey(anyString()))
                .thenAnswer(invocation -> {
                    String key = invocation.getArgument(0, String.class);
                    if ("free_weekly_recommendation_limit".equals(key)) {
                        return Optional.of(SystemSetting.builder()
                                .settingKey(key)
                                .settingValue("20")
                                .build());
                    }
                    return Optional.empty();
                });
        lenient().when(recommendationEventRepository.countByUserIdAndCreatedAtAfterAndQuotaLimitedFalse(any(), any()))
                .thenReturn(0L);
        lenient().when(budgetOptimizer.estimateRecipeCost(any(), anyString())).thenReturn(BigDecimal.ZERO);
        lenient().when(pantryUtilizationScorer.calculatePantryScore(any(), any())).thenReturn(0.8);
        lenient().when(ingredientResolutionService.normalize(anyString()))
                .thenAnswer(invocation -> invocation.getArgument(0, String.class).trim().toLowerCase());
        lenient().when(recommendationEventRepository.save(any(RecommendationEvent.class)))
                .thenAnswer(invocation -> invocation.getArgument(0));
    }

    @Test
    void allergyHardFilterExcludesUnsafeRecipe() {
        UUID userId = UUID.randomUUID();
        Recipe unsafe = recipe("Peanut Stew", true);
        Recipe safe = recipe("Bean Bowl", false);
        when(allergyRepository.findByUserId(userId)).thenReturn(List.of(Allergy.builder()
                .userId(userId)
                .allergen("peanut")
                .severity("severe")
                .build()));
        when(recipeRepository.findByIsPublicTrueAndDeletedAtIsNull(any(Pageable.class)))
                .thenReturn(new PageImpl<>(List.of(unsafe, safe)));
        when(recipeIngredientRepository.findByRecipeIdOrderBySortOrderAsc(unsafe.getId()))
                .thenReturn(List.of(ingredient(unsafe, "peanut butter")));
        when(recipeIngredientRepository.findByRecipeIdOrderBySortOrderAsc(safe.getId()))
                .thenReturn(List.of(ingredient(safe, "black beans")));

        List<RecommendationEngine.RecommendationResult> results = engine.getRecommendations(userId, 10);

        assertThat(results).extracting(result -> result.recipe().getName())
                .containsExactly("Bean Bowl");
    }

    @Test
    void freeQuotaBlocksAfterConfiguredLimit() {
        UUID userId = UUID.randomUUID();
        when(systemSettingRepository.findBySettingKey(eq("free_weekly_recommendation_limit")))
                .thenReturn(Optional.of(SystemSetting.builder()
                        .settingKey("free_weekly_recommendation_limit")
                        .settingValue("2")
                        .build()));
        when(recommendationEventRepository.countByUserIdAndCreatedAtAfterAndQuotaLimitedFalse(eq(userId), any(Instant.class)))
                .thenReturn(2L);

        assertThatThrownBy(() -> engine.getRecommendations(userId, 5))
                .isInstanceOf(BusinessRuleViolationException.class)
                .hasMessageContaining("Free recommendation limit reached");

        ArgumentCaptor<RecommendationEvent> eventCaptor = ArgumentCaptor.forClass(RecommendationEvent.class);
        verify(recommendationEventRepository).save(eventCaptor.capture());
        assertThat(eventCaptor.getValue().getQuotaLimited()).isTrue();
        assertThat(eventCaptor.getValue().getResultCount()).isZero();
        verify(recipeRepository, never()).findByIsPublicTrueAndDeletedAtIsNull(any(Pageable.class));
    }

    @Test
    void rejectedOrDisabledRecipesAreNotRecommended() {
        UUID userId = UUID.randomUUID();
        Recipe disabled = recipe("Disabled Bowl", false);
        disabled.setEnabled(false);
        Recipe rejected = recipe("Rejected Bowl", false);
        rejected.setVerificationStatus("REJECTED");
        Recipe eligible = recipe("Trusted Bowl", false);
        eligible.setVerified(true);
        eligible.setConfidenceScore(0.9);
        when(recipeRepository.findByIsPublicTrueAndDeletedAtIsNull(any(Pageable.class)))
                .thenReturn(new PageImpl<>(List.of(disabled, rejected, eligible)));

        List<RecommendationEngine.RecommendationResult> results = engine.getRecommendations(userId, 10);

        assertThat(results).extracting(result -> result.recipe().getName())
                .containsExactly("Trusted Bowl");
    }

    @Test
    void unverifiedLowConfidenceRecipeReturnsTrustWarnings() {
        UUID userId = UUID.randomUUID();
        Recipe recipe = recipe("Estimated Bowl", false);
        recipe.setVerified(false);
        recipe.setConfidenceScore(0.4);
        when(recipeRepository.findByIsPublicTrueAndDeletedAtIsNull(any(Pageable.class)))
                .thenReturn(new PageImpl<>(List.of(recipe)));

        List<RecommendationEngine.RecommendationResult> results = engine.getRecommendations(userId, 10);

        assertThat(results).hasSize(1);
        assertThat(results.getFirst().warnings())
                .contains("Recipe has not been professionally verified",
                        "Nutrition and allergen details are estimates");
    }

    @Test
    void premiumBypassesFreeQuota() {
        UUID userId = UUID.randomUUID();
        Recipe recipe = recipe("Premium Bowl", false);
        OurUser premiumUser = OurUser.builder()
                .email("premium@example.com")
                .firstName("Premium")
                .lastName("User")
                .enabled(true)
                .roles(Set.of(new Role(UUID.randomUUID(), "ROLE_PREMIUM_USER", "Premium")))
                .build();

        when(userRepository.findById(userId)).thenReturn(Optional.of(premiumUser));
        lenient().when(recipeRepository.findByIsPublicTrueAndDeletedAtIsNull(any(Pageable.class)))
                .thenReturn(new PageImpl<>(List.of(recipe)));

        List<RecommendationEngine.RecommendationResult> results = engine.getRecommendations(userId, 5);

        assertThat(results).extracting(result -> result.recipe().getName())
                .containsExactly("Premium Bowl");
        verify(recommendationEventRepository, never())
                .countByUserIdAndCreatedAtAfterAndQuotaLimitedFalse(eq(userId), any(Instant.class));
    }

    private static Recipe recipe(String name, boolean containsNuts) {
        Recipe recipe = Recipe.builder()
                .name(name)
                .description(name + " description")
                .servings(2)
                .difficulty("Easy")
                .cuisineType("American")
                .mealType("Dinner")
                .totalTimeMinutes(20)
                .isPublic(true)
                .containsNuts(containsNuts)
                .containsGluten(false)
                .containsLactose(false)
                .containsSoy(false)
                .containsEggs(false)
                .containsFish(false)
                .containsShellfish(false)
                .vegetarian(true)
                .vegan(true)
                .lowCarb(false)
                .ketoFriendly(false)
                .halalFriendly(true)
                .estimatedCost(BigDecimal.TEN)
                .enabled(true)
                .verified(false)
                .verificationStatus("UNREVIEWED")
                .confidenceScore(0.5)
                .build();
        recipe.setId(UUID.randomUUID());
        return recipe;
    }

    private static RecipeIngredient ingredient(Recipe recipe, String name) {
        return RecipeIngredient.builder()
                .recipe(recipe)
                .name(name)
                .quantity(BigDecimal.ONE)
                .unit("cup")
                .sortOrder(0)
                .build();
    }
}
