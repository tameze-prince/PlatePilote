package com.platepilote.platepilote.notification.application.service;

import com.platepilote.platepilote.notification.domain.entity.NotificationPreference;
import com.platepilote.platepilote.notification.domain.repository.NotificationPreferenceRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.UUID;

/**
 * Service de gestion des préférences de notification des utilisateurs.
 * <p>
 * Permet de consulter et modifier les préférences (push, email, rappels
 * pour le placard, les plans de repas, les listes de courses et les
 * recommandations de recettes). Les valeurs par défaut sont activées.
 */
@Service
@RequiredArgsConstructor
@Transactional
public class NotificationPreferenceService {

    /** Repository des préférences de notification. */
    private final NotificationPreferenceRepository preferenceRepository;

    /**
     * Récupère les préférences de notification d'un utilisateur.
     * <p>
     * Si aucune préférence n'existe, des valeurs par défaut (tout activé)
     * sont créées et persistées automatiquement.
     *
     * @param userId identifiant de l'utilisateur
     * @return préférences de notification
     */
    @Transactional(readOnly = true)
    public NotificationPreferenceResponse getPreferences(UUID userId) {
        return preferenceRepository.findByUserId(userId)
                .map(this::toResponse)
                .orElseGet(() -> {
                    NotificationPreference prefs = NotificationPreference.builder()
                            .userId(userId)
                            .pushEnabled(true)
                            .emailEnabled(true)
                            .pantryReminders(true)
                            .mealPlanReminders(true)
                            .groceryReminders(true)
                            .recipeRecommendations(true)
                            .updatedAt(Instant.now())
                            .build();
                    NotificationPreference saved = preferenceRepository.save(prefs);
                    return toResponse(saved);
                });
    }

    /**
     * Met à jour les préférences de notification d'un utilisateur.
     * <p>
     * Seuls les champs non null dans la requête sont modifiés.
     * Crée des préférences par défaut si aucune n'existe encore.
     *
     * @param userId  identifiant de l'utilisateur
     * @param request données de mise à jour des préférences
     * @return préférences mises à jour
     */
    @Transactional(readOnly = true)
    public NotificationPreferenceResponse updatePreferences(UUID userId, UpdatePreferencesRequest request) {
        NotificationPreference prefs = preferenceRepository.findByUserId(userId)
                .orElseGet(() -> {
                    NotificationPreference newPrefs = NotificationPreference.builder()
                            .userId(userId)
                            .updatedAt(Instant.now())
                            .build();
                    return preferenceRepository.save(newPrefs);
                });

        if (request.pushEnabled() != null) prefs.setPushEnabled(request.pushEnabled());
        if (request.emailEnabled() != null) prefs.setEmailEnabled(request.emailEnabled());
        if (request.pantryReminders() != null) prefs.setPantryReminders(request.pantryReminders());
        if (request.mealPlanReminders() != null) prefs.setMealPlanReminders(request.mealPlanReminders());
        if (request.groceryReminders() != null) prefs.setGroceryReminders(request.groceryReminders());
        if (request.recipeRecommendations() != null) prefs.setRecipeRecommendations(request.recipeRecommendations());
        prefs.setUpdatedAt(Instant.now());

        NotificationPreference saved = preferenceRepository.save(prefs);
        return toResponse(saved);
    }

    private NotificationPreferenceResponse toResponse(NotificationPreference prefs) {
        return new NotificationPreferenceResponse(
                prefs.getId(),
                prefs.getPushEnabled(),
                prefs.getEmailEnabled(),
                prefs.getPantryReminders(),
                prefs.getMealPlanReminders(),
                prefs.getGroceryReminders(),
                prefs.getRecipeRecommendations()
        );
    }

    /**
     * DTO de réponse pour les préférences de notification.
     *
     * @param id                     identifiant des préférences
     * @param pushEnabled            notifications push activées
     * @param emailEnabled           notifications email activées
     * @param pantryReminders        rappels placard activés
     * @param mealPlanReminders      rappels plans de repas activés
     * @param groceryReminders       rappels listes de courses activés
     * @param recipeRecommendations  recommandations de recettes activées
     */
    public record NotificationPreferenceResponse(
            UUID id,
            Boolean pushEnabled,
            Boolean emailEnabled,
            Boolean pantryReminders,
            Boolean mealPlanReminders,
            Boolean groceryReminders,
            Boolean recipeRecommendations
    ) {}

    /**
     * Requête de mise à jour des préférences de notification.
     * Les champs null ne sont pas modifiés.
     *
     * @param pushEnabled            notifications push
     * @param emailEnabled           notifications email
     * @param pantryReminders        rappels placard
     * @param mealPlanReminders      rappels plans de repas
     * @param groceryReminders       rappels listes de courses
     * @param recipeRecommendations  recommandations de recettes
     */
    public record UpdatePreferencesRequest(
            Boolean pushEnabled,
            Boolean emailEnabled,
            Boolean pantryReminders,
            Boolean mealPlanReminders,
            Boolean groceryReminders,
            Boolean recipeRecommendations
    ) {}
}
