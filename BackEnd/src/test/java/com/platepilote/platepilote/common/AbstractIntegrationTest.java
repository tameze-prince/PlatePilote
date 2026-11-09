package com.platepilote.platepilote.common;

import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;
import org.testcontainers.containers.PostgreSQLContainer;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.platepilote.platepilote.common.security.JwtService;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.web.servlet.MockMvc;

/**
 * Base class for full-stack integration tests backed by a Testcontainers PostgreSQL
 * instance. Use this when you need real Flyway migrations + JPA persistence
 * + the Spring Security filter chain end-to-end.
 *
 * <p>The PostgreSQL container is shared by every integration-test class in this
 * test JVM. This is intentional: Spring caches application contexts across test
 * classes, so stopping a class-scoped container can leave a cached datasource
 * pointing at a container that no longer exists.
 *
 * <p>Testcontainers/Ryuk owns cleanup when the test JVM exits. No reusable-container
 * configuration is required, either locally or in CI.
 *
 * <p><strong>Disabled in environments without Docker</strong>: the {@link RequiresDocker}
 * condition lets {@code mvn test} pass locally on dev machines without Docker, while CI
 * runners (with a Docker daemon) execute the full suite. In environments where Docker is
 * known to be absent, set {@code DOCKER_DISABLED=true}.
 */
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@ActiveProfiles("test")
@AutoConfigureMockMvc
@RequiresDocker
public abstract class AbstractIntegrationTest {

    @SuppressWarnings("resource")
    static final PostgreSQLContainer<?> POSTGRES = new PostgreSQLContainer<>("postgres:16-alpine")
            .withDatabaseName("platepilote_test")
            .withUsername("test")
            .withPassword("test");

    @DynamicPropertySource
    static synchronized void registerDatasourceProperties(DynamicPropertyRegistry registry) {
        // Start lazily when Spring builds an enabled test context. This keeps
        // @RequiresDocker able to skip tests without triggering Docker startup.
        if (!POSTGRES.isRunning()) {
            POSTGRES.start();
        }
        registry.add("spring.datasource.url", POSTGRES::getJdbcUrl);
        registry.add("spring.datasource.username", POSTGRES::getUsername);
        registry.add("spring.datasource.password", POSTGRES::getPassword);
        registry.add("spring.datasource.driver-class-name", () -> "org.postgresql.Driver");
        registry.add("spring.jpa.database-platform", () -> "org.hibernate.dialect.PostgreSQLDialect");
        registry.add("spring.jpa.hibernate.ddl-auto", () -> "validate");
        registry.add("spring.flyway.enabled", () -> "true");
        registry.add("spring.flyway.locations", () -> "classpath:db/migration");
        // Test resources override application.yml and re-enable Flyway for PostgreSQL
        // integration tests. V119 requires this placeholder even outside production.
        registry.add("spring.flyway.placeholders.environment", () -> "test");
    }

    @Autowired protected MockMvc mockMvc;
    @Autowired protected ObjectMapper objectMapper;
    @Autowired protected JwtService jwtService;
}
