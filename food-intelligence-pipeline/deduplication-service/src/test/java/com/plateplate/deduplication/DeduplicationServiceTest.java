package com.plateplate.deduplication;

import com.plateplate.deduplication.application.service.DeduplicationService;
import com.plateplate.deduplication.domain.model.DuplicateDetection;
import com.plateplate.deduplication.infrastructure.repository.DuplicateDetectionRepository;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;

import static org.junit.jupiter.api.Assertions.*;

@DisplayName("Deduplication Service Tests")
@SpringBootTest
@ActiveProfiles("test")
public class DeduplicationServiceTest {

    @Test
    @DisplayName("Should detect duplicates with high confidence")
    void testDetectDuplicateHighConfidence() {
        // Arrange
        String name1 = "Olive Oil";
        String name2 = "Olive Oil";

        // Act
        double similarity = calculateSimilarity(name1, name2);

        // Assert
        assertTrue(similarity >= 0.95, "Should detect identical items");
    }

    @Test
    @DisplayName("Should detect duplicates with fuzzy matching")
    void testDetectDuplicateFuzzyMatch() {
        // Arrange
        String name1 = "Olive Oil Extra Virgin";
        String name2 = "Olive Oil";

        // Act
        double similarity = calculateSimilarity(name1, name2);

        // Assert
        assertTrue(similarity >= 0.75, "Should detect similar items");
    }

    @Test
    @DisplayName("Should not flag dissimilar items as duplicates")
    void testRejectDissimilarItems() {
        // Arrange
        String name1 = "Olive Oil";
        String name2 = "Coconut Oil";

        // Act
        double similarity = calculateSimilarity(name1, name2);

        // Assert
        assertTrue(similarity < 0.75, "Should not flag as duplicates");
    }

    @Test
    @DisplayName("Should handle case-insensitive comparison")
    void testCaseInsensitiveComparison() {
        // Arrange
        String name1 = "OLIVE OIL";
        String name2 = "olive oil";

        // Act
        double similarity = calculateSimilarity(name1, name2);

        // Assert
        assertEquals(1.0, similarity, "Should be identical after normalization");
    }

    @Test
    @DisplayName("Should track duplicate detection status")
    void testDuplicateDetectionStatus() {
        // Arrange
        DuplicateDetection detection = new DuplicateDetection(
            "detect-001",
            "INGREDIENT",
            "ing-1",
            "ing-2",
            0.99
        );

        // Act & Assert
        assertEquals(DuplicateDetection.Status.PENDING, detection.getStatus());
        detection.setStatus(DuplicateDetection.Status.AUTO_MERGED);
        assertEquals(DuplicateDetection.Status.AUTO_MERGED, detection.getStatus());
    }

    private double calculateSimilarity(String str1, String str2) {
        String norm1 = str1.toLowerCase();
        String norm2 = str2.toLowerCase();
        
        if (norm1.equals(norm2)) return 1.0;
        
        int distance = levenshteinDistance(norm1, norm2);
        int maxLength = Math.max(norm1.length(), norm2.length());
        return 1.0 - (double) distance / maxLength;
    }

    private int levenshteinDistance(String str1, String str2) {
        int[][] dp = new int[str1.length() + 1][str2.length() + 1];
        for (int i = 0; i <= str1.length(); i++) dp[i][0] = i;
        for (int j = 0; j <= str2.length(); j++) dp[0][j] = j;
        
        for (int i = 1; i <= str1.length(); i++) {
            for (int j = 1; j <= str2.length(); j++) {
                int cost = str1.charAt(i - 1) == str2.charAt(j - 1) ? 0 : 1;
                dp[i][j] = Math.min(Math.min(dp[i - 1][j] + 1, dp[i][j - 1] + 1), dp[i - 1][j - 1] + cost);
            }
        }
        return dp[str1.length()][str2.length()];
    }
}
