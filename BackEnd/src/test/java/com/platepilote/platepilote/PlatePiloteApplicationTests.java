package com.platepilote.platepilote;

/**
 * APPLICATION TEST - VERIFIES THE APPLICATION STARTS CORRECTLY
 * ==============================================================
 * 
 * WHAT IT IS:
 * A basic test that ensures the Spring Boot application can start without errors.
 * 
 * WHAT IT CHECKS:
 * - All beans can be created and wired together
 * - Database connection works (uses Testcontainers for PostgreSQL)
 * - Security configuration is valid
 * - All controllers are registered
 * 
 * HOW TO RUN:
 * mvn test
 * 
 * If this test passes, the application is correctly configured and can start.
 */

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;

@SpringBootTest
@ActiveProfiles("test")
class PlatePiloteApplicationTests {

    @Test
    void contextLoads() {
        // If this test runs without throwing an exception, the application context loaded successfully.
    }
}
