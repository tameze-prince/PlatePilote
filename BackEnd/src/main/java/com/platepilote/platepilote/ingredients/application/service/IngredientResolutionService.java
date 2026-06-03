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

/**
 * Service de résolution d'ingrédients à partir de textes bruts.
 * <p>
 * Normalise le texte saisi (suppression des accents, mise en minuscules, etc.)
 * et tente de trouver l'ingrédient correspondant, d'abord par nom canonique,
 * puis par alias.
 * </p>
 */
@Service
@RequiredArgsConstructor
public class IngredientResolutionService {

    private final IngredientRepository ingredientRepository;
    private final IngredientAliasRepository ingredientAliasRepository;

    /**
     * Résout un nom d'ingrédient brut en une entité {@link Ingredient}.
     * <p>
     * La recherche s'effectue d'abord par nom canonique normalisé,
     * puis par alias normalisé si aucun résultat direct n'est trouvé.
     * </p>
     *
     * @param rawName nom brut de l'ingrédient (ex : "Épinards frais")
     * @return un {@code Optional} contenant l'ingrédient trouvé, ou vide
     */
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

    /**
     * Résout un nom d'ingrédient brut en un identifiant ({@link UUID}).
     *
     * @param rawName nom brut de l'ingrédient
     * @return un {@code Optional} contenant l'identifiant de l'ingrédient, ou vide
     */
    @Transactional(readOnly = true)
    public Optional<UUID> resolveIngredientId(String rawName) {
        return resolveIngredient(rawName).map(Ingredient::getId);
    }

    /**
     * Normalise une chaîne de caractères pour la recherche.
     * <p>
     * Supprime les accents, met en minuscules, remplace les caractères
     * non alphanumériques par des espaces, et réduit les espaces multiples.
     * </p>
     *
     * @param value chaîne à normaliser
     * @return chaîne normalisée, ou chaîne vide si {@code null}
     */
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
