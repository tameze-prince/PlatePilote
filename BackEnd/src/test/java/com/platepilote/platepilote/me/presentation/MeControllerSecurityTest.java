package com.platepilote.platepilote.me.presentation;

import com.platepilote.platepilote.authentication.domain.repository.UserRepository;
import com.platepilote.platepilote.common.security.JwtAuthenticationFilter;
import com.platepilote.platepilote.common.security.JwtService;
import com.platepilote.platepilote.common.security.SecurityConfig;
import com.platepilote.platepilote.common.security.SecurityUtils;
import com.platepilote.platepilote.me.application.dto.DataExportResponse;
import com.platepilote.platepilote.me.application.dto.DeleteAccountResponse;
import com.platepilote.platepilote.me.application.dto.RightsActionResponse;
import com.platepilote.platepilote.me.application.service.MeService;
import com.platepilote.platepilote.pantry.application.dto.PantryItemResponse;
import com.platepilote.platepilote.preferences.application.dto.UserPreferencesResponse;
import com.platepilote.platepilote.userprofile.application.dto.UserProfileResponse;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.context.annotation.Import;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.web.servlet.MockMvc;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@WebMvcTest(MeController.class)
@Import({SecurityConfig.class, JwtAuthenticationFilter.class})
class MeControllerSecurityTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private JwtService jwtService;

    @MockBean
    private UserDetailsService userDetailsService;

    @MockBean
    private UserRepository userRepository;

    @MockBean
    private SecurityUtils securityUtils;

    @MockBean
    private MeService meService;

    @Test
    void unauthenticatedDataExportIsRejected() throws Exception {
        mockMvc.perform(get("/api/v1/me/data-export"))
                .andExpect(status().isForbidden());
    }

    @Test
    void unauthenticatedDeleteAccountIsRejected() throws Exception {
        mockMvc.perform(delete("/api/v1/me/account"))
                .andExpect(status().isForbidden());
    }

    @Test
    void unauthenticatedRestrictProcessingIsRejected() throws Exception {
        mockMvc.perform(post("/api/v1/me/restrict-processing"))
                .andExpect(status().isForbidden());
    }

    @Test
    void unauthenticatedOptOutAnalyticsIsRejected() throws Exception {
        mockMvc.perform(post("/api/v1/me/opt-out-analytics"))
                .andExpect(status().isForbidden());
    }

    @Test
    @WithMockUser(username = "user@example.com", roles = "USER")
    void authenticatedDataExportReturnsEnvelope() throws Exception {
        UUID userId = UUID.randomUUID();
        when(securityUtils.getCurrentUserId(any())).thenReturn(userId);

        DataExportResponse export = DataExportResponse.builder()
                .userId(userId)
                .email("user@example.com")
                .firstName("Test")
                .lastName("User")
                .accountCreatedAt(Instant.parse("2026-01-01T00:00:00Z"))
                .exportedAt(Instant.parse("2026-07-14T00:00:00Z"))
                .analyticsOptOut(false)
                .processingRestricted(false)
                .profile(UserProfileResponse.builder()
                        .id(userId)
                        .userId(userId)
                        .firstName("Test")
                        .lastName("User")
                        .locale("fr")
                        .build())
                .preferences(UserPreferencesResponse.builder()
                        .dietaryPreferences(List.of())
                        .allergies(List.of())
                        .cuisines(List.of())
                        .build())
                .mealPlans(List.of())
                .groceryLists(List.of())
                .pantryItems(List.of(PantryItemResponse.builder()
                        .id(UUID.randomUUID())
                        .name("Pasta")
                        .quantity(new java.math.BigDecimal("500.0"))
                        .unit("g")
                        .isExpired(false)
                        .build()))
                .recipeFavorites(List.of())
                .personalRecipes(List.of())
                .build();
        when(meService.exportUserData(userId)).thenReturn(export);

        mockMvc.perform(get("/api/v1/me/data-export"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.userId").value(userId.toString()))
                .andExpect(jsonPath("$.data.email").value("user@example.com"))
                .andExpect(jsonPath("$.data.profile.firstName").value("Test"))
                .andExpect(jsonPath("$.data.pantryItems[0].name").value("Pasta"))
                .andExpect(jsonPath("$.data.mealPlans").isArray())
                .andExpect(jsonPath("$.data.groceryLists").isArray());
    }

    @Test
    @WithMockUser(username = "user@example.com", roles = "USER")
    void authenticatedOptOutAnalyticsForwardsUserId() throws Exception {
        UUID userId = UUID.randomUUID();
        when(securityUtils.getCurrentUserId(any())).thenReturn(userId);
        when(meService.optOutAnalytics(userId))
                .thenReturn(RightsActionResponse.builder()
                        .userId(userId)
                        .action("opt-out-analytics")
                        .processedAt(Instant.now())
                        .message("Analytics opt-out recorded.")
                        .build());

        mockMvc.perform(post("/api/v1/me/opt-out-analytics"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.action").value("opt-out-analytics"));

        verify(meService).optOutAnalytics(userId);
    }

    @Test
    @WithMockUser(username = "user@example.com", roles = "USER")
    void authenticatedRestrictProcessingForwardsUserId() throws Exception {
        UUID userId = UUID.randomUUID();
        when(securityUtils.getCurrentUserId(any())).thenReturn(userId);
        when(meService.restrictProcessing(userId))
                .thenReturn(RightsActionResponse.builder()
                        .userId(userId)
                        .action("restrict-processing")
                        .processedAt(Instant.now())
                        .message("Processing restriction recorded.")
                        .build());

        mockMvc.perform(post("/api/v1/me/restrict-processing"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.action").value("restrict-processing"));

        verify(meService).restrictProcessing(userId);
    }

    @Test
    @WithMockUser(username = "user@example.com", roles = "USER")
    void authenticatedDeleteAccountReturnsPurgeEnvelope() throws Exception {
        UUID userId = UUID.randomUUID();
        Instant deletedAt = Instant.parse("2026-07-14T00:00:00Z");
        Instant purgeAt = deletedAt.plus(30, java.time.temporal.ChronoUnit.DAYS);
        when(securityUtils.getCurrentUserId(any())).thenReturn(userId);
        when(meService.deleteUserAccount(userId))
                .thenReturn(DeleteAccountResponse.builder()
                        .userId(userId)
                        .deletionDateAt(deletedAt)
                        .scheduledPurgeAt(purgeAt)
                        .gracePeriodDays(30)
                        .message("Account soft-deleted. Hard-purge scheduled in 30 days.")
                        .build());

        mockMvc.perform(delete("/api/v1/me/account"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.userId").value(userId.toString()))
                .andExpect(jsonPath("$.data.gracePeriodDays").value(30));

        ArgumentCaptor<UUID> captor = ArgumentCaptor.forClass(UUID.class);
        verify(meService).deleteUserAccount(captor.capture());
        assertThat(captor.getValue()).isEqualTo(userId);
    }
}
