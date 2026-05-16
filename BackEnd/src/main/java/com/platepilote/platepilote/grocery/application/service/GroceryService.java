package com.platepilote.platepilote.grocery.application.service;

import com.platepilote.platepilote.common.dto.PagedResponse;
import com.platepilote.platepilote.common.kernel.ResourceNotFoundException;
import com.platepilote.platepilote.grocery.application.dto.GroceryItemRequest;
import com.platepilote.platepilote.grocery.application.dto.GroceryListRequest;
import com.platepilote.platepilote.grocery.domain.entity.GroceryItem;
import com.platepilote.platepilote.grocery.domain.entity.GroceryList;
import com.platepilote.platepilote.grocery.domain.repository.GroceryItemRepository;
import com.platepilote.platepilote.grocery.domain.repository.GroceryListRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional
public class GroceryService {

    private final GroceryListRepository groceryListRepository;
    private final GroceryItemRepository groceryItemRepository;

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
                item.getSortOrder()
        );
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
            Integer sortOrder
    ) {}
}
