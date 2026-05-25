package com.plateplate.deduplication;

import com.plateplate.common.util.StringNormalizer;
import com.plateplate.deduplication.domain.model.DuplicateDetection;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

@DisplayName("Deduplication Service Tests")
public class DeduplicationServiceTest {

    @Test
    @DisplayName("Should detect duplicates with high confidence")
    void testDetectDuplicateHighConfidence() {
        double similarity = calculateSimilarity("Olive Oil", "Olive Oil");
        assertTrue(similarity >= 0.95, "Should detect identical items");
    }

    @Test
    @DisplayName("Should detect duplicates with fuzzy matching")
    void testDetectDuplicateFuzzyMatch() {
        double similarity = calculateSimilarity("Tomatoes", "Tomato");
        assertTrue(similarity >= 0.75, "Should detect similar items");
    }

    @Test
    @DisplayName("Should not flag dissimilar items as duplicates")
    void testRejectDissimilarItems() {
        double similarity = calculateSimilarity("Olive Oil", "Coconut Oil");
        assertTrue(similarity < 0.75, "Should not flag as duplicates");
    }

    @Test
    @DisplayName("Should handle case-insensitive comparison")
    void testCaseInsensitiveComparison() {
        double similarity = calculateSimilarity("OLIVE OIL", "olive oil");
        assertEquals(1.0, similarity, "Should be identical after normalization");
    }

    @Test
    @DisplayName("Should track duplicate detection status")
    void testDuplicateDetectionStatus() {
        DuplicateDetection detection = new DuplicateDetection(
            "detect-001",
            "INGREDIENT",
            "ing-1",
            "ing-2",
            0.99
        );
        assertEquals(DuplicateDetection.Status.PENDING, detection.getStatus());
        detection.setStatus(DuplicateDetection.Status.AUTO_MERGED);
        assertEquals(DuplicateDetection.Status.AUTO_MERGED, detection.getStatus());
    }

    private double calculateSimilarity(String str1, String str2) {
        String norm1 = StringNormalizer.normalize(str1);
        String norm2 = StringNormalizer.normalize(str2);
        if (norm1.equals(norm2)) return 1.0;
        int distance = StringNormalizer.levenshtein(norm1, norm2);
        int maxLength = Math.max(norm1.length(), norm2.length());
        return 1.0 - (double) distance / maxLength;
    }
}
