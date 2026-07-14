package com.platepilote.platepilote.me.application.service;

import com.platepilote.platepilote.authentication.domain.entity.OurUser;
import com.platepilote.platepilote.authentication.domain.repository.UserRepository;
import com.platepilote.platepilote.grocery.domain.repository.GroceryListRepository;
import com.platepilote.platepilote.mealplanning.domain.repository.MealPlanRepository;
import com.platepilote.platepilote.pantry.domain.repository.PantryItemRepository;
import com.platepilote.platepilote.preferences.application.dto.UserPreferencesResponse;
import com.platepilote.platepilote.preferences.application.service.PreferencesService;
import com.platepilote.platepilote.recipes.domain.repository.RecipeFavoriteRepository;
import com.platepilote.platepilote.recipes.domain.repository.RecipeRepository;
import com.platepilote.platepilote.userprofile.application.dto.UserProfileResponse;
import com.platepilote.platepilote.userprofile.application.service.UserProfileService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;

import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

/**
 * Pinned behaviour for the production-side DSR pipeline on top of {@link MeService}.
 *
 * <p>This test stays at the service level (no Spring context, no DB) so it can run
 * inside the H2-fast lane of {@code mvn test}. A future Testcontainers run (Phase 2C)
 * will cover the Postgres-flavoured E2E happy path.</p>
 */
class MeServiceTest {

    private UserRepository userRepository;
    private UserProfileService userProfileService;
    private PreferencesService preferencesService;
    private MealPlanRepository mealPlanRepository;
    private GroceryListRepository groceryListRepository;
    private PantryItemRepository pantryItemRepository;
    private RecipeFavoriteRepository recipeFavoriteRepository;
    private RecipeRepository recipeRepository;

    private MeService service;
    private OurUser user;

    @BeforeEach
    void setUp() {
        userRepository = mock(UserRepository.class);
        userProfileService = mock(UserProfileService.class);
        preferencesService = mock(PreferencesService.class);
        mealPlanRepository = mock(MealPlanRepository.class);
        groceryListRepository = mock(GroceryListRepository.class);
        pantryItemRepository = mock(PantryItemRepository.class);
        recipeFavoriteRepository = mock(RecipeFavoriteRepository.class);
        recipeRepository = mock(RecipeRepository.class);

        when(mealPlanRepository.findByUserIdAndDeletedAtIsNull(any(UUID.class), any()))
                .thenReturn(org.springframework.data.domain.Page.empty());
        when(groceryListRepository.findByUserIdAndDeletedAtIsNull(any(UUID.class), any()))
                .thenReturn(org.springframework.data.domain.Page.empty());
        when(pantryItemRepository.findByUserIdAndDeletedAtIsNull(any(UUID.class), any()))
                .thenReturn(org.springframework.data.domain.Page.empty());
        when(recipeFavoriteRepository.findByUserIdOrderByCreatedAtDesc(any(UUID.class), any()))
                .thenReturn(org.springframework.data.domain.Page.empty());
        when(recipeRepository.findByUserIdAndDeletedAtIsNull(any(UUID.class), any()))
                .thenReturn(org.springframework.data.domain.Page.empty());

        service = new MeService(
                userRepository,
                userProfileService,
                preferencesService,
                mealPlanRepository,
                groceryListRepository,
                pantryItemRepository,
                recipeFavoriteRepository,
                recipeRepository);

        user = ourUserStub(UUID.randomUUID(), "alpha@example.com", "Alpha", "User");
        when(userRepository.findById(user.getId())).thenReturn(Optional.of(user));
    }

    @Test
    void exportUserDataReturnsEnvelopeWithProfileAndPreferences() {
        when(userProfileService.getProfileByUserId(user.getId())).thenReturn(
                UserProfileResponse.builder().id(user.getId()).userId(user.getId()).firstName("Alpha").build());
        when(preferencesService.getAllPreferences(user.getId())).thenReturn(
                UserPreferencesResponse.builder().build());

        var response = service.exportUserData(user.getId());

        assertThat(response.getUserId()).isEqualTo(user.getId());
        assertThat(response.getEmail()).isEqualTo("alpha@example.com");
        assertThat(response.getFirstName()).isEqualTo("Alpha");
        assertThat(response.getLastName()).isEqualTo("User");
        assertThat(response.getAnalyticsOptOut()).isFalse();
        assertThat(response.getProcessingRestricted()).isFalse();
        assertThat(response.getProfile()).isNotNull();
        assertThat(response.getPreferences()).isNotNull();
        assertThat(response.getExportedAt())
                .isAfterOrEqualTo(Instant.now().minusSeconds(5));
    }

    @Test
    void optOutAnalyticsFlipsFlagAndPersists() {
        when(userRepository.save(any(OurUser.class))).thenAnswer(inv -> inv.getArgument(0));

        var response = service.optOutAnalytics(user.getId());

        ArgumentCaptor<OurUser> captor = ArgumentCaptor.forClass(OurUser.class);
        verify(userRepository).save(captor.capture());
        OurUser saved = captor.getValue();
        assertThat(saved.getAnalyticsOptOut()).isTrue();
        assertThat(saved.getProcessingRestricted()).isFalse();
        assertThat(response.getAction()).isEqualTo("opt-out-analytics");
        assertThat(response.getMessage()).contains("opt-out");
    }

    @Test
    void restrictProcessingFlipsFlagAndPersists() {
        when(userRepository.save(any(OurUser.class))).thenAnswer(inv -> inv.getArgument(0));

        var response = service.restrictProcessing(user.getId());

        ArgumentCaptor<OurUser> captor = ArgumentCaptor.forClass(OurUser.class);
        verify(userRepository).save(captor.capture());
        OurUser saved = captor.getValue();
        assertThat(saved.getProcessingRestricted()).isTrue();
        assertThat(saved.getAnalyticsOptOut()).isFalse();
        assertThat(response.getAction()).isEqualTo("restrict-processing");
    }

    @Test
    void deleteUserAccountSoftsDeletesAndSchedulesPurgeIn30Days() {
        when(userRepository.save(any(OurUser.class))).thenAnswer(inv -> inv.getArgument(0));

        Instant beforeCall = Instant.now();
        var response = service.deleteUserAccount(user.getId());
        Instant afterCall = Instant.now();

        ArgumentCaptor<OurUser> captor = ArgumentCaptor.forClass(OurUser.class);
        verify(userRepository).save(captor.capture());
        OurUser saved = captor.getValue();
        assertThat(saved.getEnabled()).isFalse();
        assertThat(saved.getDeletedAt())
                .isBetween(beforeCall.minusSeconds(1), afterCall.plusSeconds(1));
        assertThat(response.getScheduledPurgeAt())
                .isEqualTo(response.getDeletionDateAt().plus(30, ChronoUnit.DAYS));
        assertThat(response.getGracePeriodDays()).isEqualTo(30);
        assertThat(response.getMessage()).contains("soft-deleted");
    }

    private static OurUser ourUserStub(UUID id, String email, String first, String last) {
        OurUser user = OurUser.builder()
                .email(email)
                .firstName(first)
                .lastName(last)
                .passwordHash("$2a$10$abcdefghijklmnopqrstuv")
                .provider("local")
                .enabled(true)
                .analyticsOptOut(false)
                .processingRestricted(false)
                .build();
        user.setId(id);
        return user;
    }
}
