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
import com.platepilote.platepilote.authentication.application.dto.RegisterRequest;
import com.platepilote.platepilote.authentication.domain.entity.OurUser;
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

import java.util.List;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;  // BCrypt password hasher
    private final AuthenticationManager authenticationManager;  // Spring Security auth manager
    private final JwtService jwtService;  // JWT token generator/validator

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

        // Create new user entity
        OurUser user = OurUser.builder()
                .firstName(request.getFirstName())
                .lastName(request.getLastName())
                .email(request.getEmail())
                .passwordHash(passwordEncoder.encode(request.getPassword()))  // Hash password before saving
                .provider("local")
                .emailVerified(false)
                .enabled(true)
                .build();

        // Save user to database
        userRepository.save(user);

        // Create UserDetails for JWT generation
        UserDetails userDetails = new org.springframework.security.core.userdetails.User(
                user.getEmail(),
                user.getPasswordHash(),
                List.of(new SimpleGrantedAuthority("ROLE_USER"))
        );

        // Generate JWT tokens
        String accessToken = jwtService.generateToken(userDetails);
        String refreshToken = jwtService.generateRefreshToken(userDetails);

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

        // Load user details for JWT generation
        UserDetails userDetails = new org.springframework.security.core.userdetails.User(
                request.getEmail(),
                userRepository.findByEmail(request.getEmail())
                        .orElseThrow()
                        .getPasswordHash(),
                List.of(new SimpleGrantedAuthority("ROLE_USER"))
        );

        // Generate JWT tokens
        String accessToken = jwtService.generateToken(userDetails);
        String refreshToken = jwtService.generateRefreshToken(userDetails);

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
    public AuthenticationResponse refreshToken(String refreshToken) {
        // Extract email from the refresh token
        final String email = jwtService.extractUsername(refreshToken);

        if (email == null) {
            throw new BusinessRuleViolationException("Invalid refresh token");
        }

        // Load user from database
        OurUser user = userRepository.findByEmail(email)
                .orElseThrow(() -> new BusinessRuleViolationException("User not found"));

        // Create UserDetails for validation
        UserDetails userDetails = new org.springframework.security.core.userdetails.User(
                user.getEmail(),
                user.getPasswordHash(),
                List.of(new SimpleGrantedAuthority("ROLE_USER"))
        );

        // Verify the refresh token is still valid
        if (!jwtService.isTokenValid(refreshToken, userDetails)) {
            throw new BusinessRuleViolationException("Invalid refresh token");
        }

        // Generate a new access token (keep the same refresh token)
        String newAccessToken = jwtService.generateToken(userDetails);

        return AuthenticationResponse.builder()
                .accessToken(newAccessToken)
                .refreshToken(refreshToken)
                .build();
    }
}
