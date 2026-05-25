package com.platepilote.platepilote.notification.application.service;

import com.platepilote.platepilote.notification.domain.entity.NotificationPreference;
import com.platepilote.platepilote.notification.domain.repository.NotificationPreferenceRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Transactional
public class NotificationPreferenceService {

    private final NotificationPreferenceRepository preferenceRepository;

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

    public record NotificationPreferenceResponse(
            UUID id,
            Boolean pushEnabled,
            Boolean emailEnabled,
            Boolean pantryReminders,
            Boolean mealPlanReminders,
            Boolean groceryReminders,
            Boolean recipeRecommendations
    ) {}

    public record UpdatePreferencesRequest(
            Boolean pushEnabled,
            Boolean emailEnabled,
            Boolean pantryReminders,
            Boolean mealPlanReminders,
            Boolean groceryReminders,
            Boolean recipeRecommendations
    ) {}
}
