package com.platepilote.platepilote.common.kernel;

/**
 * BUSINESS RULE VIOLATION EXCEPTION - HTTP 422 ERROR
 * ====================================================
 * 
 * WHAT IT IS:
 * Thrown when a business rule is violated (not a technical error, but a logic violation).
 * 
 * EXAMPLES:
 * - Trying to register with an email that already exists
 * - Trying to subtract more pantry items than available
 * - Trying to create a meal plan in the past
 * 
 * This gets caught by GlobalExceptionHandler and converted to HTTP 422 response.
 */

public class BusinessRuleViolationException extends DomainException {
    public BusinessRuleViolationException(String message) {
        super(message);
    }
}
