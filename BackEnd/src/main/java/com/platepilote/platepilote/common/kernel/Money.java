package com.platepilote.platepilote.common.kernel;

/**
 * MONEY VALUE OBJECT - SAFE CURRENCY HANDLING
 * =============================================
 * 
 * WHAT IT IS:
 * A type-safe way to handle money amounts with currency.
 * Instead of using raw doubles (which cause rounding errors), we use BigDecimal.
 * 
 * WHY NOT USE DOUBLE?
 * - double price = 19.99; // Can have floating point errors: 19.989999999999998
 * - Money handles this correctly with BigDecimal
 * 
 * EXAMPLE USAGE:
 * Money price = new Money(BigDecimal.valueOf(19.99), Currency.getInstance("USD"));
 * Money total = price.multiply(3); // 3 items
 * 
 * STORED IN DATABASE AS:
 * - amount: DECIMAL(10,2) column
 * - currency: VARCHAR(3) column (e.g., "USD", "EUR")
 */

import jakarta.persistence.Column;
import jakarta.persistence.Embeddable;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.Currency;

@Embeddable  // Tells JPA: "This object's fields are stored in the parent entity's table"
@Getter
@NoArgsConstructor
@EqualsAndHashCode
public class Money {

    @Column(name = "amount")
    private BigDecimal amount;

    @Column(name = "currency")
    private String currency;

    public Money(BigDecimal amount, Currency currency) {
        if (amount == null) throw new IllegalArgumentException("Amount cannot be null");
        if (currency == null) throw new IllegalArgumentException("Currency cannot be null");
        this.amount = amount.setScale(2, RoundingMode.HALF_UP); // Always round to 2 decimal places
        this.currency = currency.getCurrencyCode();
    }

    public static Money zero() {
        return new Money(BigDecimal.ZERO, Currency.getInstance("USD"));
    }

    public static Money of(double amount, String currencyCode) {
        return new Money(BigDecimal.valueOf(amount), Currency.getInstance(currencyCode));
    }

    public Money add(Money other) {
        assertSameCurrency(other);
        return new Money(this.amount.add(other.amount), Currency.getInstance(this.currency));
    }

    public Money subtract(Money other) {
        assertSameCurrency(other);
        return new Money(this.amount.subtract(other.amount), Currency.getInstance(this.currency));
    }

    public Money multiply(int quantity) {
        return new Money(this.amount.multiply(BigDecimal.valueOf(quantity)), Currency.getInstance(this.currency));
    }

    public boolean isGreaterThan(Money other) {
        assertSameCurrency(other);
        return this.amount.compareTo(other.amount) > 0;
    }

    public boolean isLessThan(Money other) {
        assertSameCurrency(other);
        return this.amount.compareTo(other.amount) < 0;
    }

    private void assertSameCurrency(Money other) {
        if (!this.currency.equals(other.currency)) {
            throw new IllegalArgumentException("Cannot operate on different currencies");
        }
    }

    @Override
    public String toString() {
        return String.format("%s %s", amount, currency);
    }
}
