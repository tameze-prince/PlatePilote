package com.platepilote.platepilote.ingredients.application.service;

import com.platepilote.platepilote.common.dto.PagedResponse;
import com.platepilote.platepilote.common.kernel.ResourceNotFoundException;
import com.platepilote.platepilote.ingredients.application.dto.IngredientResponse;
import com.platepilote.platepilote.ingredients.domain.entity.Ingredient;
import com.platepilote.platepilote.ingredients.domain.repository.IngredientRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional
public class IngredientService {

    private final IngredientRepository ingredientRepository;

    @Transactional(readOnly = true)
    @Cacheable(value = "ingredients", key = "'search:' + #query + ':' + #pageable.pageNumber + ':' + #pageable.pageSize")
    public PagedResponse<IngredientResponse> searchIngredients(String query, Pageable pageable) {
        Page<Ingredient> page = ingredientRepository.search(query, pageable);
        return toPagedResponse(page);
    }

    @Transactional(readOnly = true)
    @Cacheable(value = "ingredients", key = "'category:' + #category")
    public PagedResponse<IngredientResponse> getByCategory(String category, Pageable pageable) {
        Page<Ingredient> page = ingredientRepository.findByCategoryAndDeletedAtIsNull(category, pageable);
        return toPagedResponse(page);
    }

    @Transactional(readOnly = true)
    @Cacheable(value = "ingredient", key = "#slug")
    public IngredientResponse getBySlug(String slug) {
        Ingredient ingredient = ingredientRepository.findBySlug(slug)
                .orElseThrow(() -> new ResourceNotFoundException("Ingredient", "slug", slug));
        return toResponse(ingredient);
    }

    @Transactional(readOnly = true)
    @Cacheable(value = "ingredient", key = "#id")
    public IngredientResponse getById(UUID id) {
        Ingredient ingredient = ingredientRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Ingredient", "id", id.toString()));
        return toResponse(ingredient);
    }

    @Transactional(readOnly = true)
    public List<IngredientResponse> findAllById(List<UUID> ids) {
        return ingredientRepository.findAllById(ids).stream()
                .map(this::toResponse)
                .collect(Collectors.toList());
    }

    @CacheEvict(value = {"ingredients", "ingredient"}, allEntries = true)
    public IngredientResponse create(Ingredient ingredient) {
        Ingredient saved = ingredientRepository.save(ingredient);
        return toResponse(saved);
    }

    @CacheEvict(value = {"ingredients", "ingredient"}, allEntries = true)
    public void delete(UUID id) {
        Ingredient ingredient = ingredientRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Ingredient", "id", id.toString()));
        ingredient.softDelete();
        ingredientRepository.save(ingredient);
    }

    private PagedResponse<IngredientResponse> toPagedResponse(Page<Ingredient> page) {
        List<IngredientResponse> content = page.getContent().stream()
                .map(this::toResponse).collect(Collectors.toList());
        return PagedResponse.of(content, page.getNumber(), page.getSize(), page.getTotalElements());
    }

    private IngredientResponse toResponse(Ingredient ing) {
        return IngredientResponse.builder()
                .id(ing.getId())
                .canonicalName(ing.getCanonicalName())
                .slug(ing.getSlug())
                .category(ing.getCategory())
                .description(ing.getDescription())
                .defaultUnit(ing.getDefaultUnit())
                .caloriesPer100g(ing.getCaloriesPer100g())
                .proteinPer100g(ing.getProteinPer100g())
                .carbohydratesPer100g(ing.getCarbohydratesPer100g())
                .fatPer100g(ing.getFatPer100g())
                .fiberPer100g(ing.getFiberPer100g())
                .sugarPer100g(ing.getSugarPer100g())
                .sodiumMgPer100g(ing.getSodiumMgPer100g())
                .cholesterolMgPer100g(ing.getCholesterolMgPer100g())
                .containsGluten(ing.getContainsGluten())
                .containsLactose(ing.getContainsLactose())
                .containsNuts(ing.getContainsNuts())
                .containsSoy(ing.getContainsSoy())
                .containsEggs(ing.getContainsEggs())
                .containsFish(ing.getContainsFish())
                .containsShellfish(ing.getContainsShellfish())
                .vegan(ing.getVegan())
                .vegetarian(ing.getVegetarian())
                .halalFriendly(ing.getHalalFriendly())
                .kosherFriendly(ing.getKosherFriendly())
                .lowCarb(ing.getLowCarb())
                .ketoFriendly(ing.getKetoFriendly())
                .averagePricePerKg(ing.getAveragePricePerKg())
                .usdaFdcId(ing.getUsdaFdcId())
                .openFoodFactsCode(ing.getOpenFoodFactsCode())
                .sourceName(ing.getSourceName())
                .sourceUrl(ing.getSourceUrl())
                .createdAt(ing.getCreatedAt())
                .updatedAt(ing.getUpdatedAt())
                .build();
    }
}
