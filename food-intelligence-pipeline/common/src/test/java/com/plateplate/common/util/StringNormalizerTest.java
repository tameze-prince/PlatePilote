package com.plateplate.common.util;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

@DisplayName("String Normalizer Tests")
public class StringNormalizerTest {

    @Test
    @DisplayName("Should normalize to lowercase")
    void testNormalizeLowercase() {
        assertEquals("hello", StringNormalizer.normalize("HELLO"));
        assertEquals("world", StringNormalizer.normalize("WoRLd"));
    }

    @Test
    @DisplayName("Should remove accents")
    void testRemoveAccents() {
        assertEquals("cafe", StringNormalizer.normalize("café"));
        assertEquals("naive", StringNormalizer.normalize("naïve"));
        assertEquals("creme", StringNormalizer.normalize("crème"));
    }

    @Test
    @DisplayName("Should trim whitespace")
    void testTrimWhitespace() {
        assertEquals("test", StringNormalizer.normalize("  test  "));
        assertEquals("hello world", StringNormalizer.normalize("  hello world  "));
    }

    @Test
    @DisplayName("Should generate correct slug")
    void testSlugGeneration() {
        assertEquals("bell-pepper", StringNormalizer.toSlug("Bell Pepper"));
        assertEquals("olive-oil", StringNormalizer.toSlug("Olive Oil"));
        assertEquals("extra-virgin-olive-oil", StringNormalizer.toSlug("Extra Virgin Olive Oil"));
    }

    @Test
    @DisplayName("Should remove special characters in slug")
    void testSlugRemoveSpecialChars() {
        assertEquals("salt-pepper", StringNormalizer.toSlug("Salt & Pepper"));
        assertEquals("100-organic-beef", StringNormalizer.toSlug("100% Organic Beef"));
    }

    @Test
    @DisplayName("Should handle empty strings")
    void testEmptyString() {
        assertEquals("", StringNormalizer.normalize(""));
        assertEquals("", StringNormalizer.toSlug(""));
    }

    @Test
    @DisplayName("Should detect similar strings")
    void testSimilarityDetection() {
        assertTrue(StringNormalizer.isSimilar("tomato", "tomato", 0.9));
        assertTrue(StringNormalizer.isSimilar("olive", "olives", 0.8));
    }
}
