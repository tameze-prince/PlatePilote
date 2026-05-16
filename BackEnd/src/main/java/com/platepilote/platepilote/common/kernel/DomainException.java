package com.platepilote.platepilote.common.kernel;

/**
 * DOMAIN EXCEPTION - BASE CLASS FOR ALL BUSINESS ERRORS
 * ======================================================
 * 
 * WHAT IT IS:
 * Parent class for all custom exceptions in this application.
 * All business rule violations extend from this class.
 * 
 * WHY IT EXISTS:
 * Instead of throwing generic RuntimeException, we throw specific exceptions
 * that the GlobalExceptionHandler can catch and convert to proper HTTP responses.
 * 
 * EXAMPLE:
 * - BusinessRuleViolationException -> HTTP 422 Unprocessable Entity
 * - ResourceNotFoundException -> HTTP 404 Not Found
 */

public abstract class DomainException extends RuntimeException {

    protected DomainException(String message) {
        super(message);
    }

    protected DomainException(String message, Throwable cause) {
        super(message, cause);
    }
}
