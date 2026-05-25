package com.plateplate.normalization.application.service;

import com.plateplate.common.util.StringNormalizer;
import com.plateplate.normalization.domain.model.Ingredient;
import com.plateplate.normalization.infrastructure.repository.IngredientRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Optional;
import java.util.UUID;

@Service
public class NormalizationService {

    private final IngredientRepository ingredientRepository;

    public NormalizationService(IngredientRepository ingredientRepository) {
        this.ingredientRepository = ingredientRepository;
    }

    public String normalizeName(String rawName) {
        return StringNormalizer.normalize(rawName);
    }

    public String generateSlug(String name) {
        return StringNormalizer.toSlug(name);
    }

    @Transactional
    public Ingredient normalizeIngredient(String rawName, String category) {
        String normalized = normalizeName(rawName);
        String slug = generateSlug(rawName);

        Optional<Ingredient> existing = ingredientRepository.findBySlug(slug);
        if (existing.isPresent()) {
            return existing.get();
        }

        Ingredient ingredient = new Ingredient();
        ingredient.setId(UUID.randomUUID().toString());
        ingredient.setCanonicalName(normalized);
        ingredient.setSlug(slug);
        ingredient.setCategory(category);
        return ingredientRepository.save(ingredient);
    }
}
