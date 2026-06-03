package com.platepilote.platepilote.notification.domain.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.Instant;
import java.util.UUID;

/**
 * Entité représentant les préférences de notification d'un utilisateur.
 * <p>
 * Chaque utilisateur dispose d'une unique ligne de préférences qui
 * détermine les types de notifications qu'il souhaite recevoir :
 * push, email, rappels placard, plans de repas, listes de courses
 * et recommandations de recettes. Toutes les préférences sont activées
 * par défaut.
 */
@Entity
@Table(name = "notification_preferences")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class NotificationPreference {

    /** Identifiant unique des préférences. */
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    /** Identifiant de l'utilisateur (unique). */
    @Column(name = "user_id", nullable = false, unique = true)
    private UUID userId;

    /** Notifications push activées. */
    @Column(name = "push_enabled")
    @Builder.Default
    private Boolean pushEnabled = true;

    /** Notifications email activées. */
    @Column(name = "email_enabled")
    @Builder.Default
    private Boolean emailEnabled = true;

    /** Rappels d'expiration du placard activés. */
    @Column(name = "pantry_reminders")
    @Builder.Default
    private Boolean pantryReminders = true;

    /** Rappels de plans de repas activés. */
    @Column(name = "meal_plan_reminders")
    @Builder.Default
    private Boolean mealPlanReminders = true;

    /** Rappels de listes de courses activés. */
    @Column(name = "grocery_reminders")
    @Builder.Default
    private Boolean groceryReminders = true;

    /** Recommandations de recettes activées. */
    @Column(name = "recipe_recommendations")
    @Builder.Default
    private Boolean recipeRecommendations = true;

    /** Date de dernière mise à jour des préférences. */
    @Column(name = "updated_at", nullable = false)
    private Instant updatedAt;
}
