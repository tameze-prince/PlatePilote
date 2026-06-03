package com.platepilote.platepilote.imports.domain.repository;

import com.platepilote.platepilote.imports.domain.entity.ImportJob;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.UUID;

/**
 * Repository pour l'accès aux données des jobs d'importation.
 * <p>
 * Fournit des méthodes de requête pour lister l'historique des imports.
 */
@Repository
public interface ImportJobRepository extends JpaRepository<ImportJob, UUID> {

    /**
     * Récupère les jobs d'importation non supprimés, triés par date de création décroissante.
     *
     * @param pageable paramètres de pagination
     * @return page de jobs d'importation
     */
    Page<ImportJob> findByDeletedAtIsNullOrderByCreatedAtDesc(Pageable pageable);
}
