package com.platepilote.platepilote.common.security;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.test.util.ReflectionTestUtils;

import java.util.Base64;

import static org.assertj.core.api.Assertions.assertThat;

class JwtServiceTokenPurposeTest {

    private JwtService jwtService;
    private UserDetails userDetails;

    @BeforeEach
    void setUp() {
        jwtService = new JwtService();
        ReflectionTestUtils.setField(jwtService, "secretKey",
                Base64.getEncoder().encodeToString(new byte[64]));
        ReflectionTestUtils.setField(jwtService, "jwtExpiration", 60_000L);
        ReflectionTestUtils.setField(jwtService, "refreshExpiration", 3_600_000L);
        userDetails = User.withUsername("user@example.com")
                .password("not-used")
                .authorities("ROLE_USER")
                .build();
    }

    @Test
    void accessValidatorAcceptsOnlyAccessTokens() {
        String access = jwtService.generateToken(userDetails);
        String refresh = jwtService.generateRefreshToken(userDetails);
        String reset = jwtService.generateResetToken(userDetails.getUsername());

        assertThat(jwtService.isTokenValid(access, userDetails)).isTrue();
        assertThat(jwtService.isTokenValid(refresh, userDetails)).isFalse();
        assertThat(jwtService.isTokenValid(reset, userDetails)).isFalse();
    }

    @Test
    void refreshValidatorAcceptsOnlyRefreshTokens() {
        String access = jwtService.generateToken(userDetails);
        String refresh = jwtService.generateRefreshToken(userDetails);
        String reset = jwtService.generateResetToken(userDetails.getUsername());

        assertThat(jwtService.isRefreshTokenValid(refresh, userDetails)).isTrue();
        assertThat(jwtService.isRefreshTokenValid(access, userDetails)).isFalse();
        assertThat(jwtService.isRefreshTokenValid(reset, userDetails)).isFalse();
    }

    @Test
    void resetValidatorAcceptsOnlyPasswordResetTokens() {
        String access = jwtService.generateToken(userDetails);
        String refresh = jwtService.generateRefreshToken(userDetails);
        String reset = jwtService.generateResetToken(userDetails.getUsername());

        assertThat(jwtService.isResetTokenValid(reset, userDetails.getUsername())).isTrue();
        assertThat(jwtService.isResetTokenValid(access, userDetails.getUsername())).isFalse();
        assertThat(jwtService.isResetTokenValid(refresh, userDetails.getUsername())).isFalse();
        assertThat(jwtService.isResetTokenValid(reset, "another@example.com")).isFalse();
    }

    @Test
    void malformedTokensAreRejectedWithoutEscapingParserExceptions() {
        assertThat(jwtService.isTokenValid("not-a-jwt", userDetails)).isFalse();
        assertThat(jwtService.isRefreshTokenValid("not-a-jwt", userDetails)).isFalse();
        assertThat(jwtService.isResetTokenValid("not-a-jwt", userDetails.getUsername())).isFalse();
    }
}
