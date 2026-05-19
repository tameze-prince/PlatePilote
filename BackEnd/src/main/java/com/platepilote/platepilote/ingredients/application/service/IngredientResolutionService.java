package com.platepilote.platepilote.ingredients.application.service;

import com.platepilote.platepilote.ingredients.domain.entity.Ingredient;
import com.platepilote.platepilote.ingredients.domain.entity.IngredientAlias;
import com.platepilote.platepilote.ingredients.domain.repository.IngredientAliasRepository;
import com.platepilote.platepilote.ingredients.domain.repository.IngredientRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.text.Normalizer;
import java.util.Optional;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class IngredientResolutionService {

    private final IngredientRepository ingredientRepository;
    private final IngredientAliasRepository ingredientAliasRepository;

    @Transactional(readOnly = true)
    public Optional<Ingredient> resolveIngredient(String rawName) {
        String normalized = normalize(rawName);
        if (normalized.isBlank()) {
            return Optional.empty();
        }

        Optional<Ingredient> direct = ingredientRepository.findByCanonicalName(normalized);
        if (direct.isPresent()) {
            return direct;
        }

        Optional<IngredientAlias> alias = ingredientAliasRepository.findByNormalizedAlias(normalized)
                .stream()
                .findFirst();
        return alias.flatMap(a -> ingredientRepository.findById(a.getIngredientId()));
    }

    @Transactional(readOnly = true)
    public Optional<UUID> resolveIngredientId(String rawName) {
        return resolveIngredient(rawName).map(Ingredient::getId);
    }

    public String normalize(String value) {
        if (value == null) {
            return "";
        }
        String ascii = Normalizer.normalize(value, Normalizer.Form.NFD)
                .replaceAll("\\p{M}", "");
        return ascii.toLowerCase()
                .replaceAll("[^a-z0-9]+", " ")
                .trim()
                .replaceAll("\\s+", " ");
    }
}
