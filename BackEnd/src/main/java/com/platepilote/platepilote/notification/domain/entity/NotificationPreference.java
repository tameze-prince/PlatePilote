package com.platepilote.platepilote.notification.domain.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "notification_preferences")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class NotificationPreference {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(name = "user_id", nullable = false, unique = true)
    private UUID userId;

    @Column(name = "push_enabled")
    @Builder.Default
    private Boolean pushEnabled = true;

    @Column(name = "email_enabled")
    @Builder.Default
    private Boolean emailEnabled = true;

    @Column(name = "pantry_reminders")
    @Builder.Default
    private Boolean pantryReminders = true;

    @Column(name = "meal_plan_reminders")
    @Builder.Default
    private Boolean mealPlanReminders = true;

    @Column(name = "grocery_reminders")
    @Builder.Default
    private Boolean groceryReminders = true;

    @Column(name = "recipe_recommendations")
    @Builder.Default
    private Boolean recipeRecommendations = true;

    @Column(name = "updated_at", nullable = false)
    private Instant updatedAt;
}
