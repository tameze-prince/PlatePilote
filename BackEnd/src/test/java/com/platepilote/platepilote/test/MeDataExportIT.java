package com.platepilote.platepilote.test;

import com.platepilote.platepilote.common.AbstractIntegrationTest;
import com.platepilote.platepilote.common.RequiresDocker;
import com.platepilote.platepilote.me.application.dto.DeleteAccountResponse;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/**
 * End-to-end coverage of {@code /api/v1/me} DSR endpoints against the seeded
 * {@code V117__seed_test_users.sql} personas, backed by the Testcontainers
 * PostgreSQL harness of {@link AbstractIntegrationTest}.
 *
 * <p>Auto-disabled when {@code DOCKER_DISABLED=true} (see
 * {@link com.platepilote.platepilote.common.RequiresDocker}). Local dev
 * coverage stays in {@code MeControllerSecurityTest} (unit slice) and
 * {@code MeServiceTest} (service-level stubs).</p>
 */
@DisplayName("DSR endpoints against seeded personas in Testcontainers Postgres")
@RequiresDocker
class MeDataExportIT extends AbstractIntegrationTest {

    private static final String SARAH_ID = "11111111-1111-1111-1111-111111111111";
    private static final String PWD = "Test123!";

    @Test
    @DisplayName("Sarah can request /me/data-export and the envelope contains her profile")
    void sarahCanExportAndProfileComesBack() throws Exception {
        String token = loginAndCaptureToken("sarah.busypro@platepilote.test");

        String body = mockMvc.perform(get("/api/v1/me/data-export")
                        .header("Authorization", "Bearer " + token))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.userId").value(SARAH_ID))
                .andExpect(jsonPath("$.data.email").value("sarah.busypro@platepilote.test"))
                .andExpect(jsonPath("$.data.firstName").value("Sarah"))
                .andExpect(jsonPath("$.data.mealPlans").isArray())
                .andExpect(jsonPath("$.data.groceryLists").isArray())
                .andReturn()
                .getResponse()
                .getContentAsString();
        assertThat(body).contains("data-export");
    }

    @Test
    @DisplayName("Sarah can flip the opt-out flag and the flag persists")
    void sarahOptsOutAndTheFlagFlips() throws Exception {
        String token = loginAndCaptureToken("sarah.busypro@platepilote.test");

        mockMvc.perform(post("/api/v1/me/opt-out-analytics")
                        .header("Authorization", "Bearer " + token))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.action").value("opt-out-analytics"));

        mockMvc.perform(get("/api/v1/me/data-export")
                        .header("Authorization", "Bearer " + token))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.analyticsOptOut").value(true));
    }

    @Test
    @DisplayName("Sarah's account delete soft-deletes and schedules a 30-day purge")
    void sarahDeletesAccount() throws Exception {
        String token = loginAndCaptureToken("sarah.busypro@platepilote.test");

        String body = mockMvc.perform(delete("/api/v1/me/account")
                        .header("Authorization", "Bearer " + token))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.userId").value(SARAH_ID))
                .andExpect(jsonPath("$.data.gracePeriodDays").value(30))
                .andReturn()
                .getResponse()
                .getContentAsString();

        DeleteAccountResponse typed = mapFromJson(body, DeleteAccountResponse.class);
        assertThat(typed.getScheduledPurgeAt()).isAfter(typed.getDeletionDateAt());

        // Export must reflect that the user is now soft-deleted.
        mockMvc.perform(get("/api/v1/me/data-export")
                        .header("Authorization", "Bearer " + token))
                .andExpect(status().isForbidden())
                .andReturn();
    }

    private String loginAndCaptureToken(String email) throws Exception {
        String body = mockMvc.perform(post("/api/v1/auth/login")
                        .contentType("application/json")
                        .content("{\"email\":\"" + email + "\",\"password\":\"" + PWD + "\"}"))
                .andExpect(status().isOk())
                .andReturn()
                .getResponse()
                .getContentAsString();
        return extractAccessToken(body)
                .orElseThrow(() -> new IllegalStateException(
                        "Missing access_token in login response for " + email));
    }

    private Optional<String> extractAccessToken(String body) throws Exception {
        try {
            var node = objectMapper.readTree(body);
            var token = node.path("data").path("accessToken").asText(null);
            if (!token.isEmpty()) return Optional.of(token);
            token = node.path("accessToken").asText(null);
            if (!token.isEmpty()) return Optional.of(token);
            var tokens = node.path("data").path("tokens");
            token = tokens.path("accessToken").asText(null);
            return token.isEmpty() ? Optional.empty() : Optional.of(token);
        } catch (Exception e) {
            return Optional.empty();
        }
    }

    private <T> T mapFromJson(String body, Class<T> type) throws Exception {
        // Live login envelopes wrap fetch results under .data
        var root = objectMapper.readTree(body);
        var data = root.has("data") ? root.get("data") : root;
        return objectMapper.treeToValue(data, type);
    }
}
