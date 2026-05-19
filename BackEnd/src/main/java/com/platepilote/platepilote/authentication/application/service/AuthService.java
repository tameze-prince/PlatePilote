package com.platepilote.platepilote.authentication.application.service;

/**
 * AUTH SERVICE - BUSINESS LOGIC FOR AUTHENTICATION
 * ==================================================
 * 
 * WHAT IT IS:
 * The service class that handles all authentication business logic.
 * 
 * WHAT IT DOES:
 * 1. register() - Creates a new user account and returns JWT tokens
 * 2. login() - Validates credentials and returns JWT tokens
 * 3. refreshToken() - Generates new access token from refresh token
 * 
 * REGISTER FLOW:
 * 1. Check if email already exists -> throw error if yes
 * 2. Hash the password with BCrypt (one-way encryption)
 * 3. Create User entity and save to database
 * 4. Generate access token and refresh token
 * 5. Return tokens to the client
 * 
 * LOGIN FLOW:
 * 1. Call Spring Security's AuthenticationManager to validate email/password
 * 2. If valid, load user details from database
 * 3. Generate access token and refresh token
 * 4. Return tokens to the client
 * 
 * REFRESH TOKEN FLOW:
 * 1. Extract email from the refresh token
 * 2. Verify the refresh token is valid and not expired
 * 3. Generate a new access token
 * 4. Return new access token (keep the same refresh token)
 */

import com.platepilote.platepilote.authentication.application.dto.AuthenticationResponse;
import com.platepilote.platepilote.authentication.application.dto.LoginRequest;
import com.platepilote.platepilote.authentication.application.dto.OAuth2LoginRequest;
import com.platepilote.platepilote.authentication.application.dto.RegisterRequest;
import com.platepilote.platepilote.authentication.domain.entity.OurUser;
import com.platepilote.platepilote.authentication.domain.entity.RefreshToken;
import com.platepilote.platepilote.authentication.domain.entity.Role;
import com.platepilote.platepilote.authentication.domain.repository.RefreshTokenRepository;
import com.platepilote.platepilote.authentication.domain.repository.RoleRepository;
import com.platepilote.platepilote.authentication.domain.repository.UserRepository;
import com.platepilote.platepilote.common.kernel.BusinessRuleViolationException;
import com.platepilote.platepilote.common.security.JwtService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.time.Instant;
import java.util.HashSet;
import java.util.HexFormat;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final UserRepository userRepository;
    private final RefreshTokenRepository refreshTokenRepository;
    private final RoleRepository roleRepository;
    private final PasswordEncoder passwordEncoder;  // BCrypt password hasher
    private final AuthenticationManager authenticationManager;  // Spring Security auth manager
    private final JwtService jwtService;  // JWT token generator/validator
    private final OAuth2IdentityVerifier oAuth2IdentityVerifier;
    private final EmailVerificationService emailVerificationService;

    /**
     * Register a new user account.
     * 
     * @param request Registration data (firstName, lastName, email, password)
     * @return AuthenticationResponse with access and refresh tokens
     * @throws BusinessRuleViolationException if email already exists
     */
    @Transactional
    public AuthenticationResponse register(RegisterRequest request) {
        // Check if email is already registered
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new BusinessRuleViolationException("Email already registered");
        }

        Role userRole = roleRepository.findByName("ROLE_USER")
                .orElseThrow(() -> new BusinessRuleViolationException("Default user role is not configured"));

        OurUser user = OurUser.builder()
                .firstName(request.getFirstName())
                .lastName(request.getLastName())
                .email(request.getEmail())
                .passwordHash(passwordEncoder.encode(request.getPassword()))  // Hash password before saving
                .provider("local")
                .emailVerified(false)
                .enabled(true)
                .roles(new HashSet<>(List.of(userRole)))
                .build();

        // Save user to database
        OurUser savedUser = userRepository.save(user);
        emailVerificationService.sendVerificationEmail(savedUser);

        // Create UserDetails for JWT generation
        UserDetails userDetails = userDetails(savedUser);

        // Generate JWT tokens
        String accessToken = jwtService.generateToken(roleClaims(savedUser), userDetails);
        String refreshToken = issueRefreshToken(savedUser, userDetails);

        return AuthenticationResponse.builder()
                .accessToken(accessToken)
                .refreshToken(refreshToken)
                .build();
    }

    /**
     * Authenticate an existing user.
     * 
     * @param request Login data (email, password)
     * @return AuthenticationResponse with access and refresh tokens
     * @throws BadCredentialsException if email or password is wrong
     */
    public AuthenticationResponse login(LoginRequest request) {
        // Spring Security validates the password against the stored hash
        authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(request.getEmail(), request.getPassword())
        );

        OurUser user = userRepository.findByEmail(request.getEmail())
                .orElseThrow();

        UserDetails userDetails = userDetails(user);

        // Generate JWT tokens
        String accessToken = jwtService.generateToken(roleClaims(user), userDetails);
        String refreshToken = issueRefreshToken(user, userDetails);

        return AuthenticationResponse.builder()
                .accessToken(accessToken)
                .refreshToken(refreshToken)
                .build();
    }

    /**
     * Generate a new access token using a valid refresh token.
     * 
     * @param refreshToken The refresh token sent by the client
     * @return AuthenticationResponse with new access token
     * @throws BusinessRuleViolationException if refresh token is invalid
     */
    @Transactional
    public AuthenticationResponse oauth2Login(OAuth2LoginRequest request) {
        OAuth2IdentityVerifier.OAuth2Identity identity = oAuth2IdentityVerifier.verify(
                request.provider(), request.idToken());
        if (identity.email() == null || identity.email().isBlank()) {
            throw new BusinessRuleViolationException("OAuth2 token is missing email");
        }
        if (!identity.emailVerified()) {
            throw new BusinessRuleViolationException("OAuth2 email must be verified");
        }

        Role userRole = roleRepository.findByName("ROLE_USER")
                .orElseThrow(() -> new BusinessRuleViolationException("Default user role is not configured"));

        OurUser user = userRepository.findByProviderIgnoreCaseAndProviderId(identity.provider(), identity.providerId())
                .or(() -> userRepository.findByEmail(identity.email()))
                .map(existing -> linkOAuth2Identity(existing, identity, request))
                .orElseGet(() -> createOAuth2User(identity, request, userRole));

        if (!Boolean.TRUE.equals(user.getEnabled())) {
            throw new BusinessRuleViolationException("User account is disabled");
        }

        OurUser saved = userRepository.save(user);
        UserDetails userDetails = userDetails(saved);
        String accessToken = jwtService.generateToken(roleClaims(saved), userDetails);
        String refreshToken = issueRefreshToken(saved, userDetails);

        return AuthenticationResponse.builder()
                .accessToken(accessToken)
                .refreshToken(refreshToken)
                .build();
    }

    @Transactional
    public AuthenticationResponse refreshToken(String refreshToken) {
        // Extract email from the refresh token
        final String email = jwtService.extractUsername(refreshToken);

        if (email == null) {
            throw new BusinessRuleViolationException("Invalid refresh token");
        }

        // Load user from database
        OurUser user = userRepository.findByEmail(email)
                .orElseThrow(() -> new BusinessRuleViolationException("User not found"));

        if (!Boolean.TRUE.equals(user.getEnabled())) {
            throw new BusinessRuleViolationException("User account is disabled");
        }

        // Create UserDetails for validation
        UserDetails userDetails = userDetails(user);

        String tokenHash = hashToken(refreshToken);
        RefreshToken persistedToken = refreshTokenRepository.findByToken(tokenHash)
                .orElseThrow(() -> new BusinessRuleViolationException("Invalid refresh token"));

        boolean revoked = Boolean.TRUE.equals(persistedToken.getRevoked());
        boolean expired = persistedToken.getExpiresAt().isBefore(Instant.now());
        boolean wrongUser = !persistedToken.getUserId().equals(user.getId());

        if (revoked || expired || wrongUser || !jwtService.isTokenValid(refreshToken, userDetails)) {
            throw new BusinessRuleViolationException("Invalid refresh token");
        }

        persistedToken.setRevoked(true);
        refreshTokenRepository.save(persistedToken);

        String newAccessToken = jwtService.generateToken(roleClaims(user), userDetails);
        String newRefreshToken = issueRefreshToken(user, userDetails);

        return AuthenticationResponse.builder()
                .accessToken(newAccessToken)
                .refreshToken(newRefreshToken)
                .build();
    }

    @Transactional
    public void logout(String refreshToken) {
        if (refreshToken == null || refreshToken.isBlank()) {
            return;
        }
        String tokenHash = hashToken(refreshToken);
        refreshTokenRepository.findByToken(tokenHash).ifPresent(token -> {
            token.setRevoked(true);
            refreshTokenRepository.save(token);
        });
    }

    @Transactional
    public void logoutAll(UUID userId) {
        refreshTokenRepository.revokeAllActiveForUser(userId);
    }

    private String issueRefreshToken(OurUser user, UserDetails userDetails) {
        String refreshToken = jwtService.generateRefreshToken(userDetails);
        refreshTokenRepository.save(RefreshToken.builder()
                .userId(user.getId())
                .token(hashToken(refreshToken))
                .expiresAt(jwtService.extractExpirationInstant(refreshToken))
                .revoked(false)
                .build());
        return refreshToken;
    }

    private OurUser createOAuth2User(OAuth2IdentityVerifier.OAuth2Identity identity,
                                     OAuth2LoginRequest request,
                                     Role userRole) {
        return OurUser.builder()
                .firstName(nameOrFallback(request.firstName(), identity.firstName(), "User"))
                .lastName(nameOrFallback(request.lastName(), identity.lastName(), ""))
                .email(identity.email())
                .passwordHash(null)
                .provider(identity.provider())
                .providerId(identity.providerId())
                .avatarUrl(identity.avatarUrl())
                .emailVerified(true)
                .enabled(true)
                .roles(new HashSet<>(List.of(userRole)))
                .build();
    }

    private OurUser linkOAuth2Identity(OurUser user,
                                       OAuth2IdentityVerifier.OAuth2Identity identity,
                                       OAuth2LoginRequest request) {
        boolean sameProvider = identity.provider().equalsIgnoreCase(user.getProvider());
        if (user.getProviderId() != null && sameProvider && !user.getProviderId().equals(identity.providerId())) {
            throw new BusinessRuleViolationException("OAuth2 account is already linked to another identity");
        }
        if (user.getProviderId() == null || sameProvider || "local".equalsIgnoreCase(user.getProvider())) {
            user.setProvider(identity.provider());
            user.setProviderId(identity.providerId());
        }
        user.setEmailVerified(true);
        if (user.getAvatarUrl() == null || user.getAvatarUrl().isBlank()) {
            user.setAvatarUrl(identity.avatarUrl());
        }
        if (request.firstName() != null && !request.firstName().isBlank()) {
            user.setFirstName(request.firstName().trim());
        } else if ((user.getFirstName() == null || user.getFirstName().isBlank()) && identity.firstName() != null) {
            user.setFirstName(identity.firstName());
        }
        if (request.lastName() != null && !request.lastName().isBlank()) {
            user.setLastName(request.lastName().trim());
        } else if ((user.getLastName() == null || user.getLastName().isBlank()) && identity.lastName() != null) {
            user.setLastName(identity.lastName());
        }
        return user;
    }

    private String nameOrFallback(String requestValue, String identityValue, String fallback) {
        if (requestValue != null && !requestValue.isBlank()) {
            return requestValue.trim();
        }
        if (identityValue != null && !identityValue.isBlank()) {
            return identityValue.trim();
        }
        return fallback;
    }

    private UserDetails userDetails(OurUser user) {
        return new org.springframework.security.core.userdetails.User(
                user.getEmail(),
                user.getPasswordHash() == null ? "{noop}oauth2" : user.getPasswordHash(),
                Boolean.TRUE.equals(user.getEnabled()),
                true,
                true,
                true,
                user.getRoles().stream()
                        .map(Role::getName)
                        .map(SimpleGrantedAuthority::new)
                        .toList()
        );
    }

    private String hashToken(String token) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] hash = digest.digest(token.getBytes(StandardCharsets.UTF_8));
            return HexFormat.of().formatHex(hash);
        } catch (NoSuchAlgorithmException ex) {
            throw new IllegalStateException("SHA-256 is not available", ex);
        }
    }

    private Map<String, Object> roleClaims(OurUser user) {
        List<String> roles = user.getRoles().stream()
                .map(Role::getName)
                .toList();
        if (roles.isEmpty()) {
            roles = List.of("ROLE_USER");
        }
        return Map.of("roles", roles);
    }
}
