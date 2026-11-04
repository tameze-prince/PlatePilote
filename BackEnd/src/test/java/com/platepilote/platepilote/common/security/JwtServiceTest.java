package com.platepilote.platepilote.common.security;

import io.jsonwebtoken.Claims;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.test.util.ReflectionTestUtils;

import java.util.Base64;

import static org.assertj.core.api.Assertions.assertThat;

class JwtServiceTest {

    private JwtService jwtService;
    private UserDetails userDetails;

    @BeforeEach
    void setUp() {
        jwtService = new JwtService();
        ReflectionTestUtils.setField(jwtService, "secretKey",
                Base64.getEncoder().encodeToString(new byte[64]));
        ReflectionTestUtils.setField(jwtService, "jwtExpiration", 60_000L);
        ReflectionTestUtils.setField(jwtService, "refreshExpiration", 120_000L);
        userDetails = User.withUsername("person@example.com")
                .password("not-used")
                .roles("USER")
                .build();
    }

    @Test
    void accessRefreshAndResetTokensHaveDistinctPurposes() {
        String accessToken = jwtService.generateToken(userDetails);
        String refreshToken = jwtService.generateRefreshToken(userDetails);
        String resetToken = jwtService.generateResetToken(userDetails.getUsername());

        assertThat(tokenUse(accessToken)).isEqualTo("access");
        assertThat(tokenUse(refreshToken)).isEqualTo("refresh");
        assertThat(tokenUse(resetToken)).isEqualTo("password_reset");

        assertThat(jwtService.isAccessTokenValid(accessToken, userDetails)).isTrue();
        assertThat(jwtService.isAccessTokenValid(refreshToken, userDetails)).isFalse();
        assertThat(jwtService.isAccessTokenValid(resetToken, userDetails)).isFalse();

        assertThat(jwtService.isRefreshTokenValid(refreshToken, userDetails)).isTrue();
        assertThat(jwtService.isRefreshTokenValid(accessToken, userDetails)).isFalse();
        assertThat(jwtService.isRefreshTokenValid(resetToken, userDetails)).isFalse();

        assertThat(jwtService.isResetTokenValid(resetToken, userDetails.getUsername())).isTrue();
        assertThat(jwtService.isResetTokenValid(accessToken, userDetails.getUsername())).isFalse();
        assertThat(jwtService.isResetTokenValid(refreshToken, userDetails.getUsername())).isFalse();
    }

    @Test
    void accessTokenCannotBeValidatedForAnotherUser() {
        String token = jwtService.generateToken(userDetails);
        UserDetails anotherUser = User.withUsername("another@example.com")
                .password("not-used")
                .roles("USER")
                .build();

        assertThat(jwtService.isAccessTokenValid(token, anotherUser)).isFalse();
    }

    private String tokenUse(String token) {
        return jwtService.extractClaim(token, claims -> claims.get("token_use", String.class));
    }
}
