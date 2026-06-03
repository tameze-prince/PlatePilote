package com.platepilote.platepilote.common.kernel;

/**
 * Objet-valeur ({@code Value Object}) représentant un montant monétaire avec sa devise.
 * <p>
 * Utilise {@link java.math.BigDecimal} pour éviter les erreurs d'arrondi des {@code double}.
 * Stocké en base sous forme de colonnes {@code DECIMAL(10,2)} et {@code VARCHAR(3)}.
 * </p>
 */
import jakarta.persistence.Column;
import jakarta.persistence.Embeddable;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.Currency;

@Embeddable
@Getter
@NoArgsConstructor
@EqualsAndHashCode
public class Money {

    /** Montant monétaire arrondi à 2 décimales. */
    @Column(name = "amount")
    private BigDecimal amount;

    /** Code devise (ex : USD, EUR). */
    @Column(name = "currency")
    private String currency;

    /**
     * Crée un montant monétaire.
     *
     * @param amount   montant (ne peut pas être null)
     * @param currency devise (ne peut pas être null)
     */
    public Money(BigDecimal amount, Currency currency) {
        if (amount == null) throw new IllegalArgumentException("Le montant ne peut pas être null");
        if (currency == null) throw new IllegalArgumentException("La devise ne peut pas être null");
        this.amount = amount.setScale(2, RoundingMode.HALF_UP);
        this.currency = currency.getCurrencyCode();
    }

    /**
     * Crée un montant nul en USD.
     *
     * @return montant de 0,00 USD
     */
    public static Money zero() {
        return new Money(BigDecimal.ZERO, Currency.getInstance("USD"));
    }

    /**
     * Crée un montant à partir d'une valeur et d'un code devise.
     *
     * @param amount       valeur numérique
     * @param currencyCode code devise ISO 4217 (ex : "EUR")
     * @return montant monétaire
     */
    public static Money of(double amount, String currencyCode) {
        return new Money(BigDecimal.valueOf(amount), Currency.getInstance(currencyCode));
    }

    /**
     * Additionne un autre montant (même devise requise).
     *
     * @param other montant à additionner
     * @return nouveau montant total
     */
    public Money add(Money other) {
        assertSameCurrency(other);
        return new Money(this.amount.add(other.amount), Currency.getInstance(this.currency));
    }

    /**
     * Soustrait un autre montant (même devise requise).
     *
     * @param other montant à soustraire
     * @return nouveau montant
     */
    public Money subtract(Money other) {
        assertSameCurrency(other);
        return new Money(this.amount.subtract(other.amount), Currency.getInstance(this.currency));
    }

    /**
     * Multiplie le montant par une quantité.
     *
     * @param quantity facteur de multiplication
     * @return nouveau montant
     */
    public Money multiply(int quantity) {
        return new Money(this.amount.multiply(BigDecimal.valueOf(quantity)), Currency.getInstance(this.currency));
    }

    /**
     * Vérifie si ce montant est supérieur à un autre (même devise requise).
     *
     * @param other montant de comparaison
     * @return {@code true} si ce montant est supérieur
     */
    public boolean isGreaterThan(Money other) {
        assertSameCurrency(other);
        return this.amount.compareTo(other.amount) > 0;
    }

    /**
     * Vérifie si ce montant est inférieur à un autre (même devise requise).
     *
     * @param other montant de comparaison
     * @return {@code true} si ce montant est inférieur
     */
    public boolean isLessThan(Money other) {
        assertSameCurrency(other);
        return this.amount.compareTo(other.amount) < 0;
    }

    /**
     * Vérifie que les deux montants ont la même devise.
     *
     * @param other montant à vérifier
     */
    private void assertSameCurrency(Money other) {
        if (!this.currency.equals(other.currency)) {
            throw new IllegalArgumentException("Impossible d'opérer sur des devises différentes");
        }
    }

    @Override
    public String toString() {
        return String.format("%s %s", amount, currency);
    }
}
