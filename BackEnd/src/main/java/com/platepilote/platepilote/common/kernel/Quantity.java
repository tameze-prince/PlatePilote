package com.platepilote.platepilote.common.kernel;

/**
 * QUANTITY VALUE OBJECT - SAFE UNIT HANDLING
 * ============================================
 * 
 * WHAT IT IS:
 * A type-safe way to handle quantities with units (e.g., "2.5 kg", "500 ml").
 * 
 * EXAMPLE USAGE:
 * Quantity flour = new Quantity(2.5, "kg");
 * Quantity sugar = new Quantity(500, "g");
 * 
 * WHY IT EXISTS:
 * - Prevents mixing different units (can't add kg + g without conversion)
 * - Prevents negative quantities
 * - Stored in database as: value (DECIMAL) + unit (VARCHAR)
 */

import jakarta.persistence.Embeddable;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Embeddable
@Getter
@NoArgsConstructor
@EqualsAndHashCode
public class Quantity {

    private double value;
    private String unit;

    public Quantity(double value, String unit) {
        if (value < 0) throw new IllegalArgumentException("Quantity cannot be negative");
        if (unit == null || unit.isBlank()) throw new IllegalArgumentException("Unit cannot be null or empty");
        this.value = value;
        this.unit = unit.toLowerCase();
    }

    public static Quantity of(double value, String unit) {
        return new Quantity(value, unit);
    }

    public Quantity add(Quantity other) {
        assertSameUnit(other);
        return new Quantity(this.value + other.value, this.unit);
    }

    public Quantity subtract(Quantity other) {
        assertSameUnit(other);
        double result = this.value - other.value;
        if (result < 0) {
            throw new BusinessRuleViolationException("Cannot subtract: result would be negative");
        }
        return new Quantity(result, this.unit);
    }

    public boolean isGreaterThan(Quantity other) {
        assertSameUnit(other);
        return this.value > other.value;
    }

    public boolean isLessThan(Quantity other) {
        assertSameUnit(other);
        return this.value < other.value;
    }

    public boolean isZero() {
        return this.value == 0;
    }

    private void assertSameUnit(Quantity other) {
        if (!this.unit.equals(other.unit)) {
            throw new IllegalArgumentException("Cannot operate on different units: " + this.unit + " vs " + other.unit);
        }
    }

    @Override
    public String toString() {
        return String.format("%s %s", value, unit);
    }
}
