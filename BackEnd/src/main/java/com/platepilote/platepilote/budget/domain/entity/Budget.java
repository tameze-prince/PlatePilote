package com.platepilote.platepilote.budget.domain.entity;

import com.platepilote.platepilote.common.kernel.BaseEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.UUID;

/**
 * Entité représentant un budget défini par un utilisateur.
 * Table en base : {@code budgets}.
 */
@Entity
@Table(name = "budgets")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Budget extends BaseEntity {

    /** Identifiant de l'utilisateur propriétaire. */
    @Column(name = "user_id", nullable = false)
    private UUID userId;

    /** Montant alloué au budget. */
    @Column(nullable = false)
    private BigDecimal amount;

    /** Devise du budget (défaut USD). */
    @Column(nullable = false)
    private String currency = "USD";

    /** Période du budget (mensuel, hebdomadaire, etc.). */
    @Column(nullable = false)
    private String period;

    /** Date de début du budget. */
    @Column(name = "start_date", nullable = false)
    private LocalDate startDate;

    /** Date de fin du budget. */
    @Column(name = "end_date")
    private LocalDate endDate;

    /** Montant dépensé sur ce budget. */
    @Column(nullable = false)
    private BigDecimal spent = BigDecimal.ZERO;
}
