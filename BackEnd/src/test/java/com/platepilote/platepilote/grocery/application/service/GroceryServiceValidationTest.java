package com.platepilote.platepilote.grocery.application.service;

import com.platepilote.platepilote.budget.domain.repository.BudgetRepository;
import com.platepilote.platepilote.common.kernel.BusinessRuleViolationException;
import com.platepilote.platepilote.common.kernel.ResourceNotFoundException;
import com.platepilote.platepilote.common.security.SecurityUtils;
import com.platepilote.platepilote.grocery.domain.entity.GroceryList;
import com.platepilote.platepilote.grocery.domain.repository.GroceryItemRepository;
import com.platepilote.platepilote.grocery.domain.repository.GroceryListRepository;
import com.platepilote.platepilote.grocery.domain.repository.PurchaseRecordRepository;
import com.platepilote.platepilote.mealplanning.domain.repository.MealPlanEntryRepository;
import com.platepilote.platepilote.mealplanning.domain.repository.MealPlanRepository;
import com.platepilote.platepilote.pantry.domain.repository.PantryItemRepository;
import com.platepilote.platepilote.pricing.application.service.PricingService;
import com.platepilote.platepilote.recipes.domain.repository.RecipeIngredientRepository;
import com.platepilote.platepilote.userprofile.domain.repository.UserProfileRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.Mockito.verifyNoInteractions;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class GroceryServiceValidationTest {

    @Mock private GroceryListRepository groceryListRepository;
    @Mock private GroceryItemRepository groceryItemRepository;
    @Mock private MealPlanRepository mealPlanRepository;
    @Mock private MealPlanEntryRepository mealPlanEntryRepository;
    @Mock private RecipeIngredientRepository recipeIngredientRepository;
    @Mock private PantryItemRepository pantryItemRepository;
    @Mock private PricingService pricingService;
    @Mock private UserProfileRepository userProfileRepository;
    @Mock private BudgetRepository budgetRepository;
    @Mock private SecurityUtils securityUtils;
    @Mock private PurchaseRecordRepository purchaseRecordRepository;

    private GroceryService service;

    @BeforeEach
    void setUp() {
        service = new GroceryService(
                groceryListRepository,
                groceryItemRepository,
                mealPlanRepository,
                mealPlanEntryRepository,
                recipeIngredientRepository,
                pantryItemRepository,
                pricingService,
                userProfileRepository,
                budgetRepository,
                securityUtils,
                purchaseRecordRepository);
    }

    @Test
    void checkoutRejectsAnEmptySelectionBeforeLoadingTheList() {
        assertThatThrownBy(() -> service.checkoutList(
                UUID.randomUUID(), UUID.randomUUID(), List.of(), null))
                .isInstanceOf(BusinessRuleViolationException.class);

        verifyNoInteractions(groceryListRepository, groceryItemRepository, pantryItemRepository,
                purchaseRecordRepository, budgetRepository);
    }

    @Test
    void checkoutRejectsNegativeActualPricesBeforeMutatingState() {
        UUID itemId = UUID.randomUUID();

        assertThatThrownBy(() -> service.checkoutList(
                UUID.randomUUID(), UUID.randomUUID(), List.of(itemId),
                Map.of(itemId, new BigDecimal("-0.01"))))
                .isInstanceOf(BusinessRuleViolationException.class);

        verifyNoInteractions(groceryListRepository, groceryItemRepository, pantryItemRepository,
                purchaseRecordRepository, budgetRepository);
    }

    @Test
    void checkoutRejectsItemIdsThatDoNotBelongToTheSelectedList() {
        UUID userId = UUID.randomUUID();
        UUID listId = UUID.randomUUID();
        GroceryList list = activeList(userId, listId);
        when(groceryListRepository.findById(listId)).thenReturn(Optional.of(list));
        when(groceryItemRepository.findByGroceryListIdOrderBySortOrderAsc(listId)).thenReturn(List.of());

        assertThatThrownBy(() -> service.checkoutList(
                userId, listId, List.of(UUID.randomUUID()), null))
                .isInstanceOf(BusinessRuleViolationException.class);

        verifyNoInteractions(pantryItemRepository, purchaseRecordRepository, budgetRepository);
    }

    @Test
    void deletedGroceryListCannotBeReadById() {
        UUID userId = UUID.randomUUID();
        UUID listId = UUID.randomUUID();
        GroceryList list = activeList(userId, listId);
        list.softDelete();
        when(groceryListRepository.findById(listId)).thenReturn(Optional.of(list));

        assertThatThrownBy(() -> service.getListById(userId, listId))
                .isInstanceOf(ResourceNotFoundException.class);
    }

    private static GroceryList activeList(UUID userId, UUID listId) {
        GroceryList list = GroceryList.builder()
                .userId(userId)
                .name("Test list")
                .status("ACTIVE")
                .build();
        list.setId(listId);
        return list;
    }
}
