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

@Service
@RequiredArgsConstructor
@Transactional
public class UserProfileService {

    private final UserProfileRepository userProfileRepository;

    @Transactional(readOnly = true)
    public UserProfileResponse getProfileByUserId(UUID userId) {
        UserProfile profile = userProfileRepository.findByUserId(userId)
                .orElseThrow(() -> new ResourceNotFoundException("UserProfile", "userId", userId.toString()));

        return toResponse(profile);
    }

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
