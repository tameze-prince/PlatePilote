package com.platepilote.platepilote.common.kernel;

/**
 * Classe parente de toutes les entités de la base de données.
 * <p>
 * Fournit les champs communs à toutes les tables :
 * <ul>
 *   <li>{@code id} — identifiant unique (UUID)</li>
 *   <li>{@code createdAt} — date de création</li>
 *   <li>{@code updatedAt} — date de dernière modification</li>
 *   <li>{@code deletedAt} — date de suppression logique (soft delete)</li>
 * </ul>
 *
 * La suppression logique consiste à marquer un enregistrement comme supprimé
 * sans l'effacer de la base, permettant la récupération et la traçabilité.
 * </p>
 */
import jakarta.persistence.Column;
import jakarta.persistence.EntityListeners;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.MappedSuperclass;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.Instant;
import java.util.UUID;

@MappedSuperclass
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@EntityListeners(AuditableEntityListener.class)
public abstract class BaseEntity {

    /** Identifiant unique (UUID) de l'enregistrement. */
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    /** Date de création de l'enregistrement. Rempli automatiquement, non modifiable. */
    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;

    /** Date de dernière modification de l'enregistrement. Mis à jour automatiquement. */
    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false)
    private Instant updatedAt;

    /** Date de suppression logique. {@code null} = actif, non {@code null} = supprimé. */
    @Column(name = "deleted_at")
    private Instant deletedAt;

    /**
     * Vérifie si l'enregistrement est supprimé logiquement.
     *
     * @return {@code true} si {@code deletedAt} est renseigné
     */
    public boolean isDeleted() {
        return deletedAt != null;
    }

    /**
     * Supprime logiquement l'enregistrement en renseignant {@code deletedAt}.
     */
    public void softDelete() {
        this.deletedAt = Instant.now();
    }

    /**
     * Restaure un enregistrement supprimé logiquement en passant {@code deletedAt} à {@code null}.
     */
    public void restore() {
        this.deletedAt = null;
    }
}
