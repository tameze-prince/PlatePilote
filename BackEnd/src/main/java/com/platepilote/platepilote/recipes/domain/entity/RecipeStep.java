package com.platepilote.platepilote.recipes.domain.entity;

/**
 * Entité représentant une étape d'une recette.
 * <p>
 * Chaque étape appartient à une recette (relation many-to-one) et contient
 * un numéro d'ordre, une instruction de cuisson et une durée optionnelle.
 */

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.UUID;

@Entity
@Table(name = "recipe_steps")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class RecipeStep {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "recipe_id", nullable = false)
    private Recipe recipe;

    @Column(name = "step_number", nullable = false)
    private Integer stepNumber;  // 1, 2, 3, ... (order of steps)

    @Column(name = "instruction", nullable = false, columnDefinition = "TEXT")
    private String instruction;  // The actual cooking instruction

    @Column(name = "duration_minutes")
    private Integer durationMinutes;  // How long this step takes (optional)
}
