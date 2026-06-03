package com.platepilote.platepilote.userprofile.application.service;

import com.platepilote.platepilote.common.kernel.ResourceNotFoundException;
import com.platepilote.platepilote.userprofile.application.dto.UserProfileRequest;
import com.platepilote.platepilote.userprofile.application.dto.UserProfileResponse;
import com.platepilote.platepilote.userprofile.domain.entity.UserProfile;
import com.platepilote.platepilote.userprofile.domain.repository.UserProfileRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

/**
 * Service de gestion des profils utilisateur.
 * <p>
 * Permet de consulter, créer, mettre à jour et supprimer le profil d'un utilisateur.
 * Les profils contiennent des informations physiques et des préférences utilisées
 * par les autres modules (recommandations, nutrition, etc.).
 */
@Service
@RequiredArgsConstructor
@Transactional
public class UserProfileService {

    /** Repository des profils utilisateur. */
    private final UserProfileRepository userProfileRepository;

    /**
     * Récupère le profil d'un utilisateur par son identifiant.
     * <p>
     * Si aucun profil n'existe, un profil par défaut est retourné sans être persisté.
     *
     * @param userId identifiant de l'utilisateur
     * @return profil utilisateur (existant ou par défaut)
     */
    @Transactional(readOnly = true)
    public UserProfileResponse getProfileByUserId(UUID userId) {
        UserProfile profile = userProfileRepository.findByUserId(userId).orElseGet(() -> {
            UserProfile defaultProfile = new UserProfile();
            defaultProfile.setUserId(userId);
            defaultProfile.setCountryCode("US");
            defaultProfile.setCurrencyCode("USD");
            defaultProfile.setLocale("en-US");
            defaultProfile.setCookingSkill("BEGINNER");
            defaultProfile.setHouseholdSize(1);
            return defaultProfile;
        });

        return toResponse(profile);
    }

    /**
     * Crée ou met à jour le profil d'un utilisateur.
     * <p>
     * Si un profil existe déjà, il est mis à jour. Sinon, un nouveau profil est créé.
     * Les valeurs par défaut sont appliquées pour les champs null ou invalides.
     *
     * @param userId  identifiant de l'utilisateur
     * @param request données du profil à enregistrer
     * @return profil créé ou mis à jour
     */
    public UserProfileResponse createOrUpdateProfile(UUID userId, UserProfileRequest request) {
        UserProfile profile = userProfileRepository.findByUserId(userId)
                .orElseGet(() -> {
                    UserProfile newProfile = new UserProfile();
                    newProfile.setUserId(userId);
                    return newProfile;
                });

        profile.setDateOfBirth(request.getDateOfBirth());
        profile.setGender(request.getGender());
        profile.setHeightCm(request.getHeightCm());
        profile.setWeightKg(request.getWeightKg());
        profile.setActivityLevel(request.getActivityLevel());
        profile.setHealthGoals(request.getHealthGoals());
        profile.setCountryCode(defaultIfBlank(request.getCountryCode(), "US").toUpperCase());
        profile.setCurrencyCode(defaultIfBlank(request.getCurrencyCode(), "USD").toUpperCase());
        profile.setLocale(defaultIfBlank(request.getLocale(), "en-US"));
        profile.setCookingSkill(defaultIfBlank(request.getCookingSkill(), "BEGINNER").toUpperCase());
        profile.setHouseholdSize(request.getHouseholdSize() == null || request.getHouseholdSize() < 1
                ? 1
                : request.getHouseholdSize());

        UserProfile saved = userProfileRepository.save(profile);
        return toResponse(saved);
    }

    /**
     * Supprime (soft-delete) le profil d'un utilisateur.
     *
     * @param userId identifiant de l'utilisateur
     * @throws com.platepilote.platepilote.common.kernel.ResourceNotFoundException si le profil n'existe pas
     */
    public void deleteProfile(UUID userId) {
        UserProfile profile = userProfileRepository.findByUserId(userId)
                .orElseThrow(() -> new ResourceNotFoundException("UserProfile", "userId", userId.toString()));
        profile.softDelete();
        userProfileRepository.save(profile);
    }

    private UserProfileResponse toResponse(UserProfile profile) {
        return UserProfileResponse.builder()
                .id(profile.getId())
                .userId(profile.getUserId())
                .dateOfBirth(profile.getDateOfBirth())
                .gender(profile.getGender())
                .heightCm(profile.getHeightCm())
                .weightKg(profile.getWeightKg())
                .activityLevel(profile.getActivityLevel())
                .healthGoals(profile.getHealthGoals())
                .countryCode(profile.getCountryCode())
                .currencyCode(profile.getCurrencyCode())
                .locale(profile.getLocale())
                .cookingSkill(profile.getCookingSkill())
                .householdSize(profile.getHouseholdSize())
                .createdAt(profile.getCreatedAt())
                .updatedAt(profile.getUpdatedAt())
                .build();
    }

    private String defaultIfBlank(String value, String fallback) {
        return value == null || value.isBlank() ? fallback : value.trim();
    }
}
