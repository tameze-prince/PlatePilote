package com.platepilote.platepilote.common;

import org.junit.jupiter.api.extension.ConditionEvaluationResult;
import org.junit.jupiter.api.extension.ExecutionCondition;
import org.junit.jupiter.api.extension.ExtensionContext;

/**
 * Disables tests annotated with {@link RequiresDocker} when Docker is not available.
 *
 * <p>The check is intentionally cheap (no Docker socket probe): we honour an explicit
 * opt-out via the {@code DOCKER_DISABLED} env var, which is set by the local dev runner
 * when {@code docker --version} fails. CI environments simply skip this annotation and
 * get the full Testcontainers suite.
 */
public class DockerAvailabilityCondition implements ExecutionCondition {

    @Override
    public ConditionEvaluationResult evaluateExecutionCondition(ExtensionContext context) {
        String disabled = System.getenv("DOCKER_DISABLED");
        if ("true".equalsIgnoreCase(disabled) || "1".equals(disabled)) {
            return ConditionEvaluationResult.disabled(
                    "Docker is unavailable in this environment (DOCKER_DISABLED=true). "
                            + "Integration tests are skipped; unit tests still run.");
        }
        return ConditionEvaluationResult.enabled("Docker assumed available");
    }
}
