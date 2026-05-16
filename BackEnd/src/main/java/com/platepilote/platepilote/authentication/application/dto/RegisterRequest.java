package com.platepilote.platepilote.authentication.application.dto;

/**
 * REGISTER REQUEST - DATA SENT WHEN CREATING A NEW ACCOUNT
 * ==========================================================
 * 
 * WHAT IT IS:
 * The data structure that the Flutter app sends when a user registers.
 * 
 * EXAMPLE REQUEST BODY:
 * {
 *   "firstName": "John",
 *   "lastName": "Doe",
 *   "email": "john@email.com",
 *   "password": "SecurePass123!"
 * }
 * 
 * VALIDATION RULES:
 * - firstName: Required, cannot be empty
 * - lastName: Required, cannot be empty
 * - email: Required, must be a valid email format (contains @)
 * - password: Required, must be at least 8 characters
 * 
 * IF VALIDATION FAILS:
 * GlobalExceptionHandler catches the error and returns HTTP 400 with field-specific messages.
 */

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class RegisterRequest {

    @NotBlank(message = "First name is required")
    private String firstName;

    @NotBlank(message = "Last name is required")
    private String lastName;

    @NotBlank(message = "Email is required")
    @Email(message = "Email must be valid")
    private String email;

    @NotBlank(message = "Password is required")
    @Size(min = 8, message = "Password must be at least 8 characters")
    private String password;
}
