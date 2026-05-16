package com.platepilote.platepilote.imports.application.service;

import org.springframework.stereotype.Service;

import java.text.Normalizer;
import java.util.Locale;

@Service
public class IngredientNormalizer {

    public String normalizeName(String name) {
        if (name == null) return null;
        String normalized = Normalizer.normalize(name, Normalizer.Form.NFD);
        normalized = normalized.replaceAll("[\\p{InCombiningDiacriticalMarks}]", "");
        normalized = normalized.replaceAll("[^a-zA-Z0-9\\s-]", "");
        normalized = normalized.trim().toLowerCase(Locale.ROOT);
        normalized = normalized.replaceAll("\\s+", " ");
        return normalized;
    }

    public String toSlug(String name) {
        if (name == null) return null;
        String slug = normalizeName(name);
        slug = slug.replaceAll("\\s+", "-");
        slug = slug.replaceAll("-+", "-");
        return slug;
    }
}
