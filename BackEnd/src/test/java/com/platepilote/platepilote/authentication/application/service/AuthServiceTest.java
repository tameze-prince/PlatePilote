package com.platepilote.platepilote.authentication.application.service;

import com.platepilote.platepilote.authentication.application.dto.AuthenticationResponse;
import com.platepilote.platepilote.authentication.application.dto.LoginRequest;
import com.platepilote.platepilote.authentication.application.dto.RegisterRequest;
import com.platepilote.platepilote.authentication.domain.entity.OurUser;
import com.platepilote.platepilote.authentication.domain.entity.RefreshToken;
import com.platepilote.platepilote.authentication.domain.entity.Role;
import com.platepilote.platepilote.authentication.domain.repository.RefreshTokenRepository;
import com.platepilote.platepilote.authentication.domain.repository.RoleRepository;
import com.platepilote.platepilote.authentication.domain.repository.UserRepository;
import com.platepilote.platepilote.common.kernel.BusinessRuleViolationException;
import com.platepilote.platepilote.common.security.JwtService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.time.Instant;
import java.util.HashSet;
import java.util.Optional;
import java.util.Set;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyMap;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

/**
 * Pure-unit coverage of {@link AuthService} covering the full authentication lifecycle:
 * signup, login, refresh, logout, logout-all, password reset. Runs on the H2/no-context
 * runner and complements the existing {@code AuthServiceOAuth2Test}.
 */
@ExtendWith(MockitoExtension.class)
class AuthServiceTest {

    @Mock private UserRepository userRepository;
    @Mock private RefreshTokenRepository refreshTokenRepository;
    @Mock private RoleRepository roleRepository;
    @Mock private PasswordEncoder passwordEncoder;
    @Mock private AuthenticationManager authenticationManager;
    @Mock private JwtService jwtService;
    @Mock private OAuth2IdentityVerifier oAuth2IdentityVerifier;
    @Mock private EmailVerificationService emailVerificationService;

    private AuthService authService;

    @BeforeEach
    void setUp() {
        authService = new AuthService(userRepository, refreshTokenRepository, roleRepository, passwordEncoder,
                authenticationManager, jwtService, oAuth2IdentityVerifier, emailVerificationService);
    }

    @Test
    void registerIssuesAccessAndRefreshTokensAndTriggersVerificationEmail() {
        RegisterRequest request = new RegisterRequest("Alice", "Smith", "alice@example.com", "Sup3rSecret!");
        when(userRepository.existsByEmail("alice@example.com")).thenReturn(false);
        when(roleRepository.findByName("ROLE_USER"))
                .thenReturn(Optional.of(new Role(UUID.randomUUID(), "ROLE_USER", "User")));
        when(passwordEncoder.encode("Sup3rSecret!")).thenReturn("hashed:pwd");
        when(userRepository.save(any(OurUser.class))).thenAnswer(invocation -> {
            OurUser user = invocation.getArgument(0);
            user.setId(UUID.randomUUID());
            if (user.getRoles() == null) {
                user.setRoles(new HashSet<>());
            }
            return user;
        });
        when(jwtService.generateToken(anyMap(), any())).thenReturn("access.jwt.value");
        when(jwtService.generateRefreshToken(any())).thenReturn("refresh.jwt.value");
        when(jwtService.extractExpirationInstant("refresh.jwt.value"))
                .thenReturn(Instant.now().plusSeconds(3600));

        AuthenticationResponse response = authService.register(request);

        assertThat(response.getAccessToken()).isEqualTo("access.jwt.value");
        assertThat(response.getRefreshToken()).isEqualTo("refresh.jwt.value");
        verify(emailVerificationService).sendVerificationEmail(any(OurUser.class));

        ArgumentCaptor<OurUser> userCaptor = ArgumentCaptor.forClass(OurUser.class);
        verify(userRepository).save(userCaptor.capture());
        OurUser saved = userCaptor.getValue();
        assertThat(saved.getEmail()).isEqualTo("alice@example.com");
        assertThat(saved.getProvider()).isEqualTo("local");
        assertThat(saved.getEmailVerified()).isFalse();
        assertThat(saved.getEnabled()).isTrue();
        assertThat(saved.getPasswordHash()).isEqualTo("hashed:pwd");
        assertThat(saved.getRoles()).extracting(Role::getName).containsExactly("ROLE_USER");

        ArgumentCaptor<RefreshToken> tokenCaptor = ArgumentCaptor.forClass(RefreshToken.class);
        verify(refreshTokenRepository).save(tokenCaptor.capture());
        assertThat(tokenCaptor.getValue().getUserId()).isEqualTo(saved.getId());
        assertThat(tokenCaptor.getValue().getRevoked()).isFalse();
    }

    @Test
    void registerRejectsAlreadyRegisteredEmail() {
        RegisterRequest request = new RegisterRequest("Alice", "Smith", "alice@example.com", "Sup3rSecret!");
        when(userRepository.existsByEmail("alice@example.com")).thenReturn(true);

        assertThatThrownBy(() -> authService.register(request))
                .isInstanceOf(BusinessRuleViolationException.class)
                .hasMessageContaining("Email already registered");

        verify(userRepository, never()).save(any());
        verify(refreshTokenRepository, never()).save(any());
    }

    @Test
    void registerFailsWhenDefaultRoleNotConfigured() {
        RegisterRequest request = new RegisterRequest("Alice", "Smith", "alice@example.com", "Sup3rSecret!");
        when(userRepository.existsByEmail("alice@example.com")).thenReturn(false);
        when(roleRepository.findByName("ROLE_USER")).thenReturn(Optional.empty());

        assertThatThrownBy(() -> authService.register(request))
                .isInstanceOf(BusinessRuleViolationException.class)
                .hasMessageContaining("Default user role");
    }

    @Test
    void loginDelegatesAuthenticationAndIssuesTokens() {
        LoginRequest loginRequest = new LoginRequest("alice@example.com", "Sup3rSecret!");
        OurUser user = user("alice@example.com");
        when(authenticationManager.authenticate(any(Authentication.class)))
                .thenReturn(new UsernamePasswordAuthenticationToken("alice@example.com", "Sup3rSecret!", Set.of()));
        when(userRepository.findByEmail("alice@example.com")).thenReturn(Optional.of(user));
        when(jwtService.generateToken(anyMap(), any())).thenReturn("access.jwt.value");
        when(jwtService.generateRefreshToken(any())).thenReturn("refresh.jwt.value");
        when(jwtService.extractExpirationInstant("refresh.jwt.value"))
                .thenReturn(Instant.now().plusSeconds(3600));

        AuthenticationResponse response = authService.login(loginRequest);

        assertThat(response.getAccessToken()).isEqualTo("access.jwt.value");
        assertThat(response.getRefreshToken()).isEqualTo("refresh.jwt.value");

        ArgumentCaptor<Authentication> authCaptor = ArgumentCaptor.forClass(Authentication.class);
        verify(authenticationManager).authenticate(authCaptor.capture());
        UsernamePasswordAuthenticationToken token =
                (UsernamePasswordAuthenticationToken) authCaptor.getValue();
        assertThat(token.getPrincipal()).isEqualTo("alice@example.com");
        assertThat(token.getCredentials()).isEqualTo("Sup3rSecret!");
    }

    @Test
    void loginPropagatesBadCredentials() {
        LoginRequest loginRequest = new LoginRequest("ghost@example.com", "wrong");
        when(authenticationManager.authenticate(any(Authentication.class)))
                .thenThrow(new BadCredentialsException("bad creds"));

        assertThatThrownBy(() -> authService.login(loginRequest))
                .isInstanceOf(BadCredentialsException.class);
        verify(userRepository, never()).findByEmail(any());
        verify(refreshTokenRepository, never()).save(any());
    }

    @Test
    void refreshTokenRevokesOldTokenAndIssuesNewPair() {
        OurUser user = user("alice@example.com");
        String oldRefresh = "old.refresh.token";
        String tokenHash = sha256Hex(oldRefresh);
        RefreshToken persisted = RefreshToken.builder()
                .userId(user.getId())
                .token(tokenHash)
                .expiresAt(Instant.now().plusSeconds(3600))
                .revoked(false)
                .build();
        persisted.setId(UUID.randomUUID());

        when(jwtService.extractUsername(oldRefresh)).thenReturn("alice@example.com");
        when(userRepository.findByEmail("alice@example.com")).thenReturn(Optional.of(user));
        when(refreshTokenRepository.findByToken(tokenHash)).thenReturn(Optional.of(persisted));
        when(jwtService.isTokenValid(eq(oldRefresh), any())).thenReturn(true);
        when(jwtService.generateToken(anyMap(), any())).thenReturn("access.new");
        when(jwtService.generateRefreshToken(any())).thenReturn("refresh.new");
        when(jwtService.extractExpirationInstant("refresh.new"))
                .thenReturn(Instant.now().plusSeconds(3600));

        AuthenticationResponse response = authService.refreshToken(oldRefresh);

        assertThat(response.getAccessToken()).isEqualTo("access.new");
        assertThat(response.getRefreshToken()).isEqualTo("refresh.new");
        assertThat(persisted.getRevoked()).isTrue();
        verify(refreshTokenRepository).save(persisted);
    }

    @Test
    void refreshTokenRejectsAlreadyRevoked() {
        OurUser user = user("alice@example.com");
        String oldRefresh = "old.refresh.token";
        String tokenHash = sha256Hex(oldRefresh);
        RefreshToken persisted = RefreshToken.builder()
                .userId(user.getId())
                .token(tokenHash)
                .expiresAt(Instant.now().plusSeconds(3600))
                .revoked(true)  // already revoked
                .build();
        persisted.setId(UUID.randomUUID());

        when(jwtService.extractUsername(oldRefresh)).thenReturn("alice@example.com");
        when(userRepository.findByEmail("alice@example.com")).thenReturn(Optional.of(user));
        when(refreshTokenRepository.findByToken(tokenHash)).thenReturn(Optional.of(persisted));

        assertThatThrownBy(() -> authService.refreshToken(oldRefresh))
                .isInstanceOf(BusinessRuleViolationException.class)
                .hasMessageContaining("Invalid refresh token");
        verify(jwtService, never()).generateToken(anyMap(), any());
    }

    @Test
    void refreshTokenRejectsExpired() {
        OurUser user = user("alice@example.com");
        String oldRefresh = "old.refresh.token";
        String tokenHash = sha256Hex(oldRefresh);
        RefreshToken persisted = RefreshToken.builder()
                .userId(user.getId())
                .token(tokenHash)
                .expiresAt(Instant.now().minusSeconds(60))   // expired
                .revoked(false)
                .build();
        persisted.setId(UUID.randomUUID());

        when(jwtService.extractUsername(oldRefresh)).thenReturn("alice@example.com");
        when(userRepository.findByEmail("alice@example.com")).thenReturn(Optional.of(user));
        when(refreshTokenRepository.findByToken(tokenHash)).thenReturn(Optional.of(persisted));

        assertThatThrownBy(() -> authService.refreshToken(oldRefresh))
                .isInstanceOf(BusinessRuleViolationException.class)
                .hasMessageContaining("Invalid refresh token");
    }

    @Test
    void refreshTokenRejectsWrongUser() {
        OurUser user = user("alice@example.com");
        UUID otherUserId = UUID.randomUUID();
        String oldRefresh = "old.refresh.token";
        String tokenHash = sha256Hex(oldRefresh);
        RefreshToken persisted = RefreshToken.builder()
                .userId(otherUserId)   // belongs to someone else
                .token(tokenHash)
                .expiresAt(Instant.now().plusSeconds(3600))
                .revoked(false)
                .build();
        persisted.setId(UUID.randomUUID());

        when(jwtService.extractUsername(oldRefresh)).thenReturn("alice@example.com");
        when(userRepository.findByEmail("alice@example.com")).thenReturn(Optional.of(user));
        when(refreshTokenRepository.findByToken(tokenHash)).thenReturn(Optional.of(persisted));

        assertThatThrownBy(() -> authService.refreshToken(oldRefresh))
                .isInstanceOf(BusinessRuleViolationException.class)
                .hasMessageContaining("Invalid refresh token");
    }

    @Test
    void refreshTokenRejectsMissingEmail() {
        when(jwtService.extractUsername("malformed")).thenReturn(null);

        assertThatThrownBy(() -> authService.refreshToken("malformed"))
                .isInstanceOf(BusinessRuleViolationException.class);
        verify(userRepository, never()).findByEmail(any());
    }

    @Test
    void logoutRevokesMatchingToken() {
        String token = "active.refresh";
        String tokenHash = sha256Hex(token);
        RefreshToken persisted = RefreshToken.builder()
                .userId(UUID.randomUUID())
                .token(tokenHash)
                .expiresAt(Instant.now().plusSeconds(3600))
                .revoked(false)
                .build();
        persisted.setId(UUID.randomUUID());
        when(refreshTokenRepository.findByToken(tokenHash)).thenReturn(Optional.of(persisted));

        authService.logout(token);

        assertThat(persisted.getRevoked()).isTrue();
        verify(refreshTokenRepository).save(persisted);
    }

    @Test
    void logoutIgnoresBlankTokenWithoutDbAccess() {
        authService.logout(null);
        authService.logout("   ");
        verify(refreshTokenRepository, never()).findByToken(any());
    }

    @Test
    void logoutAllDelegatesToRepositoryBulkRevoke() {
        UUID userId = UUID.randomUUID();
        authService.logoutAll(userId);
        verify(refreshTokenRepository).revokeAllActiveForUser(userId);
    }

    @Test
    void forgotPasswordSendsResetEmailOnlyIfUserExists() {
        // Existing user → email is sent
        OurUser existing = user("alice@example.com");
        when(userRepository.findByEmail("alice@example.com")).thenReturn(Optional.of(existing));
        when(jwtService.generateResetToken("alice@example.com")).thenReturn("reset-token");

        authService.forgotPassword("alice@example.com");

        verify(emailVerificationService)
                .sendPasswordResetEmail(eq(existing), eq("reset-token"));

        // Unknown user → silently swallowed (anti-enumeration)
        org.mockito.Mockito.clearInvocations(userRepository, emailVerificationService, jwtService);
        when(userRepository.findByEmail("ghost@example.com")).thenReturn(Optional.empty());
        authService.forgotPassword("ghost@example.com");
        verify(emailVerificationService, never())
                .sendPasswordResetEmail(any(), any());
        verify(jwtService, never()).generateResetToken(any());
    }

    @Test
    void resetPasswordHashesNewPasswordAndRevokesAllTokens() {
        OurUser existing = user("alice@example.com");
        when(jwtService.extractUsername("reset-token")).thenReturn("alice@example.com");
        when(userRepository.findByEmail("alice@example.com")).thenReturn(Optional.of(existing));
        when(jwtService.isResetTokenValid("reset-token", "alice@example.com")).thenReturn(true);
        when(passwordEncoder.encode("BrandNewPwd!")).thenReturn("new-hash");

        authService.resetPassword("reset-token", "BrandNewPwd!");

        ArgumentCaptor<OurUser> userCaptor = ArgumentCaptor.forClass(OurUser.class);
        verify(userRepository).save(userCaptor.capture());
        assertThat(userCaptor.getValue().getPasswordHash()).isEqualTo("new-hash");
        verify(refreshTokenRepository).revokeAllActiveForUser(existing.getId());
    }

    @Test
    void resetPasswordRejectsInvalidToken() {
        when(jwtService.extractUsername("reset-token")).thenReturn("alice@example.com");
        when(userRepository.findByEmail("alice@example.com"))
                .thenReturn(Optional.of(user("alice@example.com")));
        when(jwtService.isResetTokenValid("reset-token", "alice@example.com")).thenReturn(false);

        assertThatThrownBy(() -> authService.resetPassword("reset-token", "BrandNewPwd!"))
                .isInstanceOf(BusinessRuleViolationException.class)
                .hasMessageContaining("Invalid or expired reset token");
        verify(passwordEncoder, never()).encode(any());
        verify(refreshTokenRepository, never()).revokeAllActiveForUser(any());
    }

    @Test
    void resetPasswordRejectsMissingEmailSubject() {
        when(jwtService.extractUsername("reset-token")).thenReturn(null);

        assertThatThrownBy(() -> authService.resetPassword("reset-token", "BrandNewPwd!"))
                .isInstanceOf(BusinessRuleViolationException.class);
        verify(userRepository, never()).findByEmail(any());
    }

    private static OurUser user(String email) {
        OurUser user = OurUser.builder()
                .email(email)
                .firstName("Test")
                .lastName("User")
                .enabled(true)
                .emailVerified(true)
                .passwordHash("hashed")
                .provider("local")
                .roles(new HashSet<>(java.util.List.of(
                        new Role(UUID.randomUUID(), "ROLE_USER", "User"))))
                .build();
        user.setId(UUID.randomUUID());
        return user;
    }

    private static String sha256Hex(String token) {
        try {
            java.security.MessageDigest digest = java.security.MessageDigest.getInstance("SHA-256");
            byte[] hash = digest.digest(token.getBytes(java.nio.charset.StandardCharsets.UTF_8));
            return java.util.HexFormat.of().formatHex(hash);
        } catch (java.security.NoSuchAlgorithmException ex) {
            throw new IllegalStateException(ex);
        }
    }

    private static <T> T eq(T value) {
        return org.mockito.ArgumentMatchers.eq(value);
    }
}
