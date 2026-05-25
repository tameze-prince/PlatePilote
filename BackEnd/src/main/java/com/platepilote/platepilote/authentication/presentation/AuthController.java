package com.platepilote.platepilote.authentication.presentation;

/**
 * AUTH CONTROLLER - REST API ENDPOINTS FOR AUTHENTICATION
 * =========================================================
 * 
 * WHAT IT IS:
 * The REST controller that exposes authentication endpoints to the Flutter app.
 * 
 * ENDPOINTS:
 * 
 * 1. POST /api/v1/auth/register
 *    - Creates a new user account
 *    - Request body: RegisterRequest (firstName, lastName, email, password)
 *    - Response: AuthenticationResponse (accessToken, refreshToken)
 *    - HTTP Status: 201 Created
 * 
 * 2. POST /api/v1/auth/login
 *    - Authenticates an existing user
 *    - Request body: LoginRequest (email, password)
 *    - Response: AuthenticationResponse (accessToken, refreshToken)
 *    - HTTP Status: 200 OK
 * 
 * 3. POST /api/v1/auth/refresh?refreshToken=xxx
 *    - Generates a new access token from a valid refresh token
 *    - Query parameter: refreshToken
 *    - Response: AuthenticationResponse (new accessToken, same refreshToken)
 *    - HTTP Status: 200 OK
 * 
 * ALL THESE ENDPOINTS ARE PUBLIC (no authentication required).
 * See SecurityConfig.PUBLIC_ENDPOINTS for the list.
 */

import com.platepilote.platepilote.authentication.application.dto.AuthenticationResponse;
import com.platepilote.platepilote.authentication.application.dto.LoginRequest;
import com.platepilote.platepilote.authentication.application.dto.OAuth2LoginRequest;
import com.platepilote.platepilote.authentication.application.dto.RegisterRequest;
import com.platepilote.platepilote.authentication.application.service.AuthService;
import com.platepilote.platepilote.authentication.application.service.EmailVerificationService;
import com.platepilote.platepilote.common.dto.ApiResponse;
import com.platepilote.platepilote.common.security.SecurityUtils;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController  // Tells Spring: "This is a REST controller"
@RequestMapping("/api/v1/auth")  // Base URL for all endpoints in this controller
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;
    private final EmailVerificationService emailVerificationService;
    private final SecurityUtils securityUtils;

    /**
     * POST /api/v1/auth/register
     * Creates a new user account and returns JWT tokens.
     */
    @PostMapping("/register")
    public ResponseEntity<ApiResponse<AuthenticationResponse>> register(
            @Valid @RequestBody RegisterRequest request) {
        AuthenticationResponse response = authService.register(request);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success("Registration successful", response));
    }

    /**
     * POST /api/v1/auth/login
     * Authenticates user and returns JWT tokens.
     */
    @PostMapping("/login")
    public ResponseEntity<ApiResponse<AuthenticationResponse>> login(
            @Valid @RequestBody LoginRequest request) {
        AuthenticationResponse response = authService.login(request);
        return ResponseEntity.ok(ApiResponse.success("Login successful", response));
    }

    @PostMapping("/oauth2")
    public ResponseEntity<ApiResponse<AuthenticationResponse>> oauth2Login(
            @Valid @RequestBody OAuth2LoginRequest request) {
        AuthenticationResponse response = authService.oauth2Login(request);
        return ResponseEntity.ok(ApiResponse.success("OAuth2 login successful", response));
    }

    /**
     * POST /api/v1/auth/refresh?refreshToken=xxx
     * Generates new access token from refresh token.
     */
    @PostMapping("/refresh")
    public ResponseEntity<ApiResponse<AuthenticationResponse>> refresh(
            @RequestParam String refreshToken) {
        AuthenticationResponse response = authService.refreshToken(refreshToken);
        return ResponseEntity.ok(ApiResponse.success("Token refreshed", response));
    }

    @PostMapping("/verify-email")
    public ResponseEntity<ApiResponse<Void>> verifyEmail(@RequestParam String token) {
        emailVerificationService.verifyEmail(token);
        return ResponseEntity.ok(ApiResponse.success("Email verified", null));
    }

    @PostMapping("/resend-verification")
    public ResponseEntity<ApiResponse<Void>> resendVerification(@Valid @RequestBody ResendVerificationRequest request) {
        emailVerificationService.resendVerificationEmail(request.email());
        return ResponseEntity.ok(ApiResponse.success("Verification email sent", null));
    }

    @PostMapping("/logout")
    public ResponseEntity<ApiResponse<Void>> logout(@Valid @RequestBody RefreshTokenRequest request) {
        authService.logout(request.refreshToken());
        return ResponseEntity.ok(ApiResponse.success("Logout successful", null));
    }

    @PostMapping("/logout-all")
    public ResponseEntity<ApiResponse<Void>> logoutAll(@AuthenticationPrincipal UserDetails userDetails) {
        authService.logoutAll(securityUtils.getCurrentUserId(userDetails));
        return ResponseEntity.ok(ApiResponse.success("All sessions revoked", null));
    }

    @PostMapping("/forgot-password")
    public ResponseEntity<ApiResponse<Void>> forgotPassword(@Valid @RequestBody ForgotPasswordRequest request) {
        authService.forgotPassword(request.email());
        return ResponseEntity.ok(ApiResponse.success("If an account exists, a reset email has been sent", null));
    }

    @PostMapping("/reset-password")
    public ResponseEntity<ApiResponse<Void>> resetPassword(@Valid @RequestBody ResetPasswordRequest request) {
        authService.resetPassword(request.token(), request.newPassword());
        return ResponseEntity.ok(ApiResponse.success("Password has been reset successfully", null));
    }

    public record RefreshTokenRequest(String refreshToken) {}
    public record ResendVerificationRequest(String email) {}
    public record ForgotPasswordRequest(String email) {}
    public record ResetPasswordRequest(String token, String newPassword) {}
}
