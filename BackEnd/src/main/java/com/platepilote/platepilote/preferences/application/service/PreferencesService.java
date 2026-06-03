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

/**
 * Service métier pour la gestion des préférences utilisateur
 * (régimes alimentaires, allergies, cuisines).
 */
@Service
@RequiredArgsConstructor
@Transactional
public class PreferencesService {

    private final DietaryPreferenceRepository dietaryPreferenceRepository;
    private final AllergyRepository allergyRepository;
    private final CuisinePreferenceRepository cuisinePreferenceRepository;

    // ==================== PRÉFÉRENCES ALIMENTAIRES (RÉGIMES) ====================

    /**
     * Récupère la liste des régimes alimentaires d'un utilisateur.
     *
     * @param userId identifiant de l'utilisateur
     * @return liste des types de régime
     */
    @Transactional(readOnly = true)
    public List<String> getDietaryPreferences(UUID userId) {
        return dietaryPreferenceRepository.findByUserId(userId)
                .stream()
                .map(DietaryPreference::getDietType)
                .collect(Collectors.toList());
    }

    /**
     * Ajoute un régime alimentaire pour un utilisateur.
     *
     * @param userId  identifiant de l'utilisateur
     * @param request données du régime
     * @throws BusinessRuleViolationException si le régime existe déjà
     */
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

    /**
     * Supprime (soft-delete) un régime alimentaire.
     *
     * @param userId   identifiant de l'utilisateur
     * @param dietType type de régime à supprimer
     * @throws BusinessRuleViolationException si le régime n'existe pas
     */
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

    /**
     * Récupère la liste des allergies d'un utilisateur.
     *
     * @param userId identifiant de l'utilisateur
     * @return liste des allergies
     */
    @Transactional(readOnly = true)
    public List<Allergy> getAllergies(UUID userId) {
        return allergyRepository.findByUserId(userId);
    }

    /**
     * Ajoute une allergie pour un utilisateur.
     *
     * @param userId  identifiant de l'utilisateur
     * @param request données de l'allergie
     * @throws BusinessRuleViolationException si l'allergie existe déjà
     */
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

    /**
     * Supprime (soft-delete) une allergie.
     *
     * @param userId   identifiant de l'utilisateur
     * @param allergen nom de l'allergène à supprimer
     * @throws BusinessRuleViolationException si l'allergie n'existe pas
     */
    public void removeAllergy(UUID userId, String allergen) {
        Allergy allergy = allergyRepository.findByUserId(userId)
                .stream()
                .filter(a -> a.getAllergen().equalsIgnoreCase(allergen))
                .findFirst()
                .orElseThrow(() -> new BusinessRuleViolationException("Allergy not found"));

        allergy.softDelete();
        allergyRepository.save(allergy);
    }

    // ==================== PRÉFÉRENCES CULINAIRES ====================

    /**
     * Récupère la liste des cuisines préférées d'un utilisateur.
     *
     * @param userId identifiant de l'utilisateur
     * @return liste des types de cuisine
     */
    @Transactional(readOnly = true)
    public List<String> getCuisinePreferences(UUID userId) {
        return cuisinePreferenceRepository.findByUserId(userId)
                .stream()
                .map(CuisinePreference::getCuisineType)
                .collect(Collectors.toList());
    }

    /**
     * Ajoute une préférence culinaire pour un utilisateur.
     *
     * @param userId  identifiant de l'utilisateur
     * @param request données de la cuisine
     * @throws BusinessRuleViolationException si la cuisine existe déjà
     */
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

    /**
     * Supprime (soft-delete) une préférence culinaire.
     *
     * @param userId      identifiant de l'utilisateur
     * @param cuisineType type de cuisine à supprimer
     * @throws BusinessRuleViolationException si la cuisine n'existe pas
     */
    public void removeCuisinePreference(UUID userId, String cuisineType) {
        CuisinePreference preference = cuisinePreferenceRepository.findByUserId(userId)
                .stream()
                .filter(c -> c.getCuisineType().equalsIgnoreCase(cuisineType))
                .findFirst()
                .orElseThrow(() -> new BusinessRuleViolationException("Cuisine preference not found"));

        preference.softDelete();
        cuisinePreferenceRepository.save(preference);
    }

    // ==================== PRÉFÉRENCES GROUPÉES ====================

    /**
     * Récupère l'ensemble des préférences (régimes, allergies, cuisines) d'un utilisateur.
     *
     * @param userId identifiant de l'utilisateur
     * @return réponse groupée des préférences
     */
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

    /**
     * Remplace l'ensemble des préférences d'un utilisateur.
     * Les anciennes valeurs sont supprimées avant réinsertion.
     *
     * @param userId  identifiant de l'utilisateur
     * @param request nouvelles préférences
     */
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
