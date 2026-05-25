package com.platepilote.platepilote.grocery.application.service;

import com.platepilote.platepilote.budget.domain.repository.BudgetRepository;
import com.platepilote.platepilote.common.security.SecurityUtils;
import com.platepilote.platepilote.grocery.domain.entity.GroceryItem;
import com.platepilote.platepilote.grocery.domain.entity.GroceryList;
import com.platepilote.platepilote.grocery.domain.repository.GroceryItemRepository;
import com.platepilote.platepilote.grocery.domain.repository.GroceryListRepository;
import com.platepilote.platepilote.mealplanning.domain.entity.MealPlan;
import com.platepilote.platepilote.mealplanning.domain.entity.MealPlanEntry;
import com.platepilote.platepilote.mealplanning.domain.repository.MealPlanEntryRepository;
import com.platepilote.platepilote.mealplanning.domain.repository.MealPlanRepository;
import com.platepilote.platepilote.pantry.domain.entity.PantryItem;
import com.platepilote.platepilote.pantry.domain.repository.PantryItemRepository;
import com.platepilote.platepilote.pricing.application.service.PricingService;
import com.platepilote.platepilote.recipes.domain.entity.Recipe;
import com.platepilote.platepilote.recipes.domain.entity.RecipeIngredient;
import com.platepilote.platepilote.recipes.domain.repository.RecipeIngredientRepository;
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
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.Set;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class GroceryServiceTest {

    @Mock private GroceryListRepository groceryListRepository;
    @Mock private GroceryItemRepository groceryItemRepository;
    @Mock private MealPlanRepository mealPlanRepository;
    @Mock private MealPlanEntryRepository mealPlanEntryRepository;
    @Mock private RecipeIngredientRepository recipeIngredientRepository;
    @Mock private PantryItemRepository pantryItemRepository;
    @Mock private PricingService pricingService;
    @Mock private UserProfileRepository userProfileRepository;
    @Mock private SecurityUtils securityUtils;
    @Mock private BudgetRepository budgetRepository;

    private GroceryService groceryService;

    @BeforeEach
    void setUp() {
        groceryService = new GroceryService(groceryListRepository, groceryItemRepository, mealPlanRepository,
                mealPlanEntryRepository, recipeIngredientRepository, pantryItemRepository, pricingService,
                userProfileRepository, budgetRepository, securityUtils);
        when(groceryListRepository.save(any(GroceryList.class))).thenAnswer(invocation -> {
            GroceryList list = invocation.getArgument(0);
            list.setId(UUID.randomUUID());
            return list;
        });
        when(groceryItemRepository.findByGroceryListIdOrderBySortOrderAsc(any())).thenReturn(List.of());
        when(userProfileRepository.findByUserId(any())).thenReturn(Optional.empty());
    }

    @Test
    void generateFromMealPlanAggregatesCanonicalIngredientsAndSubtractsPantryOnce() {
        UUID userId = UUID.randomUUID();
        UUID mealPlanId = UUID.randomUUID();
        UUID recipeOne = UUID.randomUUID();
        UUID recipeTwo = UUID.randomUUID();
        UUID flourId = UUID.randomUUID();
        MealPlan mealPlan = mealPlan(userId, mealPlanId);
        when(mealPlanRepository.findById(mealPlanId)).thenReturn(Optional.of(mealPlan));
        when(mealPlanEntryRepository.findByMealPlanId(mealPlanId)).thenReturn(List.of(entry(mealPlanId, recipeOne), entry(mealPlanId, recipeTwo)));
        when(recipeIngredientRepository.findByRecipeIdOrderBySortOrderAsc(recipeOne))
                .thenReturn(List.of(ingredient("Flour", "kg", "1", flourId)));
        when(recipeIngredientRepository.findByRecipeIdOrderBySortOrderAsc(recipeTwo))
                .thenReturn(List.of(ingredient("All-purpose flour", "g", "500", flourId)));
        when(pantryItemRepository.findByUserIdAndIngredientIdIn(any(), any(Set.class)))
                .thenReturn(List.of(pantry("Flour", "g", "250", flourId)));
        when(pricingService.getLatestPricePerUnit(flourId, "US")).thenReturn(Optional.of(new BigDecimal("2.00")));

        groceryService.generateFromMealPlan(userId, mealPlanId);

        ArgumentCaptor<GroceryItem> itemCaptor = ArgumentCaptor.forClass(GroceryItem.class);
        org.mockito.Mockito.verify(groceryItemRepository).save(itemCaptor.capture());
        GroceryItem item = itemCaptor.getValue();
        assertThat(item.getIngredientId()).isEqualTo(flourId);
        assertThat(item.getQuantity()).isEqualByComparingTo("1.250");
        assertThat(item.getUnit()).isEqualTo("kg");
        assertThat(item.getEstimatedPrice()).isEqualByComparingTo("2.5000");
        assertThat(item.getPriceConfidence()).isEqualByComparingTo("0.70");
    }

    @Test
    void generateFromMealPlanDoesNotSubtractAcrossMassAndVolumeUnits() {
        UUID userId = UUID.randomUUID();
        UUID mealPlanId = UUID.randomUUID();
        UUID recipeId = UUID.randomUUID();
        UUID ingredientId = UUID.randomUUID();
        when(mealPlanRepository.findById(mealPlanId)).thenReturn(Optional.of(mealPlan(userId, mealPlanId)));
        when(mealPlanEntryRepository.findByMealPlanId(mealPlanId)).thenReturn(List.of(entry(mealPlanId, recipeId)));
        when(recipeIngredientRepository.findByRecipeIdOrderBySortOrderAsc(recipeId))
                .thenReturn(List.of(ingredient("Tomatoes", "g", "500", ingredientId)));
        when(pantryItemRepository.findByUserIdAndIngredientIdIn(any(), any(Set.class)))
                .thenReturn(List.of(pantry("Tomatoes", "ml", "240", ingredientId)));
        when(pricingService.getLatestPricePerUnit(ingredientId, "US")).thenReturn(Optional.empty());

        groceryService.generateFromMealPlan(userId, mealPlanId);

        ArgumentCaptor<GroceryItem> itemCaptor = ArgumentCaptor.forClass(GroceryItem.class);
        org.mockito.Mockito.verify(groceryItemRepository).save(itemCaptor.capture());
        assertThat(itemCaptor.getValue().getQuantity()).isEqualByComparingTo("500");
    }

    private static MealPlan mealPlan(UUID userId, UUID id) {
        MealPlan mealPlan = MealPlan.builder()
                .userId(userId)
                .name("Test Plan")
                .startDate(LocalDate.now())
                .endDate(LocalDate.now().plusDays(6))
                .status("ACTIVE")
                .build();
        mealPlan.setId(id);
        return mealPlan;
    }

    private static MealPlanEntry entry(UUID mealPlanId, UUID recipeId) {
        return MealPlanEntry.builder()
                .mealPlanId(mealPlanId)
                .recipeId(recipeId)
                .mealDate(LocalDate.now())
                .mealType("Dinner")
                .servings(1)
                .build();
    }

    private static RecipeIngredient ingredient(String name, String unit, String quantity, UUID ingredientId) {
        return RecipeIngredient.builder()
                .recipe(Recipe.builder().build())
                .name(name)
                .unit(unit)
                .quantity(new BigDecimal(quantity))
                .ingredientId(ingredientId)
                .build();
    }

    private static PantryItem pantry(String name, String unit, String quantity, UUID ingredientId) {
        return PantryItem.builder()
                .userId(UUID.randomUUID())
                .name(name)
                .unit(unit)
                .quantity(new BigDecimal(quantity))
                .ingredientId(ingredientId)
                .build();
    }
}
