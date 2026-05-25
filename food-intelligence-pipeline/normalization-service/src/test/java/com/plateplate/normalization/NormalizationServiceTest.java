package com.plateplate.normalization;

import com.plateplate.common.util.StringNormalizer;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

@DisplayName("Normalization Service Tests")
public class NormalizationServiceTest {

    @Test
    @DisplayName("Should normalize ingredient name to lowercase and remove accents")
    void testNormalizeIngredientName() {
        String input = "Tomate Réchauffé";
        String result = StringNormalizer.normalize(input);
        assertEquals("tomate rechauffe", result);
    }

    @Test
    @DisplayName("Should generate correct slug from ingredient name")
    void testGenerateSlug() {
        String input = "Bell Pepper";
        String slug = StringNormalizer.toSlug(input);
        assertEquals("bell-pepper", slug);
    }

    @Test
    @DisplayName("Should handle accented characters in slug")
    void testSlugWithAccents() {
        String input = "Crème Fraîche";
        String slug = StringNormalizer.toSlug(input);
        assertEquals("creme-fraiche", slug);
    }

    @Test
    @DisplayName("Should detect similar strings")
    void testStringSimilarity() {
        String str1 = "tomato";
        String str2 = "tomat";
        boolean similar = StringNormalizer.isSimilar(str1, str2, 0.8);
        assertTrue(similar);
    }

    @Test
    @DisplayName("Should reject dissimilar strings")
    void testStringSimilarityReject() {
        String str1 = "apple";
        String str2 = "banana";
        boolean similar = StringNormalizer.isSimilar(str1, str2, 0.8);
        assertFalse(similar);
    }

    @Test
    @DisplayName("Should handle multilingual ingredients")
    void testMultilingualNormalization() {
        String[] ingredients = {
            "Aubergine",
            "Berenjena",
            "Aubergine",
            "Eggplant"
        };
        for (String ingredient : ingredients) {
            String normalized = StringNormalizer.normalize(ingredient);
            assertNotNull(normalized);
            assertEquals(normalized, normalized.toLowerCase());
        }
    }
}
