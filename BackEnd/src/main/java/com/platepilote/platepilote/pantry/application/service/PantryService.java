package com.platepilote.platepilote.pantry.application.service;

import com.platepilote.platepilote.common.dto.PagedResponse;
import com.platepilote.platepilote.common.kernel.ResourceNotFoundException;
import com.platepilote.platepilote.common.security.SecurityUtils;
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

/**
 * Service métier pour la gestion du garde-manger.
 * Gère le cycle de vie complet des articles (CRUD, consommation, recherche).
 */
@Service
@RequiredArgsConstructor
@Transactional
public class PantryService {

    private final PantryItemRepository pantryItemRepository;
    private final IngredientResolutionService ingredientResolutionService;
    private final SecurityUtils securityUtils;

    /**
     * Récupère tous les articles actifs d'un utilisateur avec pagination.
     *
     * @param userId   identifiant de l'utilisateur
     * @param pageable paramètres de pagination et tri
     * @return réponse paginée contenant les articles
     */
    @Transactional(readOnly = true)
    public PagedResponse<PantryItemResponse> getAllItems(UUID userId, Pageable pageable) {
        Page<PantryItem> page = pantryItemRepository.findByUserIdAndDeletedAtIsNull(userId, pageable);

        List<PantryItemResponse> content = page.getContent()
                .stream()
                .map(this::toResponse)
                .collect(Collectors.toList());

        return PagedResponse.of(content, page.getNumber(), page.getSize(), page.getTotalElements());
    }

    /**
     * Récupère les articles d'un utilisateur filtrés par catégorie.
     *
     * @param userId   identifiant de l'utilisateur
     * @param category catégorie souhaitée
     * @return liste des articles correspondant à la catégorie
     */
    @Transactional(readOnly = true)
    public List<PantryItemResponse> getItemsByCategory(UUID userId, String category) {
        return pantryItemRepository.findByUserIdAndCategoryAndDeletedAtIsNull(userId, category)
                .stream()
                .map(this::toResponse)
                .collect(Collectors.toList());
    }

    /**
     * Récupère les articles qui expirent dans un nombre de jours donné.
     *
     * @param userId    identifiant de l'utilisateur
     * @param daysAhead nombre de jours à venir
     * @return liste des articles proches de la péremption
     */
    @Transactional(readOnly = true)
    public List<PantryItemResponse> getExpiringItems(UUID userId, int daysAhead) {
        LocalDate threshold = LocalDate.now().plusDays(daysAhead);
        return pantryItemRepository.findExpiringItems(userId, threshold)
                .stream()
                .map(this::toResponse)
                .collect(Collectors.toList());
    }

    /**
     * Recherche des articles par nom (correspondance partielle et insensible à la casse).
     *
     * @param userId identifiant de l'utilisateur
     * @param query  terme de recherche
     * @return liste des articles correspondant à la recherche
     */
    @Transactional(readOnly = true)
    public List<PantryItemResponse> searchItems(UUID userId, String query) {
        return pantryItemRepository.searchByUserIdAndQuery(userId, query)
                .stream()
                .map(this::toResponse)
                .collect(Collectors.toList());
    }

    /**
     * Ajoute un nouvel article dans le garde-manger.
     *
     * @param userId  identifiant de l'utilisateur
     * @param request données de l'article à créer
     * @return l'article créé
     */
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

    /**
     * Met à jour un article existant.
     *
     * @param userId  identifiant de l'utilisateur propriétaire
     * @param itemId  identifiant de l'article
     * @param request nouvelles données
     * @return l'article mis à jour
     */
    public PantryItemResponse updateItem(UUID userId, UUID itemId, PantryItemRequest request) {
        PantryItem item = pantryItemRepository.findById(itemId)
                .orElseThrow(() -> new ResourceNotFoundException("PantryItem", "id", itemId.toString()));

        securityUtils.verifyOwnership(item.getUserId(), userId, "PantryItem", itemId.toString());

        item.setName(request.getName());
        item.setCategory(request.getCategory());
        item.setQuantity(request.getQuantity());
        item.setUnit(request.getUnit());
        item.setExpirationDate(request.getExpirationDate());
        item.setIngredientId(ingredientResolutionService.resolveIngredientId(request.getName()).orElse(null));

        PantryItem saved = pantryItemRepository.save(item);
        return toResponse(saved);
    }

    /**
     * Supprime (soft-delete) un article du garde-manger.
     *
     * @param userId identifiant de l'utilisateur propriétaire
     * @param itemId identifiant de l'article
     */
    public void removeItem(UUID userId, UUID itemId) {
        PantryItem item = pantryItemRepository.findById(itemId)
                .orElseThrow(() -> new ResourceNotFoundException("PantryItem", "id", itemId.toString()));

        securityUtils.verifyOwnership(item.getUserId(), userId, "PantryItem", itemId.toString());

        item.softDelete();
        pantryItemRepository.save(item);
    }

    /**
     * Consomme une partie de la quantité d'un article.
     * Si la quantité restante devient <= 0, l'article est supprimé (soft-delete).
     *
     * @param userId identifiant de l'utilisateur propriétaire
     * @param itemId identifiant de l'article
     * @param amount quantité consommée
     */
    public void consumeItem(UUID userId, UUID itemId, java.math.BigDecimal amount) {
        PantryItem item = pantryItemRepository.findById(itemId)
                .orElseThrow(() -> new ResourceNotFoundException("PantryItem", "id", itemId.toString()));

        securityUtils.verifyOwnership(item.getUserId(), userId, "PantryItem", itemId.toString());

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
