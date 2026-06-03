package com.platepilote.platepilote.grocery.application.service;

import com.platepilote.platepilote.common.dto.PagedResponse;
import com.platepilote.platepilote.common.kernel.ResourceNotFoundException;
import com.platepilote.platepilote.common.security.SecurityUtils;
import com.platepilote.platepilote.grocery.application.dto.GroceryItemRequest;
import com.platepilote.platepilote.grocery.application.dto.GroceryListRequest;
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
import com.platepilote.platepilote.budget.domain.repository.BudgetRepository;
import com.platepilote.platepilote.pantry.domain.repository.PantryItemRepository;
import com.platepilote.platepilote.pricing.application.service.PricingService;
import com.platepilote.platepilote.recipes.domain.entity.RecipeIngredient;
import com.platepilote.platepilote.recipes.domain.repository.RecipeIngredientRepository;
import com.platepilote.platepilote.userprofile.domain.repository.UserProfileRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;

/**
 * Service métier pour la gestion des listes de courses.
 * <p>
 * Gère le cycle de vie complet : création de listes, ajout/suppression d'articles,
 * génération automatique depuis un plan de repas, passage en caisse avec
 * mise à jour du budget et du garde-manger, et historique des achats.
 */
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
    private final PricingService pricingService;
    private final UserProfileRepository userProfileRepository;
    private final BudgetRepository budgetRepository;
    private final SecurityUtils securityUtils;
    private final PurchaseRecordRepository purchaseRecordRepository;

    /**
     * Récupère toutes les listes de courses d'un utilisateur, de manière paginée.
     *
     * @param userId   l'identifiant de l'utilisateur
     * @param pageable les paramètres de pagination et de tri
     * @return une page de résumés de listes de courses
     */
    @Transactional(readOnly = true)
    public PagedResponse<GroceryListResponse> getUserLists(UUID userId, Pageable pageable) {
        Page<GroceryList> page = groceryListRepository.findByUserIdAndDeletedAtIsNull(userId, pageable);
        List<GroceryListResponse> content = page.getContent()
                .stream()
                .map(this::toListResponse)
                .collect(Collectors.toList());

        return PagedResponse.of(content, page.getNumber(), page.getSize(), page.getTotalElements());
    }

    /**
     * Récupère une liste de courses par son identifiant, avec le détail de ses articles.
     *
     * @param userId l'identifiant de l'utilisateur (vérification de propriété)
     * @param listId l'identifiant de la liste
     * @return la liste de courses avec ses articles
     * @throws ResourceNotFoundException si la liste n'existe pas ou n'appartient pas à l'utilisateur
     */
    @Transactional(readOnly = true)
    public GroceryListResponse getListById(UUID userId, UUID listId) {
        GroceryList list = groceryListRepository.findById(listId)
                .orElseThrow(() -> new ResourceNotFoundException("GroceryList", "id", listId.toString()));

        if (!list.getUserId().equals(userId)) {
            throw new ResourceNotFoundException("GroceryList", "id", listId.toString());
        }

        return toFullListResponse(list);
    }

    /**
     * Crée une nouvelle liste de courses pour un utilisateur.
     *
     * @param userId  l'identifiant de l'utilisateur propriétaire
     * @param request les données de la liste (nom)
     * @return le résumé de la liste créée
     */
    public GroceryListResponse createList(UUID userId, GroceryListRequest request) {
        GroceryList list = GroceryList.builder()
                .userId(userId)
                .name(request.getName())
                .status("ACTIVE")
                .build();

        GroceryList saved = groceryListRepository.save(list);
        return toListResponse(saved);
    }

    /**
     * Ajoute un article à une liste de courses existante.
     *
     * @param userId  l'identifiant de l'utilisateur (vérification de propriété)
     * @param listId  l'identifiant de la liste destinataire
     * @param request les données du nouvel article
     * @return la liste mise à jour avec ses articles
     */
    public GroceryListResponse addItem(UUID userId, UUID listId, GroceryItemRequest request) {
        GroceryList list = groceryListRepository.findById(listId)
                .orElseThrow(() -> new ResourceNotFoundException("GroceryList", "id", listId.toString()));

        securityUtils.verifyOwnership(list.getUserId(), userId, "GroceryList", listId.toString());

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

    /**
     * Bascule l'état coché/décoché d'un article.
     *
     * @param userId l'identifiant de l'utilisateur (vérification de propriété)
     * @param itemId l'identifiant de l'article
     */
    public void toggleItemChecked(UUID userId, UUID itemId) {
        GroceryItem item = groceryItemRepository.findById(itemId)
                .orElseThrow(() -> new ResourceNotFoundException("GroceryItem", "id", itemId.toString()));

        GroceryList list = groceryListRepository.findById(item.getGroceryListId())
                .orElseThrow(() -> new ResourceNotFoundException("GroceryList", "id", item.getGroceryListId().toString()));

        securityUtils.verifyOwnership(list.getUserId(), userId, "GroceryList", item.getGroceryListId().toString());

        item.setChecked(!item.getChecked());
        groceryItemRepository.save(item);
    }

    /**
     * Supprime un article d'une liste de courses.
     *
     * @param userId l'identifiant de l'utilisateur (vérification de propriété)
     * @param itemId l'identifiant de l'article à supprimer
     */
    public void removeItem(UUID userId, UUID itemId) {
        GroceryItem item = groceryItemRepository.findById(itemId)
                .orElseThrow(() -> new ResourceNotFoundException("GroceryItem", "id", itemId.toString()));

        GroceryList list = groceryListRepository.findById(item.getGroceryListId())
                .orElseThrow(() -> new ResourceNotFoundException("GroceryList", "id", item.getGroceryListId().toString()));

        securityUtils.verifyOwnership(list.getUserId(), userId, "GroceryList", item.getGroceryListId().toString());

        groceryItemRepository.delete(item);
    }

    /**
     * Marque une liste de courses comme terminée.
     *
     * @param userId l'identifiant de l'utilisateur (vérification de propriété)
     * @param listId l'identifiant de la liste à compléter
     */
    public void completeList(UUID userId, UUID listId) {
        GroceryList list = groceryListRepository.findById(listId)
                .orElseThrow(() -> new ResourceNotFoundException("GroceryList", "id", listId.toString()));

        securityUtils.verifyOwnership(list.getUserId(), userId, "GroceryList", listId.toString());

        list.setStatus("COMPLETED");
        groceryListRepository.save(list);
    }

    /**
     * Génère une liste de courses à partir d'un plan de repas.
     * <p>
     * Agrège les ingrédients de toutes les recettes du plan, soustrait les quantités
     * déjà présentes dans le garde-manger, estime les prix, et crée ou met à jour
     * une liste de courses active associée à ce plan de repas.
     *
     * @param userId     l'identifiant de l'utilisateur
     * @param mealPlanId l'identifiant du plan de repas
     * @return la liste de courses générée avec ses articles
     */
    public GroceryListResponse generateFromMealPlan(UUID userId, UUID mealPlanId) {
        MealPlan mealPlan = mealPlanRepository.findById(mealPlanId)
                .orElseThrow(() -> new ResourceNotFoundException("MealPlan", "id", mealPlanId.toString()));
        if (!mealPlan.getUserId().equals(userId)) {
            throw new ResourceNotFoundException("MealPlan", "id", mealPlanId.toString());
        }

        List<MealPlanEntry> entries = mealPlanEntryRepository.findByMealPlanId(mealPlanId);
        Map<String, GroceryItemAggregate> aggregatedItems = new HashMap<>();

        Set<UUID> requiredIngredientIds = new HashSet<>();
        for (MealPlanEntry entry : entries) {
            List<RecipeIngredient> ingredients = recipeIngredientRepository
                    .findByRecipeIdOrderBySortOrderAsc(entry.getRecipeId());
            for (RecipeIngredient ri : ingredients) {
                String key = groceryKey(ri);
                aggregatedItems.merge(key,
                        new GroceryItemAggregate(ri.getName(), ri.getQuantity(), ri.getUnit(), ri.getNotes(), ri.getIngredientId(), 1),
                        this::mergeGroceryItems);
                if (ri.getIngredientId() != null) {
                    requiredIngredientIds.add(ri.getIngredientId());
                }
            }
        }

        List<PantryItem> pantryItems = requiredIngredientIds.isEmpty()
                ? List.of()
                : pantryItemRepository.findByUserIdAndIngredientIdIn(userId, requiredIngredientIds);

        String countryCode = userProfileRepository.findByUserId(userId)
                .map(profile -> profile.getCountryCode() == null ? "US" : profile.getCountryCode())
                .orElse("US");

        GroceryList saved = groceryListRepository
                .findByUserIdAndMealPlanIdAndStatusAndDeletedAtIsNull(userId, mealPlanId, "ACTIVE")
                .map(existing -> {
                    groceryItemRepository.deleteByGroceryListId(existing.getId());
                    existing.setName("Grocery List for " + mealPlan.getName());
                    return groceryListRepository.save(existing);
                })
                .orElseGet(() -> groceryListRepository.save(GroceryList.builder()
                        .userId(userId)
                        .mealPlanId(mealPlanId)
                        .name("Grocery List for " + mealPlan.getName())
                        .status("ACTIVE")
                        .build()));
        Map<UUID, BigDecimal> prices = pricingService.getLatestPricesPerUnit(
                aggregatedItems.values().stream()
                        .map(item -> item.ingredientId)
                        .filter(java.util.Objects::nonNull)
                        .distinct()
                        .toList(),
                countryCode
        );

        int sortOrder = 0;
        for (Map.Entry<String, GroceryItemAggregate> entry : aggregatedItems.entrySet()) {
            GroceryItemAggregate agg = subtractPantry(entry.getValue(), pantryItems);
            if (agg.totalQuantity.compareTo(BigDecimal.ZERO) <= 0) {
                continue;
            }
            GroceryItem item = GroceryItem.builder()
                    .groceryListId(saved.getId())
                    .name(agg.name)
                    .quantity(agg.totalQuantity)
                    .unit(agg.unit)
                    .estimatedPrice(estimateItemPrice(agg, prices))
                    .priceConfidence(agg.ingredientId == null ? BigDecimal.ZERO : new BigDecimal("0.70"))
                    .checked(false)
                    .notes(itemNotes(agg))
                    .ingredientId(agg.ingredientId)
                    .sortOrder(sortOrder++)
                    .build();
            groceryItemRepository.save(item);
        }

        return toFullListResponse(saved);
    }

    /**
     * Effectue le passage en caisse d'une liste de courses.
     * <p>
     * Pour chaque article coché : enregistre l'achat dans l'historique, ajoute l'article
     * au garde-manger, met à jour le budget dépensé, et supprime l'article de la liste.
     * Si tous les articles sont cochés, la liste est marquée comme terminée.
     *
     * @param userId          l'identifiant de l'utilisateur
     * @param listId          l'identifiant de la liste
     * @param checkedItemIds  la liste des identifiants des articles achetés
     * @param actualPrices    les prix réels constatés (optionnel)
     * @return le résultat du passage en caisse (liste mise à jour, ajouts au garde-manger, historique)
     */
    @Transactional
    public CheckoutResponse checkoutList(UUID userId, UUID listId, List<UUID> checkedItemIds, Map<UUID, BigDecimal> actualPrices) {
        GroceryList list = groceryListRepository.findById(listId)
                .orElseThrow(() -> new ResourceNotFoundException("GroceryList", "id", listId.toString()));
        securityUtils.verifyOwnership(list.getUserId(), userId, "GroceryList", listId.toString());

        List<GroceryItem> items = groceryItemRepository.findByGroceryListIdOrderBySortOrderAsc(listId);
        List<GroceryItem> checkedItems = items.stream()
                .filter(item -> checkedItemIds.contains(item.getId()))
                .toList();

        BigDecimal totalSpent = BigDecimal.ZERO;
        List<PantryAddition> pantryAdditions = new ArrayList<>();

        for (GroceryItem item : checkedItems) {
            BigDecimal actualPrice = actualPrices != null ? actualPrices.get(item.getId()) : item.getEstimatedPrice();
            if (actualPrice != null) {
                totalSpent = totalSpent.add(actualPrice);
            }

            if (item.getIngredientId() != null) {
                pantryItemRepository.findByUserIdAndIngredientIdIn(userId, Set.of(item.getIngredientId()))
                        .stream()
                        .filter(p -> p.getExpirationDate() != null && p.getExpirationDate().isBefore(LocalDate.now()))
                        .forEach(p -> pantryItemRepository.delete(p));
            }

            PantryItem pantryItem = PantryItem.builder()
                    .userId(userId)
                    .name(item.getName())
                    .category(item.getCategory())
                    .quantity(item.getQuantity())
                    .unit(item.getUnit())
                    .ingredientId(item.getIngredientId())
                    .build();
            pantryItemRepository.save(pantryItem);

            pantryAdditions.add(new PantryAddition(
                    pantryItem.getId(),
                    item.getName(),
                    item.getQuantity(),
                    item.getUnit()
            ));

            PurchaseRecord record = PurchaseRecord.builder()
                    .userId(userId).groceryListId(listId)
                    .itemName(item.getName()).category(item.getCategory())
                    .quantity(item.getQuantity()).unit(item.getUnit())
                    .unitPrice(actualPrice != null && item.getQuantity() != null
                            && item.getQuantity().compareTo(BigDecimal.ZERO) > 0
                            ? actualPrice.divide(item.getQuantity(), 2, java.math.RoundingMode.HALF_UP)
                            : actualPrice)
                    .totalPrice(actualPrice != null ? actualPrice : BigDecimal.ZERO)
                    .ingredientId(item.getIngredientId())
                    .purchasedAt(Instant.now()).build();
            purchaseRecordRepository.save(record);

            groceryItemRepository.delete(item);
        }

        if (totalSpent.compareTo(BigDecimal.ZERO) > 0) {
            final BigDecimal finalTotalSpent = totalSpent;
            budgetRepository.findByUserIdAndDeletedAtIsNull(userId, PageRequest.of(0, 1))
                    .stream()
                    .findFirst()
                    .ifPresent(budget -> {
                        BigDecimal currentSpent = budget.getSpent() != null ? budget.getSpent() : BigDecimal.ZERO;
                        budget.setSpent(currentSpent.add(finalTotalSpent));
                        budgetRepository.save(budget);
                    });
        }

        boolean allChecked = items.stream().allMatch(item -> checkedItemIds.contains(item.getId()));
        if (allChecked) {
            list.setStatus("COMPLETED");
            groceryListRepository.save(list);
        }

        List<String> purchaseItemNames = checkedItems.stream().map(GroceryItem::getName).toList();
        PurchaseRecordResponse purchaseRecord = new PurchaseRecordResponse(
                listId, purchaseItemNames, totalSpent, Instant.now()
        );

        GroceryListResponse updatedList = toFullListResponse(list);

        return new CheckoutResponse(
                updatedList,
                pantryAdditions,
                purchaseRecord,
                totalSpent
        );
    }

    /**
     * Récupère l'historique des achats d'un utilisateur, de manière paginée.
     * <p>
     * Les achats sont regroupés par liste de courses et triés du plus récent au plus ancien.
     *
     * @param userId   l'identifiant de l'utilisateur
     * @param pageable les paramètres de pagination
     * @return une page d'enregistrements d'achats groupés
     */
    @Transactional(readOnly = true)
    public PagedResponse<PurchaseRecordResponse> getPurchaseHistory(UUID userId, Pageable pageable) {
        Page<PurchaseRecord> records = purchaseRecordRepository
                .findByUserIdAndDeletedAtIsNullOrderByPurchasedAtDesc(userId, pageable);

        List<PurchaseRecordResponse> dtos = records.getContent().stream()
                .collect(Collectors.groupingBy(PurchaseRecord::getGroceryListId))
                .entrySet().stream()
                .map(entry -> {
                    List<PurchaseRecord> items = entry.getValue();
                    BigDecimal total = items.stream()
                            .map(PurchaseRecord::getTotalPrice)
                            .filter(java.util.Objects::nonNull)
                            .reduce(BigDecimal.ZERO, BigDecimal::add);
                    List<String> names = items.stream().map(PurchaseRecord::getItemName).toList();
                    return new PurchaseRecordResponse(
                            entry.getKey() != null ? entry.getKey() : UUID.randomUUID(),
                            names,
                            total,
                            items.getFirst().getPurchasedAt()
                    );
                })
                .toList();

        return PagedResponse.of(dtos, records.getNumber(), records.getSize(), records.getTotalElements());
    }

    /**
     * Supprime logiquement (soft-delete) une liste de courses et tous ses articles.
     *
     * @param userId l'identifiant de l'utilisateur (vérification de propriété)
     * @param listId l'identifiant de la liste à supprimer
     */
    public void deleteList(UUID userId, UUID listId) {
        GroceryList list = groceryListRepository.findById(listId)
                .orElseThrow(() -> new ResourceNotFoundException("GroceryList", "id", listId.toString()));

        securityUtils.verifyOwnership(list.getUserId(), userId, "GroceryList", listId.toString());

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
                list.getMealPlanId(),
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
                list.getMealPlanId(),
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
                item.getPriceConfidence(),
                item.getChecked(),
                item.getNotes(),
                item.getSortOrder(),
                item.getIngredientId()
        );
    }

    private String groceryKey(RecipeIngredient ingredient) {
        String unitFamily = unitFamily(ingredient.getUnit());
        if (ingredient.getIngredientId() != null) {
            return "ingredient:" + ingredient.getIngredientId() + ":" + unitFamily;
        }
        return "name:" + normalizeName(ingredient.getName()) + ":" + unitFamily;
    }

    private GroceryItemAggregate subtractPantry(GroceryItemAggregate item, List<PantryItem> pantryItems) {
        BigDecimal remaining = item.totalQuantity;
        for (PantryItem pantryItem : pantryItems) {
            if (!sameIngredient(pantryItem, item)) {
                continue;
            }
            BigDecimal pantryQuantity = convertQuantity(pantryItem.getQuantity(), pantryItem.getUnit(), item.unit);
            if (pantryQuantity == null) {
                continue;
            }
            remaining = remaining.subtract(pantryQuantity);
            if (remaining.compareTo(BigDecimal.ZERO) <= 0) {
                remaining = BigDecimal.ZERO;
                break;
            }
        }
        return new GroceryItemAggregate(item.name, remaining, item.unit, item.notes, item.ingredientId, item.count);
    }

    private boolean sameIngredient(PantryItem pantryItem, GroceryItemAggregate item) {
        if (pantryItem.getIngredientId() != null && item.ingredientId != null) {
            return pantryItem.getIngredientId().equals(item.ingredientId);
        }

        String pantryName = normalizeName(pantryItem.getName());
        String recipeName = normalizeName(item.name);
        return !pantryName.isBlank()
                && !recipeName.isBlank()
                && (pantryName.contains(recipeName) || recipeName.contains(pantryName));
    }

    private BigDecimal convertQuantity(BigDecimal quantity, String fromUnit, String toUnit) {
        String from = normalizeUnit(fromUnit);
        String to = normalizeUnit(toUnit);
        if (from.equals(to)) {
            return quantity;
        }
        if (!unitFamily(from).equals(unitFamily(to))) {
            return null;
        }
        BigDecimal base = toBaseUnit(quantity, from);
        return base == null ? null : fromBaseUnit(base, to);
    }

    private BigDecimal toBaseUnit(BigDecimal quantity, String unit) {
        return switch (unit) {
            case "g", "ml" -> quantity;
            case "kg", "l" -> quantity.multiply(BigDecimal.valueOf(1000));
            case "tsp" -> quantity.multiply(BigDecimal.valueOf(5));
            case "tbsp" -> quantity.multiply(BigDecimal.valueOf(15));
            case "cup" -> quantity.multiply(BigDecimal.valueOf(240));
            default -> null;
        };
    }

    private BigDecimal fromBaseUnit(BigDecimal quantity, String unit) {
        return switch (unit) {
            case "g", "ml" -> quantity;
            case "kg", "l" -> quantity.divide(BigDecimal.valueOf(1000), 3, java.math.RoundingMode.HALF_UP);
            case "tsp" -> quantity.divide(BigDecimal.valueOf(5), 3, java.math.RoundingMode.HALF_UP);
            case "tbsp" -> quantity.divide(BigDecimal.valueOf(15), 3, java.math.RoundingMode.HALF_UP);
            case "cup" -> quantity.divide(BigDecimal.valueOf(240), 3, java.math.RoundingMode.HALF_UP);
            default -> null;
        };
    }

    private String normalizeUnit(String value) {
        String unit = normalizeName(value);
        return switch (unit) {
            case "gram", "grams" -> "g";
            case "kilogram", "kilograms" -> "kg";
            case "milliliter", "milliliters" -> "ml";
            case "liter", "liters", "litre", "litres" -> "l";
            case "teaspoon", "teaspoons" -> "tsp";
            case "tablespoon", "tablespoons" -> "tbsp";
            case "cups" -> "cup";
            default -> unit;
        };
    }

    private String unitFamily(String value) {
        String unit = normalizeUnit(value);
        return switch (unit) {
            case "g", "kg" -> "mass";
            case "ml", "l", "tsp", "tbsp", "cup" -> "volume";
            default -> "unit:" + unit;
        };
    }

    private GroceryItemAggregate mergeGroceryItems(GroceryItemAggregate existing, GroceryItemAggregate incoming) {
        BigDecimal incomingQuantity = convertQuantity(incoming.totalQuantity, incoming.unit, existing.unit);
        if (incomingQuantity == null) {
            incomingQuantity = incoming.totalQuantity;
        }
        return new GroceryItemAggregate(
                existing.name,
                existing.totalQuantity.add(incomingQuantity),
                existing.unit,
                existing.notes != null ? existing.notes : incoming.notes,
                existing.ingredientId != null ? existing.ingredientId : incoming.ingredientId,
                existing.count + 1
        );
    }

    private String itemNotes(GroceryItemAggregate item) {
        if (item.ingredientId != null) {
            return item.notes;
        }
        String warning = "Canonical ingredient unresolved; price estimate unavailable";
        if (item.notes == null || item.notes.isBlank()) {
            return warning;
        }
        return item.notes + " | " + warning;
    }

    private BigDecimal estimateItemPrice(GroceryItemAggregate item, Map<UUID, BigDecimal> prices) {
        if (item.ingredientId == null) {
            return null;
        }
        BigDecimal price = prices.get(item.ingredientId);
        return price == null ? null : price.multiply(item.totalQuantity);
    }

    private String normalizeName(String value) {
        return value == null ? "" : value.trim().toLowerCase();
    }

    public record GroceryListResponse(
            UUID id,
            String name,
            String status,
            List<GroceryItemResponse> items,
            UUID mealPlanId,
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
            java.math.BigDecimal priceConfidence,
            Boolean checked,
            String notes,
            Integer sortOrder,
            UUID ingredientId
    ) {}

    public record CheckoutResponse(
            GroceryListResponse list,
            List<PantryAddition> pantryAdditions,
            PurchaseRecordResponse purchaseRecord,
            BigDecimal totalSpent
    ) {}

    public record PantryAddition(
            UUID id,
            String name,
            BigDecimal quantity,
            String unit
    ) {}

    public record PurchaseRecordResponse(
            UUID id,
            List<String> itemNames,
            BigDecimal totalPrice,
            Instant boughtDate
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
