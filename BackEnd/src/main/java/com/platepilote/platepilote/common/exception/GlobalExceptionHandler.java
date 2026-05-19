package com.platepilote.platepilote.common.exception;

/**
 * GLOBAL EXCEPTION HANDLER - CATCHES ALL ERRORS AND CONVERTS TO HTTP RESPONSES
 * =============================================================================
 * 
 * WHAT IT IS:
 * A centralized error handler that catches all exceptions thrown by controllers
 * and converts them into proper HTTP responses with JSON error messages.
 * 
 * WHY IT EXISTS:
 * Without this, exceptions would return generic HTML error pages.
 * This ensures all errors return consistent JSON format that the Flutter app can parse.
 * 
 * EXCEPTION MAPPING:
 * - ResourceNotFoundException -> HTTP 404 Not Found
 * - BusinessRuleViolationException -> HTTP 422 Unprocessable Entity
 * - DomainException -> HTTP 400 Bad Request
 * - Validation errors -> HTTP 400 with field-specific error messages
 * - BadCredentialsException -> HTTP 401 Unauthorized
 * - AccessDeniedException -> HTTP 403 Forbidden
 * - Any other exception -> HTTP 500 Internal Server Error
 * 
 * EXAMPLE RESPONSE:
 * {
 *   "status": 404,
 *   "message": "Recipe not found with id: '123'",
 *   "timestamp": "2024-01-15T10:30:00Z"
 * }
 */

import com.platepilote.platepilote.common.kernel.BusinessRuleViolationException;
import com.platepilote.platepilote.common.kernel.DomainException;
import com.platepilote.platepilote.common.kernel.ResourceNotFoundException;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.core.env.Environment;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.time.Instant;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;

@RestControllerAdvice  // Tells Spring: "This class handles exceptions for all controllers"
@RequiredArgsConstructor
public class GlobalExceptionHandler {

    private final Environment environment;

    /**
     * Handle "resource not found" errors -> HTTP 404
     * Example: User requests a recipe that doesn't exist
     */
    @ExceptionHandler(ResourceNotFoundException.class)
    public ResponseEntity<ErrorResponse> handleResourceNotFound(ResourceNotFoundException ex) {
        ErrorResponse error = new ErrorResponse(
                HttpStatus.NOT_FOUND.value(),
                ex.getMessage(),
                Instant.now()
        );
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(error);
    }

    /**
     * Handle business rule violations -> HTTP 422
     * Example: Trying to register with an email that already exists
     */
    @ExceptionHandler(BusinessRuleViolationException.class)
    public ResponseEntity<ErrorResponse> handleBusinessRuleViolation(BusinessRuleViolationException ex) {
        ErrorResponse error = new ErrorResponse(
                HttpStatus.UNPROCESSABLE_ENTITY.value(),
                ex.getMessage(),
                Instant.now()
        );
        return ResponseEntity.status(HttpStatus.UNPROCESSABLE_ENTITY).body(error);
    }

    /**
     * Handle general domain exceptions -> HTTP 400
     * Example: Invalid input data, validation failures at domain level
     */
    @ExceptionHandler(DomainException.class)
    public ResponseEntity<ErrorResponse> handleDomainException(DomainException ex) {
        ErrorResponse error = new ErrorResponse(
                HttpStatus.BAD_REQUEST.value(),
                ex.getMessage(),
                Instant.now()
        );
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(error);
    }

    /**
     * Handle validation errors (e.g., @NotBlank, @Email) -> HTTP 400
     * Returns field-specific error messages so the app can show them to the user.
     * 
     * EXAMPLE RESPONSE:
     * {
     *   "status": 400,
     *   "message": "Validation failed",
     *   "errors": {
     *     "email": "Email must be valid",
     *     "password": "Password must be at least 8 characters"
     *   }
     * }
     */
    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ValidationErrorResponse> handleValidationExceptions(MethodArgumentNotValidException ex) {
        Map<String, String> errors = new HashMap<>();
        ex.getBindingResult().getAllErrors().forEach(error -> {
            String fieldName = ((FieldError) error).getField();
            String errorMessage = error.getDefaultMessage();
            errors.put(fieldName, errorMessage);
        });
        ValidationErrorResponse response = new ValidationErrorResponse(
                HttpStatus.BAD_REQUEST.value(),
                "Validation failed",
                Instant.now(),
                errors
        );
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(response);
    }

    /**
     * Handle login failures -> HTTP 401
     * Example: Wrong email or password
     */
    @ExceptionHandler(BadCredentialsException.class)
    public ResponseEntity<ErrorResponse> handleBadCredentials(BadCredentialsException ex) {
        ErrorResponse error = new ErrorResponse(
                HttpStatus.UNAUTHORIZED.value(),
                "Invalid credentials",
                Instant.now()
        );
        return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(error);
    }

    /**
     * Handle access denied errors -> HTTP 403
     * Example: Regular user trying to access admin endpoint
     */
    @ExceptionHandler(AccessDeniedException.class)
    public ResponseEntity<ErrorResponse> handleAccessDenied(AccessDeniedException ex) {
        ErrorResponse error = new ErrorResponse(
                HttpStatus.FORBIDDEN.value(),
                "Access denied",
                Instant.now()
        );
        return ResponseEntity.status(HttpStatus.FORBIDDEN).body(error);
    }

    /**
     * Handle any unexpected errors -> HTTP 500
     * This is a catch-all for errors we didn't specifically handle.
     */
    @ExceptionHandler(Exception.class)
    public ResponseEntity<ErrorResponse> handleGenericException(Exception ex) {
        ex.printStackTrace();
        boolean production = Arrays.asList(environment.getActiveProfiles()).contains("prod");
        ErrorResponse error = new ErrorResponse(
                HttpStatus.INTERNAL_SERVER_ERROR.value(),
                production
                        ? "An unexpected error occurred"
                        : "An unexpected error occurred: " + ex.getClass().getSimpleName() + " - " + ex.getMessage(),
                Instant.now()
        );
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error);
    }

    /**
     * Standard error response format returned for all errors.
     */
    @Getter
    @AllArgsConstructor
    public static class ErrorResponse {
        private final int status;       // HTTP status code (404, 500, etc.)
        private final String message;   // Human-readable error message
        private final Instant timestamp; // When the error occurred
    }

    /**
     * Extended error response for validation errors with field-specific messages.
     */
    @Getter
    public static class ValidationErrorResponse extends ErrorResponse {
        private final Map<String, String> errors;  // Field name -> error message

        public ValidationErrorResponse(int status, String message, Instant timestamp, Map<String, String> errors) {
            super(status, message, timestamp);
            this.errors = errors;
        }
    }
}
