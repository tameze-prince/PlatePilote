package com.platepilote.platepilote.common;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

/**
 * PostgreSQL contract tests for critical schema invariants.
 *
 * Extending AbstractIntegrationTest runs the real Flyway chain against
 * PostgreSQL Testcontainers and starts Hibernate with ddl-auto=validate.
 */
class DatabaseSchemaContractTest extends AbstractIntegrationTest {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @Test
    void legacyInstantColumnsAreTimezoneAware() {
        assertColumnType("ingredients", "created_at", "timestamp with time zone");
        assertColumnType("barcode_products", "updated_at", "timestamp with time zone");
        assertColumnType("import_jobs", "started_at", "timestamp with time zone");
        assertColumnType("purchase_records", "purchased_at", "timestamp with time zone");
    }

    @Test
    void jsonAndDecimalColumnsMatchTheirEntityContracts() {
        assertColumnType("user_entitlements", "metadata", "jsonb");
        assertColumnNumeric("user_profiles", "weekly_budget", 10, 2);
        assertColumnNumeric("pantry_items", "quantity", 10, 2);
        assertColumnNumeric("grocery_items", "price_confidence", 4, 3);
        assertColumnLength("ingredient_prices", "currency_code", 4);
        assertColumnLength("user_profiles", "locale", 20);
    }

    @Test
    void entityRequiredFlagsAreNotNullable() {
        assertNotNullable("our_user", "provider");
        assertNotNullable("our_user", "enabled");
        assertNotNullable("refresh_tokens", "revoked");
        assertNotNullable("email_verification_tokens", "used");
        assertNotNullable("notifications", "read");
        assertNotNullable("grocery_items", "checked");
        assertNotNullable("grocery_lists", "status");
        assertNotNullable("meal_plans", "status");
        assertNotNullable("device_registrations", "is_active");
    }

    @Test
    void deviceRegistrationHasUserForeignKeyOnItsOwnTable() {
        Integer count = jdbcTemplate.queryForObject("""
                SELECT COUNT(*)
                FROM pg_constraint
                WHERE conrelid = 'device_registrations'::regclass
                  AND contype = 'f'
                  AND confrelid = 'our_user'::regclass
                """, Integer.class);

        assertTrue(count != null && count >= 1,
                "device_registrations must reference our_user");
    }

    private void assertColumnType(String table, String column, String expectedType) {
        String actual = jdbcTemplate.queryForObject("""
                SELECT data_type
                FROM information_schema.columns
                WHERE table_schema = current_schema()
                  AND table_name = ?
                  AND column_name = ?
                """, String.class, table, column);

        assertEquals(expectedType, actual, table + "." + column);
    }

    private void assertNotNullable(String table, String column) {
        String nullable = jdbcTemplate.queryForObject("""
                SELECT is_nullable
                FROM information_schema.columns
                WHERE table_schema = current_schema()
                  AND table_name = ?
                  AND column_name = ?
                """, String.class, table, column);

        assertEquals("NO", nullable, table + "." + column);
    }

    private void assertColumnLength(String table, String column, int expectedLength) {
        Integer actual = jdbcTemplate.queryForObject("""
                SELECT character_maximum_length
                FROM information_schema.columns
                WHERE table_schema = current_schema()
                  AND table_name = ?
                  AND column_name = ?
                """, Integer.class, table, column);

        assertEquals(expectedLength, actual, table + "." + column);
    }

    private void assertColumnNumeric(String table, String column, int precision, int scale) {
        Integer actualPrecision = jdbcTemplate.queryForObject("""
                SELECT numeric_precision
                FROM information_schema.columns
                WHERE table_schema = current_schema()
                  AND table_name = ?
                  AND column_name = ?
                """, Integer.class, table, column);
        Integer actualScale = jdbcTemplate.queryForObject("""
                SELECT numeric_scale
                FROM information_schema.columns
                WHERE table_schema = current_schema()
                  AND table_name = ?
                  AND column_name = ?
                """, Integer.class, table, column);

        assertEquals(precision, actualPrecision, table + "." + column + " precision");
        assertEquals(scale, actualScale, table + "." + column + " scale");
    }
}
