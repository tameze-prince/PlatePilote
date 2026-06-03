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

/**
 * Service métier pour la gestion des ingrédients.
 * <p>
 * Fournit les opérations de recherche, de consultation et de gestion
 * du cycle de vie des ingrédients, avec mise en cache des résultats.
 * </p>
 */
@Service
@RequiredArgsConstructor
@Transactional
public class IngredientService {

    private final IngredientRepository ingredientRepository;

    /**
     * Recherche des ingrédients par mot-clé avec pagination.
     * <p>
     * La recherche s'effectue sur le nom canonique et la catégorie.
     * Le résultat est mis en cache.
     * </p>
     *
     * @param query    terme de recherche
     * @param pageable paramètres de pagination et de tri
     * @return réponse paginée des ingrédients trouvés
     */
    @Transactional(readOnly = true)
    @Cacheable(value = "ingredients", key = "'search:' + #query + ':' + #pageable.pageNumber + ':' + #pageable.pageSize")
    public PagedResponse<IngredientResponse> searchIngredients(String query, Pageable pageable) {
        Page<Ingredient> page = ingredientRepository.search(query, pageable);
        return toPagedResponse(page);
    }

    /**
     * Récupère les ingrédients d'une catégorie donnée avec pagination.
     * <p>
     * Le résultat est mis en cache.
     * </p>
     *
     * @param category catégorie d'ingrédients
     * @param pageable paramètres de pagination
     * @return réponse paginée des ingrédients de la catégorie
     */
    @Transactional(readOnly = true)
    @Cacheable(value = "ingredients", key = "'category:' + #category")
    public PagedResponse<IngredientResponse> getByCategory(String category, Pageable pageable) {
        Page<Ingredient> page = ingredientRepository.findByCategoryAndDeletedAtIsNull(category, pageable);
        return toPagedResponse(page);
    }

    /**
     * Récupère un ingrédient par son slug.
     * <p>
     * Le résultat est mis en cache.
     * </p>
     *
     * @param slug slug unique de l'ingrédient
     * @return réponse détaillée de l'ingrédient
     * @throws ResourceNotFoundException si l'ingrédient n'existe pas
     */
    @Transactional(readOnly = true)
    @Cacheable(value = "ingredient", key = "#slug")
    public IngredientResponse getBySlug(String slug) {
        Ingredient ingredient = ingredientRepository.findBySlug(slug)
                .orElseThrow(() -> new ResourceNotFoundException("Ingredient", "slug", slug));
        return toResponse(ingredient);
    }

    /**
     * Récupère un ingrédient par son identifiant.
     * <p>
     * Le résultat est mis en cache.
     * </p>
     *
     * @param id identifiant de l'ingrédient
     * @return réponse détaillée de l'ingrédient
     * @throws ResourceNotFoundException si l'ingrédient n'existe pas
     */
    @Transactional(readOnly = true)
    @Cacheable(value = "ingredient", key = "#id")
    public IngredientResponse getById(UUID id) {
        Ingredient ingredient = ingredientRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Ingredient", "id", id.toString()));
        return toResponse(ingredient);
    }

    /**
     * Récupère plusieurs ingrédients par leurs identifiants.
     * <p>
     * Le résultat est mis en cache.
     * </p>
     *
     * @param ids liste des identifiants
     * @return liste des réponses des ingrédients trouvés
     */
    @Transactional(readOnly = true)
    @Cacheable(value = "ingredients_batch", key = "#ids")
    public List<IngredientResponse> findAllById(List<UUID> ids) {
        return ingredientRepository.findAllById(ids).stream()
                .map(this::toResponse)
                .collect(Collectors.toList());
    }

    /**
     * Crée un nouvel ingrédient.
     * <p>
     * Invalide les caches associés.
     * </p>
     *
     * @param ingredient entité ingrédient à créer
     * @return réponse détaillée de l'ingrédient créé
     */
    @CacheEvict(value = {"ingredients", "ingredient"}, allEntries = true)
    public IngredientResponse create(Ingredient ingredient) {
        Ingredient saved = ingredientRepository.save(ingredient);
        return toResponse(saved);
    }

    /**
     * Supprime (soft-delete) un ingrédient par son identifiant.
     * <p>
     * Invalide les caches associés.
     * </p>
     *
     * @param id identifiant de l'ingrédient à supprimer
     * @throws ResourceNotFoundException si l'ingrédient n'existe pas
     */
    @CacheEvict(value = {"ingredients", "ingredient"}, allEntries = true)
    public void delete(UUID id) {
        Ingredient ingredient = ingredientRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Ingredient", "id", id.toString()));
        ingredient.softDelete();
        ingredientRepository.save(ingredient);
    }

    /**
     * Convertit une page d'entités en réponse paginée.
     *
     * @param page page d'entités Ingredient
     * @return réponse paginée d'IngredientResponse
     */
    private PagedResponse<IngredientResponse> toPagedResponse(Page<Ingredient> page) {
        List<IngredientResponse> content = page.getContent().stream()
                .map(this::toResponse).collect(Collectors.toList());
        return PagedResponse.of(content, page.getNumber(), page.getSize(), page.getTotalElements());
    }

    /**
     * Convertit une entité Ingredient en réponse détaillée.
     *
     * @param ing entité source
     * @return réponse détaillée
     */
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
