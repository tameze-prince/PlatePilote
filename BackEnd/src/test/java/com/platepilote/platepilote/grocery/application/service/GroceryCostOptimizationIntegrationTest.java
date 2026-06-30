package com.platepilote.platepilote.grocery.application.service;

import org.junit.jupiter.api.Disabled;
import org.junit.jupiter.api.Test;

/**
 * Integration tests for the planned hexagonal Grocery API.
 *
 * These tests reference `GroceryService.listItems(String)`, `optimizeCost(OptimizeCostQuery)`
 * and `application.port.in.*` classes that have not been delivered in the current
 * code path. They remain as documentation of the intended future surface.
 *
 * Disabled until the hexagonal API lands. Re-enable when the production service
 * exposes these entry points or migrate to {@code GroceryServiceTest} for the
 * existing coverage.
 */
@Disabled("Pending hexagonal API. See class-level Javadoc.")
class GroceryCostOptimizationIntegrationTest {
    @Test
    void placeholderForFutureBuild() {
        // No-op until the hexagonal Grocery API is implemented.
    }
}