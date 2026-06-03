package com.platepilote.platepilote.recipes.domain.entity;

/**
 * Entité représentant un favori (recette marquée comme favorite par un utilisateur).
 * <p>
 * La contrainte d'unicité {@code (recipe_id, user_id)} empêche un utilisateur
 * de favoriser plusieurs fois la même recette.
 */
import jakarta.persistence.*;
import lombok.*;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "recipe_favorites", uniqueConstraints = {
    @UniqueConstraint(columnNames = {"recipe_id", "user_id"})
})
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class RecipeFavorite {
    /** Identifiant unique du favori. */
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    /** Identifiant de la recette favorite. */
    @Column(name = "recipe_id", nullable = false)
    private UUID recipeId;

    /** Identifiant de l'utilisateur ayant ajouté le favori. */
    @Column(name = "user_id", nullable = false)
    private UUID userId;

    /** Date à laquelle le favori a été ajouté. */
    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;
}
