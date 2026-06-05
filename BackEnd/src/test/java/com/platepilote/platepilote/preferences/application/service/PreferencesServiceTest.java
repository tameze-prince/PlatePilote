package com.platepilote.platepilote.preferences.application.service;

import com.platepilote.platepilote.preferences.application.dto.UserPreferencesRequest;
import com.platepilote.platepilote.preferences.application.dto.UserPreferencesResponse;
import com.platepilote.platepilote.preferences.domain.entity.Allergy;
import com.platepilote.platepilote.preferences.domain.entity.CuisinePreference;
import com.platepilote.platepilote.preferences.domain.entity.DietaryPreference;
import com.platepilote.platepilote.preferences.domain.repository.AllergyRepository;
import com.platepilote.platepilote.preferences.domain.repository.CuisinePreferenceRepository;
import com.platepilote.platepilote.preferences.domain.repository.DietaryPreferenceRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;

/**
 * Tests pour PreferencesService.
 * Vérifie notamment la correction du bug de mise à jour groupée des préférences
 * qui utilisait deleteAll() (soft delete) au lieu de deleteAllByUserId() (hard delete).
 */
@ExtendWith(MockitoExtension.class)
class PreferencesServiceTest {

    @Mock
    private DietaryPreferenceRepository dietaryPreferenceRepository;

    @Mock
    private AllergyRepository allergyRepository;

    @Mock
    private CuisinePreferenceRepository cuisinePreferenceRepository;

    @InjectMocks
    private PreferencesService preferencesService;

    private UUID userId;

    @BeforeEach
    void setUp() {
        userId = UUID.randomUUID();
    }

    @Nested
    @DisplayName("updateAllPreferences - Tests de la correction du bug de contrainte d'unicité")
    class UpdateAllPreferencesTests {

        @Test
        @DisplayName("Doit utiliser deleteAllByUserId (hard delete) et non deleteAll (soft delete)")
        void updateAllPreferences_mustUseHardDelete_notSoftDelete() {
            // Arrange
            UserPreferencesRequest request = UserPreferencesRequest.builder()
                    .dietaryPreferences(Arrays.asList("vegetarian", "gluten-free"))
                    .allergies(Collections.singletonList(
                            UserPreferencesRequest.AllergyEntry.builder()
                                    .allergen("peanuts")
                                    .severity("severe")
                                    .build()))
                    .cuisines(Arrays.asList("italian", "french"))
                    .build();

            // Act
            preferencesService.updateAllPreferences(userId, request);

            // Assert - Vérifie que deleteAllByUserId est appelé (hard delete)
            // et non deleteAll (qui aurait fait un soft delete)
            verify(dietaryPreferenceRepository, times(1)).deleteAllByUserId(userId);
            verify(allergyRepository, times(1)).deleteAllByUserId(userId);
            verify(cuisinePreferenceRepository, times(1)).deleteAllByUserId(userId);

            // Vérifie que saveAll est appelé pour réinsérer
            verify(dietaryPreferenceRepository, times(1)).saveAll(any());
            verify(allergyRepository, times(1)).saveAll(any());
            verify(cuisinePreferenceRepository, times(1)).saveAll(any());
        }

        @Test
        @DisplayName("Doit insérer les nouveaux régimes en minuscules")
        void updateAllPreferences_mustInsertDietsInLowercase() {
            // Arrange
            UserPreferencesRequest request = UserPreferencesRequest.builder()
                    .dietaryPreferences(Arrays.asList("VEGETARIAN", "Gluten-Free"))
                    .build();

            ArgumentCaptor<List<DietaryPreference>> captor =
                    ArgumentCaptor.forClass((Class) List.class);

            // Act
            preferencesService.updateAllPreferences(userId, request);

            // Assert
            verify(dietaryPreferenceRepository).saveAll(captor.capture());
            List<DietaryPreference> savedDiets = captor.getValue();

            assertEquals(2, savedDiets.size());
            assertTrue(savedDiets.stream().anyMatch(d -> d.getDietType().equals("vegetarian")));
            assertTrue(savedDiets.stream().anyMatch(d -> d.getDietType().equals("gluten-free")));
        }

        @Test
        @DisplayName("Doit insérer les nouvelles allergies en minuscules")
        void updateAllPreferences_mustInsertAllergiesInLowercase() {
            // Arrange
            UserPreferencesRequest request = UserPreferencesRequest.builder()
                    .allergies(Arrays.asList(
                            UserPreferencesRequest.AllergyEntry.builder()
                                    .allergen("PEANUTS")
                                    .severity("SEVERE")
                                    .build()))
                    .build();

            ArgumentCaptor<List<Allergy>> captor = ArgumentCaptor.forClass((Class) List.class);

            // Act
            preferencesService.updateAllPreferences(userId, request);

            // Assert
            verify(allergyRepository).saveAll(captor.capture());
            List<Allergy> savedAllergies = captor.getValue();

            assertEquals(1, savedAllergies.size());
            assertEquals("peanuts", savedAllergies.get(0).getAllergen());
            assertEquals("SEVERE", savedAllergies.get(0).getSeverity());
        }

        @Test
        @DisplayName("Doit insérer les nouvelles cuisines en minuscules avec niveau LIKE")
        void updateAllPreferences_mustInsertCuisinesInLowercaseWithLikeLevel() {
            // Arrange
            UserPreferencesRequest request = UserPreferencesRequest.builder()
                    .cuisines(Arrays.asList("ITALIAN", "French"))
                    .build();

            ArgumentCaptor<List<CuisinePreference>> captor =
                    ArgumentCaptor.forClass((Class) List.class);

            // Act
            preferencesService.updateAllPreferences(userId, request);

            // Assert
            verify(cuisinePreferenceRepository).saveAll(captor.capture());
            List<CuisinePreference> savedCuisines = captor.getValue();

            assertEquals(2, savedCuisines.size());
            assertTrue(savedCuisines.stream().anyMatch(c ->
                    c.getCuisineType().equals("italian") && "LIKE".equals(c.getPreferenceLevel())));
            assertTrue(savedCuisines.stream().anyMatch(c ->
                    c.getCuisineType().equals("french") && "LIKE".equals(c.getPreferenceLevel())));
        }

        @Test
        @DisplayName("Doit ignorer les entrées nulles ou vides")
        void updateAllPreferences_mustIgnoreNullOrBlankEntries() {
            // Arrange
            UserPreferencesRequest request = UserPreferencesRequest.builder()
                    .dietaryPreferences(Arrays.asList("vegetarian", null, "", "  ", "vegan"))
                    .allergies(Arrays.asList(
                            UserPreferencesRequest.AllergyEntry.builder().allergen(null).build(),
                            UserPreferencesRequest.AllergyEntry.builder().allergen("").build(),
                            UserPreferencesRequest.AllergyEntry.builder().allergen("peanuts").build()))
                    .cuisines(Arrays.asList("italian", null, "", "french"))
                    .build();

            ArgumentCaptor<List<DietaryPreference>> dietsCaptor =
                    ArgumentCaptor.forClass((Class) List.class);
            ArgumentCaptor<List<Allergy>> allergiesCaptor =
                    ArgumentCaptor.forClass((Class) List.class);
            ArgumentCaptor<List<CuisinePreference>> cuisinesCaptor =
                    ArgumentCaptor.forClass((Class) List.class);

            // Act
            preferencesService.updateAllPreferences(userId, request);

            // Assert
            verify(dietaryPreferenceRepository).saveAll(dietsCaptor.capture());
            verify(allergyRepository).saveAll(allergiesCaptor.capture());
            verify(cuisinePreferenceRepository).saveAll(cuisinesCaptor.capture());

            assertEquals(2, dietsCaptor.getValue().size());
            assertEquals(1, allergiesCaptor.getValue().size());
            assertEquals(2, cuisinesCaptor.getValue().size());
        }

        @Test
        @DisplayName("Ne doit rien faire si dietaryPreferences est null")
        void updateAllPreferences_mustDoNothingWhenDietaryPreferencesIsNull() {
            // Arrange
            UserPreferencesRequest request = UserPreferencesRequest.builder()
                    .dietaryPreferences(null)
                    .build();

            // Act
            preferencesService.updateAllPreferences(userId, request);

            // Assert
            verify(dietaryPreferenceRepository, never()).deleteAllByUserId(any());
            verify(dietaryPreferenceRepository, never()).saveAll(any());
        }
    }

    @Nested
    @DisplayName("getAllPreferences - Tests de récupération")
    class GetAllPreferencesTests {

        @Test
        @DisplayName("Doit retourner toutes les préférences groupées")
        void getAllPreferences_mustReturnAllGroupedPreferences() {
            // Arrange
            DietaryPreference diet = DietaryPreference.builder()
                    .userId(userId)
                    .dietType("vegetarian")
                    .build();
            Allergy allergy = Allergy.builder()
                    .userId(userId)
                    .allergen("peanuts")
                    .severity("severe")
                    .build();
            CuisinePreference cuisine = CuisinePreference.builder()
                    .userId(userId)
                    .cuisineType("italian")
                    .preferenceLevel("LIKE")
                    .build();

            when(dietaryPreferenceRepository.findByUserId(userId))
                    .thenReturn(Collections.singletonList(diet));
            when(allergyRepository.findByUserId(userId))
                    .thenReturn(Collections.singletonList(allergy));
            when(cuisinePreferenceRepository.findByUserId(userId))
                    .thenReturn(Collections.singletonList(cuisine));

            // Act
            UserPreferencesResponse response = preferencesService.getAllPreferences(userId);

            // Assert
            assertNotNull(response);
            assertEquals(1, response.getDietaryPreferences().size());
            assertEquals("vegetarian", response.getDietaryPreferences().get(0));
            assertEquals(1, response.getAllergies().size());
            assertEquals("peanuts", response.getAllergies().get(0).getAllergen());
            assertEquals("severe", response.getAllergies().get(0).getSeverity());
            assertEquals(1, response.getCuisines().size());
            assertEquals("italian", response.getCuisines().get(0));
        }

        @Test
        @DisplayName("Doit retourner des listes vides si aucune préférence")
        void getAllPreferences_mustReturnEmptyListsWhenNoPreferences() {
            // Arrange
            when(dietaryPreferenceRepository.findByUserId(userId))
                    .thenReturn(Collections.emptyList());
            when(allergyRepository.findByUserId(userId))
                    .thenReturn(Collections.emptyList());
            when(cuisinePreferenceRepository.findByUserId(userId))
                    .thenReturn(Collections.emptyList());

            // Act
            UserPreferencesResponse response = preferencesService.getAllPreferences(userId);

            // Assert
            assertNotNull(response);
            assertTrue(response.getDietaryPreferences().isEmpty());
            assertTrue(response.getAllergies().isEmpty());
            assertTrue(response.getCuisines().isEmpty());
        }
    }
}