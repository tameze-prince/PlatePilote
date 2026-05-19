package com.platepilote.platepilote.authentication.application.service;

import com.platepilote.platepilote.authentication.application.dto.OAuth2LoginRequest;
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
import org.springframework.security.crypto.password.PasswordEncoder;

import java.time.Instant;
import java.util.HashSet;
import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyMap;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class AuthServiceOAuth2Test {

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
    void oauth2LoginCreatesUserAndIssuesJwtTokens() {
        OAuth2IdentityVerifier.OAuth2Identity identity = identity(true);
        when(oAuth2IdentityVerifier.verify("google", "id-token")).thenReturn(identity);
        when(roleRepository.findByName("ROLE_USER")).thenReturn(Optional.of(new Role(UUID.randomUUID(), "ROLE_USER", "User")));
        when(userRepository.findByProviderIgnoreCaseAndProviderId("google", "google-sub")).thenReturn(Optional.empty());
        when(userRepository.findByEmail("user@example.com")).thenReturn(Optional.empty());
        when(userRepository.save(any(OurUser.class))).thenAnswer(invocation -> {
            OurUser user = invocation.getArgument(0);
            if (user.getId() == null) {
                user.setId(UUID.randomUUID());
            }
            return user;
        });
        when(jwtService.generateToken(anyMap(), any())).thenReturn("access-token");
        when(jwtService.generateRefreshToken(any())).thenReturn("refresh-token");
        when(jwtService.extractExpirationInstant("refresh-token")).thenReturn(Instant.now().plusSeconds(3600));

        var response = authService.oauth2Login(new OAuth2LoginRequest("google", "id-token", null, null));

        assertThat(response.getAccessToken()).isEqualTo("access-token");
        assertThat(response.getRefreshToken()).isEqualTo("refresh-token");
        ArgumentCaptor<OurUser> userCaptor = ArgumentCaptor.forClass(OurUser.class);
        verify(userRepository).save(userCaptor.capture());
        OurUser savedUser = userCaptor.getValue();
        assertThat(savedUser.getEmail()).isEqualTo("user@example.com");
        assertThat(savedUser.getProvider()).isEqualTo("google");
        assertThat(savedUser.getProviderId()).isEqualTo("google-sub");
        assertThat(savedUser.getEmailVerified()).isTrue();
        assertThat(savedUser.getRoles()).extracting(Role::getName).containsExactly("ROLE_USER");
        verify(refreshTokenRepository).save(any(RefreshToken.class));
    }

    @Test
    void oauth2LoginLinksExistingLocalUserByVerifiedEmail() {
        OAuth2IdentityVerifier.OAuth2Identity identity = identity(true);
        OurUser existing = OurUser.builder()
                .email("user@example.com")
                .firstName("Local")
                .lastName("User")
                .provider("local")
                .enabled(true)
                .emailVerified(false)
                .roles(new HashSet<>())
                .build();
        existing.setId(UUID.randomUUID());
        existing.getRoles().add(new Role(UUID.randomUUID(), "ROLE_USER", "User"));
        when(oAuth2IdentityVerifier.verify("apple", "id-token")).thenReturn(new OAuth2IdentityVerifier.OAuth2Identity(
                "apple", "apple-sub", "user@example.com", true, null, null, null));
        when(roleRepository.findByName("ROLE_USER")).thenReturn(Optional.of(new Role(UUID.randomUUID(), "ROLE_USER", "User")));
        when(userRepository.findByProviderIgnoreCaseAndProviderId("apple", "apple-sub")).thenReturn(Optional.empty());
        when(userRepository.findByEmail("user@example.com")).thenReturn(Optional.of(existing));
        when(userRepository.save(any(OurUser.class))).thenAnswer(invocation -> invocation.getArgument(0));
        when(jwtService.generateToken(anyMap(), any())).thenReturn("access-token");
        when(jwtService.generateRefreshToken(any())).thenReturn("refresh-token");
        when(jwtService.extractExpirationInstant("refresh-token")).thenReturn(Instant.now().plusSeconds(3600));

        authService.oauth2Login(new OAuth2LoginRequest("apple", "id-token", "Apple", "Person"));

        assertThat(existing.getProvider()).isEqualTo("apple");
        assertThat(existing.getProviderId()).isEqualTo("apple-sub");
        assertThat(existing.getFirstName()).isEqualTo("Apple");
        assertThat(existing.getLastName()).isEqualTo("Person");
        assertThat(existing.getEmailVerified()).isTrue();
    }

    @Test
    void oauth2LoginRejectsUnverifiedEmail() {
        when(oAuth2IdentityVerifier.verify("google", "id-token")).thenReturn(identity(false));

        assertThatThrownBy(() -> authService.oauth2Login(new OAuth2LoginRequest("google", "id-token", null, null)))
                .isInstanceOf(BusinessRuleViolationException.class)
                .hasMessageContaining("email must be verified");

        verify(userRepository, never()).save(any());
        verify(refreshTokenRepository, never()).save(any());
    }

    private static OAuth2IdentityVerifier.OAuth2Identity identity(boolean emailVerified) {
        return new OAuth2IdentityVerifier.OAuth2Identity(
                "google",
                "google-sub",
                "user@example.com",
                emailVerified,
                "Google",
                "User",
                "https://example.com/avatar.png"
        );
    }
}
