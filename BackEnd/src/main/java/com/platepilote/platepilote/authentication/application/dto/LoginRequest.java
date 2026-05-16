package com.platepilote.platepilote.authentication.application.dto;

/**
 * LOGIN REQUEST - DATA SENT WHEN LOGGING IN
 * ============================================
 * 
 * WHAT IT IS:
 * The data structure that the Flutter app sends when a user logs in.
 * 
 * EXAMPLE REQUEST BODY:
 * {
 *   "email": "john@email.com",
 *   "password": "SecurePass123!"
 * }
 * 
 * VALIDATION RULES:
 * - email: Required, must be valid email format
 * - password: Required
 */

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class LoginRequest {

    @NotBlank(message = "Email is required")
    @Email(message = "Email must be valid")
    private String email;

    @NotBlank(message = "Password is required")
    private String password;
}
