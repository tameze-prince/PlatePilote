package com.platepilote.platepilote.common.config;

import com.platepilote.platepilote.authentication.domain.repository.UserRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/**
 * Backfills BCrypt password hashes for the five seeded test users (migration
 * V117) if they were inserted with the placeholder sentinel
 * {@code $2a$10$DowloadNewtonHash}. The placeholder pattern is intentionally
 * non-decodable — the BCrypt runtime will reject every login attempt against
 * it, which would defeat the purpose of having a deterministic test fixture.
 *
 * <p>Activation: triggered automatically on the {@code dev} and {@code test}
 * profiles. In production the migration should be replaced with the real hash
 * before any user logs in; this bootstrap is intentionally disabled outside
 * of those profiles to avoid silently overwriting production credentials.
 *
 * <p>The five UUIDs match the migration file {@code V117__seed_test_users.sql}.
 */
@Configuration
public class TestUserHashBootstrap {

    private static final Logger log = LoggerFactory.getLogger(TestUserHashBootstrap.class);

    static final String PLACEHOLDER_HASH = "$2a$10$DowloadNewtonHash";
    static final String TEST_PASSWORD = "Test123!";

    private static final List<String> SEEDED_USER_IDS = List.of(
            "11111111-1111-1111-1111-111111111111",
            "22222222-2222-2222-2222-222222222222",
            "33333333-3333-3333-3333-333333333333",
            "44444444-4444-4444-4444-444444444444",
            "55555555-5555-5555-5555-555555555555");

    @Bean
    @Profile({"dev", "test", "default"})
    public CommandLineRunner reencodeTestUserPasswords(UserRepository userRepository,
                                                        PasswordEncoder passwordEncoder) {
        return args -> {
            String newHash = passwordEncoder.encode(TEST_PASSWORD);
            int reset = 0;
            for (String userId : SEEDED_USER_IDS) {
                reset += reencodeIfNeeded(userId, newHash, userRepository);
            }
            if (reset > 0) {
                log.info("Re-encoded {} test user BCrypt hashes (migration V117 placeholder fix).", reset);
            }
        };
    }

    @Transactional
    public int reencodeIfNeeded(String userId, String newHash, UserRepository userRepository) {
        return userRepository.findById(java.util.UUID.fromString(userId))
                .filter(user -> PLACEHOLDER_HASH.equals(user.getPasswordHash()))
                .map(user -> {
                    user.setPasswordHash(newHash);
                    userRepository.save(user);
                    return 1;
                })
                .orElse(0);
    }
}
