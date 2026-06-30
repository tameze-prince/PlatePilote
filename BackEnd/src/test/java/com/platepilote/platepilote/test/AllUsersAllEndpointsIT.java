package com.platepilote.platepilote.test;

import com.fasterxml.jackson.databind.JsonNode;
import com.platepilote.platepilote.common.AbstractIntegrationTest;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MvcResult;
import org.springframework.test.web.servlet.request.MockHttpServletRequestBuilder;

import java.util.List;
import java.util.Map;
import java.util.Optional;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/**
 * End-to-end coverage sweep across all five PRD personas.
 *
 * <p>For every seeded user, login is exercised against the real Spring
 * Security + JWT filter chain (via {@code AbstractIntegrationTest#mockMvc}),
 * then a deterministic subset of core REST endpoints is hit to assert that
 * authentication, authorisation, JPA repositories and the JWT bearer flow
 * hold together end-to-end.
 *
 * <p>Personas + UUIDs are defined by migration {@code V117__seed_test_users.sql}.
 * The bootstrap {@code TestUserHashBootstrap} re-encodes the BCrypt placeholder
 * before any user logs in.
 *
 * <p>This class contributes only the matrix; all infrastructure (Postgres
 * container, Flyway, JPA, JWT filter chain) is provided by
 * {@link AbstractIntegrationTest}. The class is auto-disabled when
 * {@code DOCKER_DISABLED=true} (see {@link com.platepilote.platepilote.common.RequiresDocker}).
 */
@DisplayName("End-to-end auth + endpoint coverage across all PRD personas")
class AllUsersAllEndpointsIT extends AbstractIntegrationTest {

    private static final String PWD = "Test123!";

    private static final Map<String, UserCreds> USERS = Map.of(
            "sarah",     new UserCreds("11111111-1111-1111-1111-111111111111", "sarah.busypro@platepilote.test",        PWD),
            "markjulia", new UserCreds("22222222-2222-2222-2222-222222222222", "family.youngparents@platepilote.test", PWD),
            "alex",      new UserCreds("33333333-3333-3333-3333-333333333333", "alex.fitness@platepilote.test",         PWD),
            "emily",     new UserCreds("44444444-4444-4444-4444-444444444444", "emily.budget@platepilote.test",         PWD),
            "admin",     new UserCreds("55555555-5555-5555-5555-555555555555", "admin@platepilote.test",                PWD)
    );

    private static final List<EndpointCall> USER_CORE_ENDPOINTS = List.of(
            new EndpointCall("GET",  "/api/v1/profile"),
            new EndpointCall("GET",  "/api/v1/preferences/me"),
            new EndpointCall("GET",  "/api/v1/meal-plans"),
            new EndpointCall("POST", "/api/v1/meal-plans/generate?startDate=2026-07-01"),
            new EndpointCall("GET",  "/api/v1/grocery-lists"),
            new EndpointCall("GET",  "/api/v1/pantry"),
            new EndpointCall("GET",  "/api/v1/notification-preferences"),
            new EndpointCall("GET",  "/api/v1/subscription"),
            new EndpointCall("GET",  "/api/v1/dashboard/home")
    );

    private static final List<String> ADMIN_ENDPOINTS = List.of(
            "/api/v1/admin/overview",
            "/api/v1/admin/users",
            "/api/v1/admin/audit-logs"
    );

    @Test
    @DisplayName("Every seeded user logs in and hits every core endpoint with 200")
    void allUsersCanLoginAndHitCoreEndpoints() throws Exception {
        for (UserCreds user : USERS.values()) {
            String token = login(user.email(), user.password());
            for (EndpointCall call : USER_CORE_ENDPOINTS) {
                mockMvc.perform(authed(call.method(), call.path(), token))
                        .andExpect(status().isOk());
            }
        }
    }

    @Test
    @DisplayName("Plain users (no ADMIN role) receive 403 on /api/v1/admin/**")
    void nonAdminCannotHitAdminEndpoints() throws Exception {
        for (String alias : List.of("sarah", "markjulia", "alex", "emily")) {
            UserCreds user = USERS.get(alias);
            String token = login(user.email(), user.password());
            for (String path : ADMIN_ENDPOINTS) {
                mockMvc.perform(authed("GET", path, token))
                        .andExpect(status().isForbidden());
            }
        }
    }

    @Test
    @DisplayName("Admin user reaches /admin/overview, /admin/users and /admin/audit-logs")
    void adminCanHitAdminEndpoints() throws Exception {
        UserCreds admin = USERS.get("admin");
        String token = login(admin.email(), admin.password());
        for (String path : ADMIN_ENDPOINTS) {
            mockMvc.perform(authed("GET", path, token))
                    .andExpect(status().isOk());
        }
    }

    @Test
    @DisplayName("Public catalog endpoints are reachable without authentication")
    void publicEndpointsAvailableWithoutAuth() throws Exception {
        mockMvc.perform(get("/api/v1/ingredients/search").param("q", "tomato"))
                .andExpect(status().isOk());
        mockMvc.perform(get("/api/v1/recipes/public/search").param("q", "chicken"))
                .andExpect(status().isOk());
    }

    /** Returns the JWT access token issued by {@code POST /api/v1/auth/login}. */
    private String login(String email, String password) throws Exception {
        String body = """
                {"email":"%s","password":"%s"}
                """.formatted(email, password);
        MvcResult result = mockMvc
                .perform(post("/api/v1/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(body))
                .andExpect(status().isOk())
                .andReturn();
        return extractAccessToken(result.getResponse().getContentAsString())
                .orElseThrow(() -> new IllegalStateException(
                        "Login response had no accessToken for " + email));
    }

    private Optional<String> extractAccessToken(String responseBody) throws Exception {
        JsonNode data = objectMapper.readTree(responseBody).path("data");
        if (data.isMissingNode() || data.isNull()) {
            return Optional.empty();
        }
        JsonNode tokenNode = data.path("accessToken");
        String token = tokenNode.isMissingNode() || tokenNode.isNull() ? null : tokenNode.asText();
        return token != null && !token.isBlank() ? Optional.of(token) : Optional.empty();
    }

    private static MockHttpServletRequestBuilder authed(String method, String path, String token) {
        MockHttpServletRequestBuilder builder = switch (method) {
            case "GET" -> get(path);
            case "POST" -> post(path);
            case "PUT" -> put(path);
            case "DELETE" -> delete(path);
            default -> throw new IllegalArgumentException("Unsupported HTTP method: " + method);
        };
        return builder.header("Authorization", "Bearer " + token);
    }

    private record UserCreds(String userId, String email, String password) {}

    private record EndpointCall(String method, String path) {}
}
