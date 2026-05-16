package com.platepilote.platepilote.preferences.application.service;

import com.platepilote.platepilote.common.kernel.BusinessRuleViolationException;
import com.platepilote.platepilote.preferences.application.dto.AllergyRequest;
import com.platepilote.platepilote.preferences.application.dto.DietaryPreferenceRequest;
import com.platepilote.platepilote.preferences.domain.entity.Allergy;
import com.platepilote.platepilote.preferences.domain.entity.DietaryPreference;
import com.platepilote.platepilote.preferences.domain.repository.AllergyRepository;
import com.platepilote.platepilote.preferences.domain.repository.DietaryPreferenceRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional
public class PreferencesService {

    private final DietaryPreferenceRepository dietaryPreferenceRepository;
    private final AllergyRepository allergyRepository;

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
}
