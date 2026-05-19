package com.platepilote.platepilote.grocery.application.service;

import com.platepilote.platepilote.common.dto.PagedResponse;
import com.platepilote.platepilote.common.kernel.ResourceNotFoundException;
import com.platepilote.platepilote.grocery.application.dto.GroceryItemRequest;
import com.platepilote.platepilote.grocery.application.dto.GroceryListRequest;
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
import com.platepilote.platepilote.recipes.domain.entity.RecipeIngredient;
import com.platepilote.platepilote.recipes.domain.repository.RecipeIngredientRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional
public class GroceryService {

    private final GroceryListRepository groceryListRepository;
    private final GroceryItemRepository groceryItemRepository;
    private final MealPlanRepository mealPlanRepository;
    private final MealPlanEntryRepository mealPlanEntryRepository;
    private final RecipeIngredientRepository recipeIngredientRepository;
    private final PantryItemRepository pantryItemRepository;

    @Transactional(readOnly = true)
    public PagedResponse<GroceryListResponse> getUserLists(UUID userId, Pageable pageable) {
        Page<GroceryList> page = groceryListRepository.findByUserIdAndDeletedAtIsNull(userId, pageable);
        List<GroceryListResponse> content = page.getContent()
                .stream()
                .map(this::toListResponse)
                .collect(Collectors.toList());

        return PagedResponse.of(content, page.getNumber(), page.getSize(), page.getTotalElements());
    }

    @Transactional(readOnly = true)
    public GroceryListResponse getListById(UUID userId, UUID listId) {
        GroceryList list = groceryListRepository.findById(listId)
                .orElseThrow(() -> new ResourceNotFoundException("GroceryList", "id", listId.toString()));

        if (!list.getUserId().equals(userId)) {
            throw new ResourceNotFoundException("GroceryList", "id", listId.toString());
        }

        return toFullListResponse(list);
    }

    public GroceryListResponse createList(UUID userId, GroceryListRequest request) {
        GroceryList list = GroceryList.builder()
                .userId(userId)
                .name(request.getName())
                .status("ACTIVE")
                .build();

        GroceryList saved = groceryListRepository.save(list);
        return toListResponse(saved);
    }

    public GroceryListResponse addItem(UUID userId, UUID listId, GroceryItemRequest request) {
        GroceryList list = groceryListRepository.findById(listId)
                .orElseThrow(() -> new ResourceNotFoundException("GroceryList", "id", listId.toString()));

        if (!list.getUserId().equals(userId)) {
            throw new ResourceNotFoundException("GroceryList", "id", listId.toString());
        }

        GroceryItem item = GroceryItem.builder()
                .groceryListId(listId)
                .name(request.getName())
                .category(request.getCategory())
                .quantity(request.getQuantity())
                .unit(request.getUnit())
                .estimatedPrice(request.getEstimatedPrice())
                .checked(false)
                .notes(request.getNotes())
                .sortOrder(request.getSortOrder())
                .build();

        groceryItemRepository.save(item);
        return toFullListResponse(list);
    }

    public void toggleItemChecked(UUID userId, UUID itemId) {
        GroceryItem item = groceryItemRepository.findById(itemId)
                .orElseThrow(() -> new ResourceNotFoundException("GroceryItem", "id", itemId.toString()));

        GroceryList list = groceryListRepository.findById(item.getGroceryListId())
                .orElseThrow(() -> new ResourceNotFoundException("GroceryList", "id", item.getGroceryListId().toString()));

        if (!list.getUserId().equals(userId)) {
            throw new ResourceNotFoundException("GroceryList", "id", item.getGroceryListId().toString());
        }

        item.setChecked(!item.getChecked());
        groceryItemRepository.save(item);
    }

    public void removeItem(UUID userId, UUID itemId) {
        GroceryItem item = groceryItemRepository.findById(itemId)
                .orElseThrow(() -> new ResourceNotFoundException("GroceryItem", "id", itemId.toString()));

        GroceryList list = groceryListRepository.findById(item.getGroceryListId())
                .orElseThrow(() -> new ResourceNotFoundException("GroceryList", "id", item.getGroceryListId().toString()));

        if (!list.getUserId().equals(userId)) {
            throw new ResourceNotFoundException("GroceryList", "id", item.getGroceryListId().toString());
        }

        groceryItemRepository.delete(item);
    }

    public void completeList(UUID userId, UUID listId) {
        GroceryList list = groceryListRepository.findById(listId)
                .orElseThrow(() -> new ResourceNotFoundException("GroceryList", "id", listId.toString()));

        if (!list.getUserId().equals(userId)) {
            throw new ResourceNotFoundException("GroceryList", "id", listId.toString());
        }

        list.setStatus("COMPLETED");
        groceryListRepository.save(list);
    }

    public GroceryListResponse generateFromMealPlan(UUID userId, UUID mealPlanId) {
        MealPlan mealPlan = mealPlanRepository.findById(mealPlanId)
                .orElseThrow(() -> new ResourceNotFoundException("MealPlan", "id", mealPlanId.toString()));
        if (!mealPlan.getUserId().equals(userId)) {
            throw new ResourceNotFoundException("MealPlan", "id", mealPlanId.toString());
        }

        List<MealPlanEntry> entries = mealPlanEntryRepository.findByMealPlanId(mealPlanId);
        Map<String, GroceryItemAggregate> aggregatedItems = new HashMap<>();
        List<PantryItem> pantryItems = pantryItemRepository
                .findByUserIdAndDeletedAtIsNull(userId, PageRequest.of(0, 500))
                .getContent();

        for (MealPlanEntry entry : entries) {
            List<RecipeIngredient> ingredients = recipeIngredientRepository
                    .findByRecipeIdOrderBySortOrderAsc(entry.getRecipeId());

            for (RecipeIngredient ri : ingredients) {
                String key = groceryKey(ri);
                boolean alreadyInPantry = pantryItems.stream().anyMatch(pi -> pantryCovers(pi, ri));
                if (alreadyInPantry) continue;

                aggregatedItems.merge(key,
                        new GroceryItemAggregate(ri.getName(), ri.getQuantity(), ri.getUnit(), ri.getNotes(), ri.getIngredientId(), 1),
                        (existing, incoming) -> new GroceryItemAggregate(
                                existing.name,
                                existing.totalQuantity.add(incoming.totalQuantity),
                                existing.unit,
                                existing.notes != null ? existing.notes : incoming.notes,
                                existing.ingredientId != null ? existing.ingredientId : incoming.ingredientId,
                                existing.count + 1
                        ));
            }
        }

        GroceryList list = GroceryList.builder()
                .userId(userId)
                .name("Grocery List for " + mealPlan.getName())
                .status("ACTIVE")
                .build();
        GroceryList saved = groceryListRepository.save(list);

        int sortOrder = 0;
        for (Map.Entry<String, GroceryItemAggregate> entry : aggregatedItems.entrySet()) {
            GroceryItemAggregate agg = entry.getValue();
            GroceryItem item = GroceryItem.builder()
                    .groceryListId(saved.getId())
                    .name(agg.name)
                    .quantity(agg.totalQuantity)
                    .unit(agg.unit)
                    .checked(false)
                    .notes(agg.notes)
                    .ingredientId(agg.ingredientId)
                    .sortOrder(sortOrder++)
                    .build();
            groceryItemRepository.save(item);
        }

        return toFullListResponse(saved);
    }

    public void deleteList(UUID userId, UUID listId) {
        GroceryList list = groceryListRepository.findById(listId)
                .orElseThrow(() -> new ResourceNotFoundException("GroceryList", "id", listId.toString()));

        if (!list.getUserId().equals(userId)) {
            throw new ResourceNotFoundException("GroceryList", "id", listId.toString());
        }

        groceryItemRepository.deleteByGroceryListId(listId);
        list.softDelete();
        groceryListRepository.save(list);
    }

    private GroceryListResponse toListResponse(GroceryList list) {
        return new GroceryListResponse(
                list.getId(),
                list.getName(),
                list.getStatus(),
                null,
                list.getCreatedAt(),
                list.getUpdatedAt()
        );
    }

    private GroceryListResponse toFullListResponse(GroceryList list) {
        List<GroceryItemResponse> items = groceryItemRepository
                .findByGroceryListIdOrderBySortOrderAsc(list.getId())
                .stream()
                .map(this::toItemResponse)
                .collect(Collectors.toList());

        return new GroceryListResponse(
                list.getId(),
                list.getName(),
                list.getStatus(),
                items,
                list.getCreatedAt(),
                list.getUpdatedAt()
        );
    }

    private GroceryItemResponse toItemResponse(GroceryItem item) {
        return new GroceryItemResponse(
                item.getId(),
                item.getName(),
                item.getCategory(),
                item.getQuantity(),
                item.getUnit(),
                item.getEstimatedPrice(),
                item.getChecked(),
                item.getNotes(),
                item.getSortOrder(),
                item.getIngredientId()
        );
    }

    private String groceryKey(RecipeIngredient ingredient) {
        if (ingredient.getIngredientId() != null) {
            return "ingredient:" + ingredient.getIngredientId();
        }
        return "name:" + normalizeName(ingredient.getName());
    }

    private boolean pantryCovers(PantryItem pantryItem, RecipeIngredient recipeIngredient) {
        if (pantryItem.getIngredientId() != null && recipeIngredient.getIngredientId() != null) {
            return pantryItem.getIngredientId().equals(recipeIngredient.getIngredientId())
                    && sameUnit(pantryItem.getUnit(), recipeIngredient.getUnit())
                    && pantryItem.getQuantity().compareTo(recipeIngredient.getQuantity()) >= 0;
        }

        String pantryName = normalizeName(pantryItem.getName());
        String recipeName = normalizeName(recipeIngredient.getName());
        return !pantryName.isBlank()
                && !recipeName.isBlank()
                && (pantryName.contains(recipeName) || recipeName.contains(pantryName))
                && sameUnit(pantryItem.getUnit(), recipeIngredient.getUnit())
                && pantryItem.getQuantity().compareTo(recipeIngredient.getQuantity()) >= 0;
    }

    private boolean sameUnit(String left, String right) {
        return normalizeName(left).equals(normalizeName(right));
    }

    private String normalizeName(String value) {
        return value == null ? "" : value.trim().toLowerCase();
    }

    public record GroceryListResponse(
            UUID id,
            String name,
            String status,
            List<GroceryItemResponse> items,
            java.time.Instant createdAt,
            java.time.Instant updatedAt
    ) {}

    public record GroceryItemResponse(
            UUID id,
            String name,
            String category,
            java.math.BigDecimal quantity,
            String unit,
            java.math.BigDecimal estimatedPrice,
            Boolean checked,
            String notes,
            Integer sortOrder,
            UUID ingredientId
    ) {}

    private record GroceryItemAggregate(
            String name,
            BigDecimal totalQuantity,
            String unit,
            String notes,
            UUID ingredientId,
            int count
    ) {}
}
