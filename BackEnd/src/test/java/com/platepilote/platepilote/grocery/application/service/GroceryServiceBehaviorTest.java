package com.platepilote.platepilote.grocery.application.service;

import com.platepilote.platepilote.budget.domain.repository.BudgetRepository;
import com.platepilote.platepilote.common.kernel.ResourceNotFoundException;
import com.platepilote.platepilote.common.security.SecurityUtils;
import com.platepilote.platepilote.grocery.application.dto.GroceryItemRequest;
import com.platepilote.platepilote.grocery.application.dto.GroceryListRequest;
import com.platepilote.platepilote.grocery.domain.entity.GroceryItem;
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
import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.verifyNoInteractions;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class GroceryServiceBehaviorTest {

    @Mock private GroceryListRepository lists;
    @Mock private GroceryItemRepository items;
    @Mock private MealPlanRepository mealPlans;
    @Mock private MealPlanEntryRepository mealPlanEntries;
    @Mock private RecipeIngredientRepository recipeIngredients;
    @Mock private PantryItemRepository pantryItems;
    @Mock private PricingService pricing;
    @Mock private UserProfileRepository profiles;
    @Mock private BudgetRepository budgets;
    @Mock private SecurityUtils securityUtils;
    @Mock private PurchaseRecordRepository purchases;

    private GroceryService service;

    @BeforeEach
    void setUp() {
        service = new GroceryService(
                lists, items, mealPlans, mealPlanEntries, recipeIngredients, pantryItems,
                pricing, profiles, budgets, securityUtils, purchases);
    }

    @Test
    void createListPersistsAnActiveList() {
        UUID userId = UUID.randomUUID();
        UUID listId = UUID.randomUUID();
        when(lists.save(any(GroceryList.class))).thenAnswer(invocation -> {
            GroceryList list = invocation.getArgument(0);
            list.setId(listId);
            return list;
        });

        var response = service.createList(
                userId, GroceryListRequest.builder().name("Weekly").build());

        assertThat(response.id()).isEqualTo(listId);
        assertThat(response.status()).isEqualTo("ACTIVE");
        verify(lists).save(any(GroceryList.class));
    }

    @Test
    void addItemVerifiesOwnershipAndPersistsTheItem() {
        UUID userId = UUID.randomUUID();
        UUID listId = UUID.randomUUID();
        GroceryList list = list(listId, userId);
        when(lists.findById(listId)).thenReturn(Optional.of(list));
        when(items.findByGroceryListIdOrderBySortOrderAsc(listId)).thenReturn(List.of());

        var response = service.addItem(userId, listId, GroceryItemRequest.builder()
                .name("Rice")
                .quantity(new BigDecimal("2"))
                .unit("kg")
                .build());

        assertThat(response.items()).isEmpty();
        verify(securityUtils).verifyOwnership(userId, userId, "GroceryList", listId.toString());
        verify(items).save(any(GroceryItem.class));
    }

    @Test
    void toggleItemCheckedFlipsTheCurrentValue() {
        UUID userId = UUID.randomUUID();
        UUID listId = UUID.randomUUID();
        UUID itemId = UUID.randomUUID();
        GroceryItem item = item(itemId, listId, false);
        when(items.findById(itemId)).thenReturn(Optional.of(item));
        when(lists.findById(listId)).thenReturn(Optional.of(list(listId, userId)));

        service.toggleItemChecked(userId, itemId);

        assertThat(item.getChecked()).isTrue();
        verify(items).save(item);
    }

    @Test
    void removeItemDeletesTheOwnedItem() {
        UUID userId = UUID.randomUUID();
        UUID listId = UUID.randomUUID();
        UUID itemId = UUID.randomUUID();
        GroceryItem item = item(itemId, listId, true);
        when(items.findById(itemId)).thenReturn(Optional.of(item));
        when(lists.findById(listId)).thenReturn(Optional.of(list(listId, userId)));

        service.removeItem(userId, itemId);

        verify(items).delete(item);
    }

    @Test
    void completeListUpdatesItsStatus() {
        UUID userId = UUID.randomUUID();
        UUID listId = UUID.randomUUID();
        GroceryList list = list(listId, userId);
        when(lists.findById(listId)).thenReturn(Optional.of(list));

        service.completeList(userId, listId);

        assertThat(list.getStatus()).isEqualTo("COMPLETED");
        verify(lists).save(list);
    }

    @Test
    void deleteListRemovesItemsAndSoftDeletesTheList() {
        UUID userId = UUID.randomUUID();
        UUID listId = UUID.randomUUID();
        GroceryList list = list(listId, userId);
        when(lists.findById(listId)).thenReturn(Optional.of(list));

        service.deleteList(userId, listId);

        assertThat(list.isDeleted()).isTrue();
        verify(items).deleteByGroceryListId(listId);
        verify(lists).save(list);
    }

    @Test
    void listOwnedByAnotherUserIsNotVisible() {
        UUID userId = UUID.randomUUID();
        UUID listId = UUID.randomUUID();
        when(lists.findById(listId)).thenReturn(Optional.of(list(listId, UUID.randomUUID())));

        assertThatThrownBy(() -> service.getListById(userId, listId))
                .isInstanceOf(ResourceNotFoundException.class);

        verifyNoInteractions(items);
    }

    private static GroceryList list(UUID id, UUID userId) {
        GroceryList list = GroceryList.builder()
                .userId(userId)
                .name("Test list")
                .status("ACTIVE")
                .build();
        list.setId(id);
        return list;
    }

    private static GroceryItem item(UUID id, UUID listId, boolean checked) {
        GroceryItem item = GroceryItem.builder()
                .groceryListId(listId)
                .name("Rice")
                .quantity(new BigDecimal("2"))
                .unit("kg")
                .checked(checked)
                .build();
        item.setId(id);
        return item;
    }
}
