package com.platepilote.platepilote.pantry.application.service;

import com.platepilote.platepilote.common.dto.PagedResponse;
import com.platepilote.platepilote.common.kernel.ResourceNotFoundException;
import com.platepilote.platepilote.pantry.application.dto.PantryItemRequest;
import com.platepilote.platepilote.pantry.application.dto.PantryItemResponse;
import com.platepilote.platepilote.pantry.domain.entity.PantryItem;
import com.platepilote.platepilote.pantry.domain.repository.PantryItemRepository;
import com.platepilote.platepilote.ingredients.application.service.IngredientResolutionService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional
public class PantryService {

    private final PantryItemRepository pantryItemRepository;
    private final IngredientResolutionService ingredientResolutionService;

    @Transactional(readOnly = true)
    public PagedResponse<PantryItemResponse> getAllItems(UUID userId, Pageable pageable) {
        Page<PantryItem> page = pantryItemRepository.findByUserIdAndDeletedAtIsNull(userId, pageable);

        List<PantryItemResponse> content = page.getContent()
                .stream()
                .map(this::toResponse)
                .collect(Collectors.toList());

        return PagedResponse.of(content, page.getNumber(), page.getSize(), page.getTotalElements());
    }

    @Transactional(readOnly = true)
    public List<PantryItemResponse> getItemsByCategory(UUID userId, String category) {
        return pantryItemRepository.findByUserIdAndCategoryAndDeletedAtIsNull(userId, category)
                .stream()
                .map(this::toResponse)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<PantryItemResponse> getExpiringItems(UUID userId, int daysAhead) {
        LocalDate threshold = LocalDate.now().plusDays(daysAhead);
        return pantryItemRepository.findExpiringItems(userId, threshold)
                .stream()
                .map(this::toResponse)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<PantryItemResponse> searchItems(UUID userId, String query) {
        return pantryItemRepository.searchByUserIdAndQuery(userId, query)
                .stream()
                .map(this::toResponse)
                .collect(Collectors.toList());
    }

    public PantryItemResponse addItem(UUID userId, PantryItemRequest request) {
        PantryItem item = PantryItem.builder()
                .userId(userId)
                .name(request.getName())
                .category(request.getCategory())
                .quantity(request.getQuantity())
                .unit(request.getUnit())
                .expirationDate(request.getExpirationDate())
                .ingredientId(ingredientResolutionService.resolveIngredientId(request.getName()).orElse(null))
                .build();

        PantryItem saved = pantryItemRepository.save(item);
        return toResponse(saved);
    }

    public PantryItemResponse updateItem(UUID userId, UUID itemId, PantryItemRequest request) {
        PantryItem item = pantryItemRepository.findById(itemId)
                .orElseThrow(() -> new ResourceNotFoundException("PantryItem", "id", itemId.toString()));

        if (!item.getUserId().equals(userId)) {
            throw new ResourceNotFoundException("PantryItem", "id", itemId.toString());
        }

        item.setName(request.getName());
        item.setCategory(request.getCategory());
        item.setQuantity(request.getQuantity());
        item.setUnit(request.getUnit());
        item.setExpirationDate(request.getExpirationDate());
        item.setIngredientId(ingredientResolutionService.resolveIngredientId(request.getName()).orElse(null));

        PantryItem saved = pantryItemRepository.save(item);
        return toResponse(saved);
    }

    public void removeItem(UUID userId, UUID itemId) {
        PantryItem item = pantryItemRepository.findById(itemId)
                .orElseThrow(() -> new ResourceNotFoundException("PantryItem", "id", itemId.toString()));

        if (!item.getUserId().equals(userId)) {
            throw new ResourceNotFoundException("PantryItem", "id", itemId.toString());
        }

        item.softDelete();
        pantryItemRepository.save(item);
    }

    public void consumeItem(UUID userId, UUID itemId, java.math.BigDecimal amount) {
        PantryItem item = pantryItemRepository.findById(itemId)
                .orElseThrow(() -> new ResourceNotFoundException("PantryItem", "id", itemId.toString()));

        if (!item.getUserId().equals(userId)) {
            throw new ResourceNotFoundException("PantryItem", "id", itemId.toString());
        }

        java.math.BigDecimal newQuantity = item.getQuantity().subtract(amount);
        if (newQuantity.compareTo(java.math.BigDecimal.ZERO) <= 0) {
            item.softDelete();
        } else {
            item.setQuantity(newQuantity);
        }

        pantryItemRepository.save(item);
    }

    private PantryItemResponse toResponse(PantryItem item) {
        boolean isExpired = item.getExpirationDate() != null && item.getExpirationDate().isBefore(LocalDate.now());

        return PantryItemResponse.builder()
                .id(item.getId())
                .name(item.getName())
                .category(item.getCategory())
                .quantity(item.getQuantity())
                .unit(item.getUnit())
                .expirationDate(item.getExpirationDate())
                .ingredientId(item.getIngredientId())
                .isExpired(isExpired)
                .createdAt(item.getCreatedAt())
                .updatedAt(item.getUpdatedAt())
                .build();
    }
}
