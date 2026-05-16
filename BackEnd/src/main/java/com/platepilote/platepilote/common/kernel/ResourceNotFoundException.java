package com.platepilote.platepilote.common.kernel;

/**
 * RESOURCE NOT FOUND EXCEPTION - HTTP 404 ERROR
 * ===============================================
 * 
 * WHAT IT IS:
 * Thrown when a requested resource (user, recipe, pantry item, etc.) doesn't exist.
 * 
 * EXAMPLE USAGE:
 * throw new ResourceNotFoundException("User", "email", "john@email.com");
 * -> Returns: "User not found with email: 'john@email.com'"
 * 
 * This gets caught by GlobalExceptionHandler and converted to HTTP 404 response.
 */

public class ResourceNotFoundException extends DomainException {
    
    /**
     * Creates a formatted error message like "User not found with email: 'john@email.com'"
     */
    public ResourceNotFoundException(String resourceName, String fieldName, Object fieldValue) {
        super(String.format("%s not found with %s: '%s'", resourceName, fieldName, fieldValue));
    }

    public ResourceNotFoundException(String message) {
        super(message);
    }
}
