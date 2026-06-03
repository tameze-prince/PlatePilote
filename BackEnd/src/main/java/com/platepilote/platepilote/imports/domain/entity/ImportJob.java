package com.platepilote.platepilote.imports.domain.entity;

import com.platepilote.platepilote.common.kernel.BaseEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.Instant;

/**
 * Entité représentant un job d'importation de données depuis une source externe.
 * <p>
 * Chaque job enregistre la source (USDA, OpenFoodFacts, etc.), le statut d'avancement
 * (RUNNING, COMPLETED, FAILED), les compteurs d'enregistrements et les horodatages
 * de début et de fin d'exécution. Hérite de BaseEntity pour le soft-delete.
 */
@Entity
@Table(name = "import_jobs")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ImportJob extends BaseEntity {

    /** Nom de la source de données (ex: USDA_FOOD_DATA_CENTRAL, SPOONACULAR). */
    @Column(nullable = false)
    private String source;

    /** Statut du job : RUNNING, COMPLETED, FAILED. */
    @Column(nullable = false)
    private String status;

    /** Nombre total d'enregistrements à traiter. */
    @Column(name = "total_records")
    private Integer totalRecords;

    /** Nombre d'enregistrements importés avec succès. */
    @Column(name = "successful_records")
    private Integer successfulRecords;

    /** Nombre d'enregistrements en échec. */
    @Column(name = "failed_records")
    private Integer failedRecords;

    /** Message d'erreur en cas d'échec du job. */
    @Column(name = "error_message", columnDefinition = "TEXT")
    private String errorMessage;

    /** Date et heure de début du job. */
    @Column(name = "started_at")
    private Instant startedAt;

    /** Date et heure de fin du job. */
    @Column(name = "completed_at")
    private Instant completedAt;
}
