package com.platepilote.platepilote.common.kernel;

/**
 * Entité auditable qui étend {@link BaseEntity} avec le suivi des utilisateurs.
 * <p>
 * Ajoute les champs {@code createdBy} et {@code updatedBy} pour tracer
 * quel utilisateur a créé ou modifié un enregistrement.
 * </p>
 *
 * <p>Exemple :</p>
 * <ul>
 *   <li>L'utilisateur "john@email.com" crée une recette → {@code createdBy = "john@email.com"}</li>
 *   <li>L'utilisateur "admin@email.com" modifie la recette → {@code updatedBy = "admin@email.com"}</li>
 * </ul>
 */
import jakarta.persistence.Column;
import jakarta.persistence.MappedSuperclass;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.springframework.data.annotation.CreatedBy;
import org.springframework.data.annotation.LastModifiedBy;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

@MappedSuperclass
@Getter
@Setter
@NoArgsConstructor
@jakarta.persistence.EntityListeners(AuditingEntityListener.class)
public abstract class AuditableEntity extends BaseEntity {

    /** Email ou identifiant de l'utilisateur ayant créé l'enregistrement. Rempli automatiquement par Spring Security. */
    @CreatedBy
    @Column(name = "created_by", updatable = false)
    private String createdBy;

    /** Email ou identifiant du dernier utilisateur ayant modifié l'enregistrement. Mis à jour automatiquement. */
    @LastModifiedBy
    @Column(name = "updated_by")
    private String updatedBy;
}
