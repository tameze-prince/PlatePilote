package com.platepilote.platepilote.authentication.application.dto;

/**
 * AUTHENTICATION RESPONSE - DATA RETURNED AFTER LOGIN/REGISTER
 * ==============================================================
 * 
 * WHAT IT IS:
 * The data structure returned to the Flutter app after successful login or registration.
 * 
 * EXAMPLE RESPONSE:
 * {
 *   "accessToken": "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJqb2huIn0.abc123",
 *   "refreshToken": "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJqb2huIn0.xyz789",
 *   "tokenType": "Bearer"
 * }
 * 
 * HOW FLUTTER APP USES THIS:
 * 1. Stores accessToken in secure storage
 * 2. Includes accessToken in every API request header: "Authorization: Bearer <token>"
 * 3. When accessToken expires (1 hour), uses refreshToken to get a new one
 * 4. Stores refreshToken for automatic re-authentication
 */

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AuthenticationResponse {

    private String accessToken;     // Short-lived token for API requests (1 hour)
    private String refreshToken;    // Long-lived token for getting new access tokens (7 days)
    private String tokenType = "Bearer";  // Always "Bearer" for JWT
}
