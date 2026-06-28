package com.platepilote.platepilote.common;

import org.junit.jupiter.api.extension.ExtendWith;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

/**
 * Marks an integration test as gated by Docker availability.
 *
 * <p>The test is DISABLED when:
 * <ul>
 *   <li>{@code DOCKER_DISABLED=true} is set as an environment variable (used by local
 *       environments without a Docker daemon), OR</li>
 *   <li>{@code CI=true} is set AND the {@code skipTcOnCi=true} system property is provided
 *       (default behaviour: IT runs in CI).</li>
 * </ul>
 *
 * <p>This intentionally lets {@code AbstractIntegrationTest} compile and load in any
 * environment, so the Docker-based path stays ready for CI without breaking local dev.
 */
@Retention(RetentionPolicy.RUNTIME)
@Target({ElementType.TYPE})
@ExtendWith(DockerAvailabilityCondition.class)
public @interface RequiresDocker {
}
