package com.platepilote.platepilote.common.kernel;

/**
 * Objet-valeur ({@code Value Object}) représentant une quantité avec son unité de mesure.
 * <p>
 * Exemples : "2.5 kg", "500 ml". Garantit que les opérations ne mélangent pas des unités différentes.
 * </p>
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

    /** Valeur numérique de la quantité. */
    private double value;
    /** Unité de mesure (ex : kg, g, ml, l). */
    private String unit;

    /**
     * Crée une quantité avec une valeur et une unité.
     *
     * @param value valeur numérique (doit être positive)
     * @param unit  unité de mesure (ne peut pas être vide)
     */
    public Quantity(double value, String unit) {
        if (value < 0) throw new IllegalArgumentException("La quantité ne peut pas être négative");
        if (unit == null || unit.isBlank()) throw new IllegalArgumentException("L'unité ne peut pas être vide");
        this.value = value;
        this.unit = unit.toLowerCase();
    }

    /**
     * Crée une quantité avec une valeur et une unité.
     *
     * @param value valeur numérique
     * @param unit  unité de mesure
     * @return nouvelle quantité
     */
    public static Quantity of(double value, String unit) {
        return new Quantity(value, unit);
    }

    /**
     * Additionne une autre quantité (même unité requise).
     *
     * @param other quantité à additionner
     * @return nouvelle quantité totale
     */
    public Quantity add(Quantity other) {
        assertSameUnit(other);
        return new Quantity(this.value + other.value, this.unit);
    }

    /**
     * Soustrait une autre quantité (même unité requise).
     *
     * @param other quantité à soustraire
     * @return nouvelle quantité
     * @throws BusinessRuleViolationException si le résultat est négatif
     */
    public Quantity subtract(Quantity other) {
        assertSameUnit(other);
        double result = this.value - other.value;
        if (result < 0) {
            throw new BusinessRuleViolationException("Impossible de soustraire : le résultat serait négatif");
        }
        return new Quantity(result, this.unit);
    }

    /**
     * Vérifie si cette quantité est supérieure à une autre (même unité requise).
     *
     * @param other quantité de comparaison
     * @return {@code true} si cette quantité est supérieure
     */
    public boolean isGreaterThan(Quantity other) {
        assertSameUnit(other);
        return this.value > other.value;
    }

    /**
     * Vérifie si cette quantité est inférieure à une autre (même unité requise).
     *
     * @param other quantité de comparaison
     * @return {@code true} si cette quantité est inférieure
     */
    public boolean isLessThan(Quantity other) {
        assertSameUnit(other);
        return this.value < other.value;
    }

    /**
     * Vérifie si la quantité est nulle.
     *
     * @return {@code true} si la valeur est 0
     */
    public boolean isZero() {
        return this.value == 0;
    }

    /**
     * Vérifie que les deux quantités ont la même unité.
     *
     * @param other quantité à vérifier
     */
    private void assertSameUnit(Quantity other) {
        if (!this.unit.equals(other.unit)) {
            throw new IllegalArgumentException("Impossible d'opérer sur des unités différentes : " + this.unit + " vs " + other.unit);
        }
    }

    @Override
    public String toString() {
        return String.format("%s %s", value, unit);
    }
}
