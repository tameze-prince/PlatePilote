package com.platepilote.platepilote.common.dto;

/**
 * API RESPONSE - STANDARD WRAPPER FOR ALL API RESPONSES
 * ======================================================
 * 
 * WHAT IT IS:
 * A standard wrapper that all API endpoints use to return data.
 * 
 * WHY IT EXISTS:
 * Ensures all API responses have the same format, making it easier for the
 * Flutter app to parse and handle responses consistently.
 * 
 * SUCCESS RESPONSE FORMAT:
 * {
 *   "success": true,
 *   "message": "Recipe created successfully",
 *   "data": { ... recipe object ... },
 *   "timestamp": "2024-01-15T10:30:00Z"
 * }
 * 
 * ERROR RESPONSE FORMAT:
 * {
 *   "success": false,
 *   "message": "Recipe not found",
 *   "timestamp": "2024-01-15T10:30:00Z"
 * }
 */

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.Instant;

@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
@JsonInclude(JsonInclude.Include.NON_NULL)  // Don't include null fields in JSON
public class ApiResponse<T> {

    private boolean success;    // true = operation succeeded, false = failed
    private String message;     // Human-readable message for the user
    private T data;             // The actual response data (generic type)
    private Instant timestamp;  // When the response was generated

    /**
     * Create a success response with data.
     * Example: return ApiResponse.success(recipe);
     */
    public static <T> ApiResponse<T> success(T data) {
        return ApiResponse.<T>builder()
                .success(true)
                .data(data)
                .timestamp(Instant.now())
                .build();
    }

    /**
     * Create a success response with a custom message and data.
     * Example: return ApiResponse.success("Recipe created", recipe);
     */
    public static <T> ApiResponse<T> success(String message, T data) {
        return ApiResponse.<T>builder()
                .success(true)
                .message(message)
                .data(data)
                .timestamp(Instant.now())
                .build();
    }

    /**
     * Create an error response.
     * Example: return ApiResponse.error("Recipe not found");
     */
    public static <T> ApiResponse<T> error(String message) {
        return ApiResponse.<T>builder()
                .success(false)
                .message(message)
                .timestamp(Instant.now())
                .build();
    }
}
