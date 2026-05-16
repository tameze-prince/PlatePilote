package com.platepilote.platepilote.recommendation.presentation;

/**
 * RECOMMENDATION CONTROLLER - REST API ENDPOINTS FOR RECOMMENDATIONS
 * ====================================================================
 * 
 * WHAT IT IS:
 * Exposes the recommendation engine as a REST API endpoint.
 * 
 * ENDPOINT:
 * 
 * GET /api/v1/recommendations?limit=10
 * - Returns personalized recipe recommendations for the authenticated user
 * - Query parameter: limit (optional, default: 10)
 * - Response: List of Recipe objects sorted by relevance score
 * - Requires authentication (JWT token)
 * 
 * EXAMPLE REQUEST:
 * GET /api/v1/recommendations?limit=5
 * Authorization: Bearer <jwt-token>
 * 
 * EXAMPLE RESPONSE:
 * {
 *   "success": true,
 *   "data": [recipe1, recipe2, recipe3, recipe4, recipe5],
 *   "timestamp": "2024-01-15T10:30:00Z"
 * }
 */

import com.platepilote.platepilote.common.dto.ApiResponse;
import com.platepilote.platepilote.recipes.domain.entity.Recipe;
import com.platepilote.platepilote.recommendation.domain.service.RecommendationEngine;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/recommendations")
@RequiredArgsConstructor
public class RecommendationController {

    private final RecommendationEngine recommendationEngine;

    /**
     * GET /api/v1/recommendations?limit=10
     * Returns personalized recipe recommendations for the logged-in user.
     * 
     * The user is identified from the JWT token (automatically extracted by Spring Security).
     */
    @GetMapping
    public ResponseEntity<ApiResponse<List<Recipe>>> getRecommendations(
            @AuthenticationPrincipal UserDetails userDetails,
            @RequestParam(defaultValue = "10") int limit) {

        // Extract user ID from the authenticated user's username (email)
        // NOTE: In production, you'd store userId in the JWT claims or look it up by email
        UUID userId = UUID.fromString(userDetails.getUsername());
        
        List<Recipe> recommendations = recommendationEngine.getRecommendations(userId, limit);
        return ResponseEntity.ok(ApiResponse.success(recommendations));
    }
}
