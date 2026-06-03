package com.platepilote.platepilote.authentication.presentation;

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

/**
 * Contrôleur REST pour l'authentification.
 * <p>
 * Expose les endpoints publics (sans authentification) permettant
 * l'inscription, la connexion, le rafraîchissement des tokens, la vérification
 * d'email, la déconnexion et la réinitialisation du mot de passe.
 * </p>
 *
 * <p>URL de base : {@code /api/v1/auth}</p>
 */
@RestController
@RequestMapping("/api/v1/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;
    private final EmailVerificationService emailVerificationService;
    private final SecurityUtils securityUtils;

    /**
     * Inscrit un nouvel utilisateur.
     * <p>
     * Crée un compte, envoie un email de vérification et retourne les tokens JWT.
     * </p>
     *
     * @param request les données d'inscription
     * @return une réponse contenant les tokens JWT (statut 201)
     */
    @PostMapping("/register")
    public ResponseEntity<ApiResponse<AuthenticationResponse>> register(
            @Valid @RequestBody RegisterRequest request) {
        AuthenticationResponse response = authService.register(request);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success("Registration successful", response));
    }

    /**
     * Connecte un utilisateur existant.
     *
     * @param request les données de connexion
     * @return une réponse contenant les tokens JWT (statut 200)
     */
    @PostMapping("/login")
    public ResponseEntity<ApiResponse<AuthenticationResponse>> login(
            @Valid @RequestBody LoginRequest request) {
        AuthenticationResponse response = authService.login(request);
        return ResponseEntity.ok(ApiResponse.success("Login successful", response));
    }

    /**
     * Connecte un utilisateur via OAuth2.
     *
     * @param request les données de connexion OAuth2
     * @return une réponse contenant les tokens JWT (statut 200)
     */
    @PostMapping("/oauth2")
    public ResponseEntity<ApiResponse<AuthenticationResponse>> oauth2Login(
            @Valid @RequestBody OAuth2LoginRequest request) {
        AuthenticationResponse response = authService.oauth2Login(request);
        return ResponseEntity.ok(ApiResponse.success("OAuth2 login successful", response));
    }

    /**
     * Rafraîchit le token d'accès à partir d'un token de rafraîchissement valide.
     *
     * @param refreshToken le token de rafraîchissement
     * @return une réponse contenant les nouveaux tokens JWT (statut 200)
     */
    @PostMapping("/refresh")
    public ResponseEntity<ApiResponse<AuthenticationResponse>> refresh(
            @RequestParam String refreshToken) {
        AuthenticationResponse response = authService.refreshToken(refreshToken);
        return ResponseEntity.ok(ApiResponse.success("Token refreshed", response));
    }

    /**
     * Vérifie l'email d'un utilisateur à partir d'un token.
     *
     * @param token le token de vérification
     * @return une réponse de succès (statut 200)
     */
    @PostMapping("/verify-email")
    public ResponseEntity<ApiResponse<Void>> verifyEmail(@RequestParam String token) {
        emailVerificationService.verifyEmail(token);
        return ResponseEntity.ok(ApiResponse.success("Email verified", null));
    }

    /**
     * Renvoie l'email de vérification.
     *
     * @param request la requête contenant l'email
     * @return une réponse de succès (statut 200)
     */
    @PostMapping("/resend-verification")
    public ResponseEntity<ApiResponse<Void>> resendVerification(@Valid @RequestBody ResendVerificationRequest request) {
        emailVerificationService.resendVerificationEmail(request.email());
        return ResponseEntity.ok(ApiResponse.success("Verification email sent", null));
    }

    /**
     * Déconnecte l'utilisateur en révoquant le token de rafraîchissement donné.
     *
     * @param request la requête contenant le token de rafraîchissement
     * @return une réponse de succès (statut 200)
     */
    @PostMapping("/logout")
    public ResponseEntity<ApiResponse<Void>> logout(@Valid @RequestBody RefreshTokenRequest request) {
        authService.logout(request.refreshToken());
        return ResponseEntity.ok(ApiResponse.success("Logout successful", null));
    }

    /**
     * Déconnecte l'utilisateur de toutes ses sessions.
     *
     * @param userDetails les détails de l'utilisateur authentifié
     * @return une réponse de succès (statut 200)
     */
    @PostMapping("/logout-all")
    public ResponseEntity<ApiResponse<Void>> logoutAll(@AuthenticationPrincipal UserDetails userDetails) {
        authService.logoutAll(securityUtils.getCurrentUserId(userDetails));
        return ResponseEntity.ok(ApiResponse.success("All sessions revoked", null));
    }

    /**
     * Initie la réinitialisation du mot de passe.
     *
     * @param request la requête contenant l'email
     * @return une réponse de succès (statut 200)
     */
    @PostMapping("/forgot-password")
    public ResponseEntity<ApiResponse<Void>> forgotPassword(@Valid @RequestBody ForgotPasswordRequest request) {
        authService.forgotPassword(request.email());
        return ResponseEntity.ok(ApiResponse.success("If an account exists, a reset email has been sent", null));
    }

    /**
     * Réinitialise le mot de passe avec un token valide.
     *
     * @param request la requête contenant le token et le nouveau mot de passe
     * @return une réponse de succès (statut 200)
     */
    @PostMapping("/reset-password")
    public ResponseEntity<ApiResponse<Void>> resetPassword(@Valid @RequestBody ResetPasswordRequest request) {
        authService.resetPassword(request.token(), request.newPassword());
        return ResponseEntity.ok(ApiResponse.success("Password has been reset successfully", null));
    }

    /**
     * Requête de déconnexion contenant le token de rafraîchissement à révoquer.
     *
     * @param refreshToken le token de rafraîchissement
     */
    public record RefreshTokenRequest(String refreshToken) {}

    /**
     * Requête de renvoi d'email de vérification.
     *
     * @param email l'email de l'utilisateur
     */
    public record ResendVerificationRequest(String email) {}

    /**
     * Requête de réinitialisation de mot de passe.
     *
     * @param email l'email du compte
     */
    public record ForgotPasswordRequest(String email) {}

    /**
     * Requête de réinitialisation de mot de passe avec token.
     *
     * @param token       le token de réinitialisation
     * @param newPassword le nouveau mot de passe
     */
    public record ResetPasswordRequest(String token, String newPassword) {}
}
