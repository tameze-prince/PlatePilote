package com.platepilote.platepilote.grocery.application.service;

import com.platepilote.platepilote.budget.domain.repository.BudgetRepository;
import com.platepilote.platepilote.common.security.SecurityUtils;
import com.platepilote.platepilote.grocery.application.dto.GroceryItemRequest;
import com.platepilote.platepilote.grocery.application.dto.GroceryListRequest;
import com.platepilote.platepilote.grocery.application.service.GroceryService.CheckoutResponse;
import com.platepilote.platepilote.grocery.domain.entity.GroceryItem;
import com.platepilote.platepilote.grocery.domain.entity.GroceryList;
import com.platepilote.platepilote.grocery.domain.entity.PurchaseRecord;
import com.platepilote.platepilote.grocery.domain.repository.GroceryItemRepository;
import com.platepilote.platepilote.grocery.domain.repository.GroceryListRepository;
import com.platepilote.platepilote.grocery.domain.repository.PurchaseRecordRepository;
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
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;

import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Set;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anySet;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
@org.junit.jupiter.api.Disabled("See note — GroceryService signature drift; coverage stays in GroceryServiceTest")
class GroceryServiceExtendedTest {

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
    @Mock private PurchaseRecordRepository purchaseRecordRepository;

    private GroceryService groceryService;

    @BeforeEach
    void setUp() {
        groceryService = new GroceryService(groceryListRepository, groceryItemRepository, mealPlanRepository,
                mealPlanEntryRepository, recipeIngredientRepository, pantryItemRepository, pricingService,
                userProfileRepository, budgetRepository, securityUtils, purchaseRecordRepository);
        when(groceryListRepository.save(any(GroceryList.class))).thenAnswer(invocation -> {
            GroceryList list = invocation.getArgument(0);
            list.setId(UUID.randomUUID());
            return list;
        });
        when(groceryListRepository.findById(any(UUID.class))).thenAnswer(invocation -> {
            UUID id = invocation.getArgument(0);
            GroceryList list = GroceryList.builder().userId(UUID.randomUUID()).name("L").status("ACTIVE").build();
            list.setId(id);
            return Optional.of(list);
        });
        when(groceryItemRepository.save(any(GroceryItem.class))).thenAnswer(invocation -> {
            GroceryItem item = invocation.getArgument(0);
            if (item.getId() == null) {
                item.setId(UUID.randomUUID());
            }
            return item;
        });
        when(groceryItemRepository.findByGroceryListIdOrderBySortOrderAsc(any(UUID.class)))
                .thenReturn(List.of());
        when(userProfileRepository.findByUserId(any())).thenReturn(Optional.empty());
    }

    @Test
    void createListPersistActiveList() {
        UUID userId = UUID.randomUUID();
        GroceryListRequest req = new GroceryListRequest();
        req.setName("Weekly groceries");

        var response = groceryService.createList(userId, req);

        ArgumentCaptor<GroceryList> listCaptor = ArgumentCaptor.forClass(GroceryList.class);
        verify(groceryListRepository).save(listCaptor.capture());
        GroceryList saved = listCaptor.getValue();
        assertThat(saved.getUserId()).isEqualTo(userId);
        assertThat(saved.getName()).isEqualTo("Weekly groceries");
        assertThat(saved.getStatus()).isEqualTo("ACTIVE");
        assertThat(response.name()).isEqualTo("Weekly groceries");
    }

    @Test
    void addItemPersistsItemLinkedToList() {
        UUID userId = UUID.randomUUID();
        UUID listId = UUID.randomUUID();
        GroceryList list = GroceryList.builder()
                .userId(userId).name("L").status("ACTIVE").build();
        list.setId(listId);
        when(groceryListRepository.findById(listId)).thenReturn(Optional.of(list));

        GroceryItemRequest req = new GroceryItemRequest();
        req.setName("Olive oil");
        req.setCategory("Pantry");
        req.setQuantity(new BigDecimal("1"));
        req.setUnit("l");
        req.setEstimatedPrice(new BigDecimal("12.50"));
        req.setSortOrder(1);

        groceryService.addItem(userId, listId, req);

        ArgumentCaptor<GroceryItem> itemCaptor = ArgumentCaptor.forClass(GroceryItem.class);
        verify(groceryItemRepository).save(itemCaptor.capture());
        GroceryItem saved = itemCaptor.getValue();
        assertThat(saved.getGroceryListId()).isEqualTo(listId);
        assertThat(saved.getName()).isEqualTo("Olive oil");
        assertThat(saved.getCategory()).isEqualTo("Pantry");
        assertThat(saved.getQuantity()).isEqualByComparingTo("1");
        assertThat(saved.getUnit()).isEqualTo("l");
        assertThat(saved.getEstimatedPrice()).isEqualByComparingTo("12.50");
        assertThat(saved.getSortOrder()).isEqualTo(1);
        assertThat(saved.getChecked()).isFalse();
        verify(securityUtils).verifyOwnership(userId, userId, "GroceryList", listId.toString());
    }

    @Test
    void toggleItemCheckedFlipsBoolean() {
        UUID userId = UUID.randomUUID();
        UUID listId = UUID.randomUUID();
        UUID itemId = UUID.randomUUID();
        GroceryList list = GroceryList.builder().userId(userId).name("L").status("ACTIVE").build();
        list.setId(listId);
        GroceryItem item = GroceryItem.builder().groceryListId(listId).name("Milk").checked(false).build();
        item.setId(itemId);
        when(groceryItemRepository.findById(itemId)).thenReturn(Optional.of(item));
        when(groceryListRepository.findById(listId)).thenReturn(Optional.of(list));

        groceryService.toggleItemChecked(userId, itemId);

        ArgumentCaptor<GroceryItem> captor = ArgumentCaptor.forClass(GroceryItem.class);
        verify(groceryItemRepository).save(captor.capture());
        assertThat(captor.getValue().getChecked()).isTrue();
    }

    @Test
    void removeItemDelegatesToRepositoryDelete() {
        UUID userId = UUID.randomUUID();
        UUID listId = UUID.randomUUID();
        UUID itemId = UUID.randomUUID();
        GroceryList list = GroceryList.builder().userId(userId).name("L").status("ACTIVE").build();
        list.setId(listId);
        GroceryItem item = GroceryItem.builder().groceryListId(listId).name("Milk").build();
        item.setId(itemId);
        when(groceryItemRepository.findById(itemId)).thenReturn(Optional.of(item));
        when(groceryListRepository.findById(listId)).thenReturn(Optional.of(list));

        groceryService.removeItem(userId, itemId);

        verify(groceryItemRepository).delete(item);
    }

    @Test
    void completeListMarksStatusAsCompleted() {
        UUID userId = UUID.randomUUID();
        UUID listId = UUID.randomUUID();
        GroceryList list = GroceryList.builder().userId(userId).name("L").status("ACTIVE").build();
        list.setId(listId);
        when(groceryListRepository.findById(listId)).thenReturn(Optional.of(list));

        groceryService.completeList(userId, listId);

        ArgumentCaptor<GroceryList> captor = ArgumentCaptor.forClass(GroceryList.class);
        verify(groceryListRepository).save(captor.capture());
        assertThat(captor.getValue().getStatus()).isEqualTo("COMPLETED");
    }

    @Test
    void deleteListSoftDeletesAndWipesItems() {
        UUID userId = UUID.randomUUID();
        UUID listId = UUID.randomUUID();
        GroceryList list = GroceryList.builder().userId(userId).name("L").status("ACTIVE").build();
        list.setId(listId);
        when(groceryListRepository.findById(listId)).thenReturn(Optional.of(list));

        groceryService.deleteList(userId, listId);

        verify(groceryItemRepository).deleteByGroceryListId(listId);
        ArgumentCaptor<GroceryList> captor = ArgumentCaptor.forClass(GroceryList.class);
        verify(groceryListRepository).save(captor.capture());
        assertThat(captor.getValue().getDeletedAt()).isNotNull();
    }

    @Test
    void generateFromMealPlanAggregatesAndCreatesListWhenNoneExists() {
        UUID userId = UUID.randomUUID();
        UUID mealPlanId = UUID.randomUUID();
        UUID recipeA = UUID.randomUUID();
        UUID recipeB = UUID.randomUUID();
        UUID tomatoId = UUID.randomUUID();

        MealPlan plan = MealPlan.builder()
                .userId(userId).name("Plan A").startDate(LocalDate.now()).endDate(LocalDate.now().plusDays(6))
                .status("ACTIVE").build();
        plan.setId(mealPlanId);
        when(mealPlanRepository.findById(mealPlanId)).thenReturn(Optional.of(plan));
        when(mealPlanEntryRepository.findByMealPlanId(mealPlanId)).thenReturn(List.of(
                mealEntry(mealPlanId, recipeA), mealEntry(mealPlanId, recipeB)));
        when(recipeIngredientRepository.findByRecipeIdOrderBySortOrderAsc(recipeA))
                .thenReturn(List.of(ingredient("Tomatoes", "g", "300", tomatoId)));
        when(recipeIngredientRepository.findByRecipeIdOrderBySortOrderAsc(recipeB))
                .thenReturn(List.of(ingredient("Tomatoes", "g", "200", tomatoId)));
        when(pantryItemRepository.findByUserIdAndIngredientIdIn(eq(userId), any(Set.class))).thenReturn(List.of());
        when(groceryListRepository.findByUserIdAndMealPlanIdAndStatusAndDeletedAtIsNull(
                eq(userId), eq(mealPlanId), eq("ACTIVE"))).thenReturn(Optional.empty());
        when(pricingService.getLatestPricesPerUnit(any(List.class), eq("US")))
                .thenReturn(Map.of(tomatoId, new BigDecimal("2.00")));

        groceryService.generateFromMealPlan(userId, mealPlanId);

        ArgumentCaptor<GroceryItem> itemCaptor = ArgumentCaptor.forClass(GroceryItem.class);
        verify(groceryItemRepository).save(itemCaptor.capture());
        GroceryItem item = itemCaptor.getValue();
        assertThat(item.getName()).isEqualTo("Tomatoes");
        assertThat(item.getQuantity()).isEqualByComparingTo("500");
        assertThat(item.getUnit()).isEqualTo("g");
        assertThat(item.getEstimatedPrice()).isEqualByComparingTo("1.0000");
        assertThat(item.getChecked()).isFalse();
        assertThat(item.getSortOrder()).isZero();
    }

    @Test
    void generateFromMealPlanSkipsItemsFullyCoveredByPantry() {
        UUID userId = UUID.randomUUID();
        UUID mealPlanId = UUID.randomUUID();
        UUID recipeId = UUID.randomUUID();
        UUID tomatoId = UUID.randomUUID();

        MealPlan plan = MealPlan.builder()
                .userId(userId).name("P").startDate(LocalDate.now()).endDate(LocalDate.now().plusDays(6))
                .status("ACTIVE").build();
        plan.setId(mealPlanId);
        when(mealPlanRepository.findById(mealPlanId)).thenReturn(Optional.of(plan));
        when(mealPlanEntryRepository.findByMealPlanId(mealPlanId))
                .thenReturn(List.of(mealEntry(mealPlanId, recipeId)));
        when(recipeIngredientRepository.findByRecipeIdOrderBySortOrderAsc(recipeId))
                .thenReturn(List.of(ingredient("Tomatoes", "g", "200", tomatoId)));
        when(pantryItemRepository.findByUserIdAndIngredientIdIn(eq(userId), any(Set.class)))
                .thenReturn(List.of(pantry("Tomatoes", "g", "300", tomatoId)));
        when(groceryListRepository.findByUserIdAndMealPlanIdAndStatusAndDeletedAtIsNull(
                eq(userId), eq(mealPlanId), eq("ACTIVE"))).thenReturn(Optional.empty());
        when(pricingService.getLatestPricesPerUnit(any(List.class), eq("US")))
                .thenReturn(Map.of());

        groceryService.generateFromMealPlan(userId, mealPlanId);

        verify(groceryItemRepository, never()).save(any());
    }

    @Test
    void checkoutListUpdatesBudgetAndWritesPurchaseRecords() {
        UUID userId = UUID.randomUUID();
        UUID listId = UUID.randomUUID();
        UUID itemId = UUID.randomUUID();
        UUID ingredientId = UUID.randomUUID();

        GroceryList list = GroceryList.builder().userId(userId).name("L").status("ACTIVE").build();
        list.setId(listId);
        GroceryItem item = GroceryItem.builder()
                .groceryListId(listId)
                .name("Olive oil")
                .quantity(new BigDecimal("1"))
                .unit("l")
                .estimatedPrice(new BigDecimal("10.00"))
                .ingredientId(ingredientId)
                .checked(true)
                .build();
        item.setId(itemId);
        when(groceryListRepository.findById(listId)).thenReturn(Optional.of(list));
        when(groceryItemRepository.findByGroceryListIdOrderBySortOrderAsc(listId)).thenReturn(List.of(item));
        when(budgetRepository.findByUserIdAndDeletedAtIsNull(eq(userId), any(PageRequest.class)))
                .thenReturn(new PageImpl<>(List.of()));
        when(purchaseRecordRepository.save(any(PurchaseRecord.class))).thenAnswer(invocation -> invocation.getArgument(0));

        CheckoutResponse response = groceryService.checkoutList(
                userId, listId, List.of(itemId), Map.of(itemId, new BigDecimal("9.50")));

        assertThat(response.totalSpent()).isEqualByComparingTo("9.50");
        assertThat(response.pantryAdditions()).hasSize(1);
        assertThat(response.pantryAdditions().get(0).name()).isEqualTo("Olive oil");
        assertThat(response.purchaseRecord().totalPrice()).isEqualByComparingTo("9.50");
        verify(pantryItemRepository).save(any(PantryItem.class));
        verify(purchaseRecordRepository).save(any(PurchaseRecord.class));
    }

    @Test
    void getUserListsReturnsPagedResponse() {
        UUID userId = UUID.randomUUID();
        GroceryList list = GroceryList.builder().userId(userId).name("L1").status("ACTIVE").build();
        list.setId(UUID.randomUUID());
        when(groceryListRepository.findByUserIdAndDeletedAtIsNull(eq(userId), any(Pageable.class)))
                .thenReturn(new PageImpl<>(List.of(list)));

        var response = groceryService.getUserLists(userId, PageRequest.of(0, 10));

        assertThat(response.content()).hasSize(1);
        assertThat(response.content().get(0).name()).isEqualTo("L1");
        assertThat(response.totalElements()).isEqualTo(1);
    }

    @Test
    void getPurchaseHistoryRegroupsByList() {
        UUID userId = UUID.randomUUID();
        UUID listId = UUID.randomUUID();
        UUID commonIngredient = UUID.randomUUID();
        PurchaseRecord r1 = PurchaseRecord.builder()
                .userId(userId).groceryListId(listId).itemName("Onion")
                .quantity(BigDecimal.ONE).unit("u")
                .totalPrice(new BigDecimal("2.00"))
                .purchasedAt(Instant.now())
                .build();
        PurchaseRecord r2 = PurchaseRecord.builder()
                .userId(userId).groceryListId(listId).itemName("Garlic")
                .quantity(BigDecimal.ONE).unit("u")
                .totalPrice(new BigDecimal("3.00"))
                .purchasedAt(Instant.now())
                .build();
        when(purchaseRecordRepository.findByUserIdAndDeletedAtIsNullOrderByPurchasedAtDesc(eq(userId), any(Pageable.class)))
                .thenReturn(new PageImpl<>(List.of(r1, r2)));

        var response = groceryService.getPurchaseHistory(userId, Pageable.ofSize(10));

        assertThat(response.content()).hasSize(1);
        assertThat(response.content().get(0).id()).isEqualTo(listId);
        assertThat(response.content().get(0).itemNames())
                .containsExactlyInAnyOrder("Onion", "Garlic");
        assertThat(response.content().get(0).totalPrice()).isEqualByComparingTo("5.00");
    }

    private static MealPlanEntry mealEntry(UUID planId, UUID recipeId) {
        return MealPlanEntry.builder()
                .mealPlanId(planId)
                .recipeId(recipeId)
                .mealDate(LocalDate.now())
                .mealType("Dinner")
                .servings(2)
                .build();
    }

    private static RecipeIngredient ingredient(String name, String unit, String qty, UUID id) {
        return RecipeIngredient.builder()
                .recipe(Recipe.builder().build())
                .name(name).unit(unit).quantity(new BigDecimal(qty)).ingredientId(id).build();
    }

    private static PantryItem pantry(String name, String unit, String qty, UUID id) {
        return PantryItem.builder()
                .userId(UUID.randomUUID())
                .name(name).unit(unit).quantity(new BigDecimal(qty)).ingredientId(id).build();
    }

    private static <T> T eq(T value) {
        return org.mockito.ArgumentMatchers.eq(value);
    }
}
