package com.platepilote.platepilote.imports.application.service;

import org.springframework.stereotype.Service;

import java.text.Normalizer;
import java.util.Locale;

/**
 * Service de normalisation des noms d'ingrédients.
 * <p>
 * Fournit des méthodes pour normaliser les noms (suppression des accents,
 * mise en minuscules, nettoyage) et pour générer des slugs uniques utilisés
 * comme identifiants URL-friendly pour la déduplication des ingrédients.
 */
@Service
public class IngredientNormalizer {

    /**
     * Normalise un nom d'ingrédient : supprime les accents, la ponctuation,
     * passe en minuscules et réduit les espaces multiples.
     *
     * @param name nom brut à normaliser
     * @return nom normalisé, ou null si l'entrée était null
     */
    public String normalizeName(String name) {
        if (name == null) return null;
        String normalized = Normalizer.normalize(name, Normalizer.Form.NFD);
        normalized = normalized.replaceAll("[\\p{InCombiningDiacriticalMarks}]", "");
        normalized = normalized.replaceAll("[^a-zA-Z0-9\\s-]", "");
        normalized = normalized.trim().toLowerCase(Locale.ROOT);
        normalized = normalized.replaceAll("\\s+", " ");
        return normalized;
    }

    /**
     * Génère un slug URL-friendly à partir d'un nom d'ingrédient.
     * <p>
     * Le slug est une version normalisée où les espaces sont remplacés par des tirets.
     *
     * @param name nom à convertir en slug
     * @return slug généré, ou null si l'entrée était null
     */
    public String toSlug(String name) {
        if (name == null) return null;
        String slug = normalizeName(name);
        slug = slug.replaceAll("\\s+", "-");
        slug = slug.replaceAll("-+", "-");
        return slug;
    }
}
