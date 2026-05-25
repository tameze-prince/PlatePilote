package com.platepilote.platepilote.preferences.application.service;

import com.platepilote.platepilote.common.kernel.BusinessRuleViolationException;
import com.platepilote.platepilote.preferences.application.dto.AllergyRequest;
import com.platepilote.platepilote.preferences.application.dto.CuisinePreferenceRequest;
import com.platepilote.platepilote.preferences.application.dto.DietaryPreferenceRequest;
import com.platepilote.platepilote.preferences.application.dto.UserPreferencesRequest;
import com.platepilote.platepilote.preferences.application.dto.UserPreferencesResponse;
import com.platepilote.platepilote.preferences.domain.entity.Allergy;
import com.platepilote.platepilote.preferences.domain.entity.CuisinePreference;
import com.platepilote.platepilote.preferences.domain.entity.DietaryPreference;
import com.platepilote.platepilote.preferences.domain.repository.AllergyRepository;
import com.platepilote.platepilote.preferences.domain.repository.CuisinePreferenceRepository;
import com.platepilote.platepilote.preferences.domain.repository.DietaryPreferenceRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional
public class PreferencesService {

    private final DietaryPreferenceRepository dietaryPreferenceRepository;
    private final AllergyRepository allergyRepository;
    private final CuisinePreferenceRepository cuisinePreferenceRepository;

    // ==================== DIETARY PREFERENCES ====================

    @Transactional(readOnly = true)
    public List<String> getDietaryPreferences(UUID userId) {
        return dietaryPreferenceRepository.findByUserId(userId)
                .stream()
                .map(DietaryPreference::getDietType)
                .collect(Collectors.toList());
    }

    public void addDietaryPreference(UUID userId, DietaryPreferenceRequest request) {
        boolean exists = dietaryPreferenceRepository.findByUserId(userId)
                .stream()
                .anyMatch(p -> p.getDietType().equalsIgnoreCase(request.getDietType()));

        if (exists) {
            throw new BusinessRuleViolationException("Dietary preference already exists");
        }

        DietaryPreference preference = DietaryPreference.builder()
                .userId(userId)
                .dietType(request.getDietType().toLowerCase())
                .build();

        dietaryPreferenceRepository.save(preference);
    }

    public void removeDietaryPreference(UUID userId, String dietType) {
        DietaryPreference preference = dietaryPreferenceRepository.findByUserId(userId)
                .stream()
                .filter(p -> p.getDietType().equalsIgnoreCase(dietType))
                .findFirst()
                .orElseThrow(() -> new BusinessRuleViolationException("Dietary preference not found"));

        preference.softDelete();
        dietaryPreferenceRepository.save(preference);
    }

    // ==================== ALLERGIES ====================

    @Transactional(readOnly = true)
    public List<Allergy> getAllergies(UUID userId) {
        return allergyRepository.findByUserId(userId);
    }

    public void addAllergy(UUID userId, AllergyRequest request) {
        boolean exists = allergyRepository.findByUserId(userId)
                .stream()
                .anyMatch(a -> a.getAllergen().equalsIgnoreCase(request.getAllergen()));

        if (exists) {
            throw new BusinessRuleViolationException("Allergy already exists");
        }

        Allergy allergy = Allergy.builder()
                .userId(userId)
                .allergen(request.getAllergen())
                .severity(request.getSeverity())
                .build();

        allergyRepository.save(allergy);
    }

    public void removeAllergy(UUID userId, String allergen) {
        Allergy allergy = allergyRepository.findByUserId(userId)
                .stream()
                .filter(a -> a.getAllergen().equalsIgnoreCase(allergen))
                .findFirst()
                .orElseThrow(() -> new BusinessRuleViolationException("Allergy not found"));

        allergy.softDelete();
        allergyRepository.save(allergy);
    }

    // ==================== CUISINE PREFERENCES ====================

    @Transactional(readOnly = true)
    public List<String> getCuisinePreferences(UUID userId) {
        return cuisinePreferenceRepository.findByUserId(userId)
                .stream()
                .map(CuisinePreference::getCuisineType)
                .collect(Collectors.toList());
    }

    public void addCuisinePreference(UUID userId, CuisinePreferenceRequest request) {
        boolean exists = cuisinePreferenceRepository.findByUserId(userId)
                .stream()
                .anyMatch(c -> c.getCuisineType().equalsIgnoreCase(request.getCuisineType()));

        if (exists) {
            throw new BusinessRuleViolationException("Cuisine preference already exists");
        }

        CuisinePreference preference = CuisinePreference.builder()
                .userId(userId)
                .cuisineType(request.getCuisineType().toLowerCase())
                .preferenceLevel("LIKE")
                .build();

        cuisinePreferenceRepository.save(preference);
    }

    public void removeCuisinePreference(UUID userId, String cuisineType) {
        CuisinePreference preference = cuisinePreferenceRepository.findByUserId(userId)
                .stream()
                .filter(c -> c.getCuisineType().equalsIgnoreCase(cuisineType))
                .findFirst()
                .orElseThrow(() -> new BusinessRuleViolationException("Cuisine preference not found"));

        preference.softDelete();
        cuisinePreferenceRepository.save(preference);
    }

    // ==================== AGGREGATED PREFERENCES ====================

    @Transactional(readOnly = true)
    public UserPreferencesResponse getAllPreferences(UUID userId) {
        List<String> diets = getDietaryPreferences(userId);

        List<UserPreferencesResponse.AllergyEntry> allergyEntries = allergyRepository.findByUserId(userId)
                .stream()
                .map(a -> UserPreferencesResponse.AllergyEntry.builder()
                        .allergen(a.getAllergen())
                        .severity(a.getSeverity())
                        .build())
                .collect(Collectors.toList());

        List<String> cuisines = getCuisinePreferences(userId);

        return UserPreferencesResponse.builder()
                .dietaryPreferences(diets)
                .allergies(allergyEntries)
                .cuisines(cuisines)
                .build();
    }

    public void updateAllPreferences(UUID userId, UserPreferencesRequest request) {
        if (request.getDietaryPreferences() != null) {
            dietaryPreferenceRepository.deleteAll(dietaryPreferenceRepository.findByUserId(userId));

            List<DietaryPreference> newDiets = request.getDietaryPreferences().stream()
                    .filter(diet -> diet != null && !diet.isBlank())
                    .map(diet -> DietaryPreference.builder()
                            .userId(userId)
                            .dietType(diet.toLowerCase())
                            .build())
                    .collect(Collectors.toList());
            dietaryPreferenceRepository.saveAll(newDiets);
        }

        if (request.getAllergies() != null) {
            allergyRepository.deleteAll(allergyRepository.findByUserId(userId));

            List<Allergy> newAllergies = request.getAllergies().stream()
                    .filter(a -> a.getAllergen() != null && !a.getAllergen().isBlank())
                    .map(a -> Allergy.builder()
                            .userId(userId)
                            .allergen(a.getAllergen().toLowerCase())
                            .severity(a.getSeverity())
                            .build())
                    .collect(Collectors.toList());
            allergyRepository.saveAll(newAllergies);
        }

        if (request.getCuisines() != null) {
            cuisinePreferenceRepository.deleteAll(cuisinePreferenceRepository.findByUserId(userId));

            List<CuisinePreference> newCuisines = request.getCuisines().stream()
                    .filter(cuisine -> cuisine != null && !cuisine.isBlank())
                    .map(cuisine -> CuisinePreference.builder()
                            .userId(userId)
                            .cuisineType(cuisine.toLowerCase())
                            .preferenceLevel("LIKE")
                            .build())
                    .collect(Collectors.toList());
            cuisinePreferenceRepository.saveAll(newCuisines);
        }
    }
}
