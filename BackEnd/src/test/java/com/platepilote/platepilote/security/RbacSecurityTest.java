package com.platepilote.platepilote.security;

import com.platepilote.platepilote.admin.application.service.AdminService;
import com.platepilote.platepilote.admin.presentation.AdminController;
import com.platepilote.platepilote.common.dto.PagedResponse;
import com.platepilote.platepilote.common.security.JwtAuthenticationFilter;
import com.platepilote.platepilote.common.security.JwtService;
import com.platepilote.platepilote.common.security.SecurityConfig;
import com.platepilote.platepilote.common.security.SecurityUtils;
import com.platepilote.platepilote.imports.application.service.ImportService;
import com.platepilote.platepilote.imports.domain.entity.ImportJob;
import com.platepilote.platepilote.imports.presentation.ImportController;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.context.annotation.Import;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.web.servlet.MockMvc;

import java.time.Instant;
import java.util.List;
import java.util.Set;
import java.util.UUID;
import java.util.concurrent.CompletableFuture;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@WebMvcTest({ImportController.class, AdminController.class})
@Import({SecurityConfig.class, JwtAuthenticationFilter.class})
class RbacSecurityTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private JwtService jwtService;

    @MockBean
    private UserDetailsService userDetailsService;

    @MockBean
    private ImportService importService;

    @MockBean
    private AdminService adminService;

    @MockBean
    private SecurityUtils securityUtils;

    @Test
    @WithMockUser(roles = "USER")
    void userCannotAccessImportOrAdminImportEndpoints() throws Exception {
        mockMvc.perform(post("/api/v1/imports/usda"))
                .andExpect(status().isForbidden());

        mockMvc.perform(get("/api/v1/admin/imports"))
                .andExpect(status().isForbidden());

        mockMvc.perform(post("/api/v1/admin/imports/run")
                        .param("source", "usda"))
                .andExpect(status().isForbidden());
    }

    @Test
    @WithMockUser(roles = "CONTENT_MANAGER")
    void contentManagerCanAccessImportAndAdminImportEndpoints() throws Exception {
        ImportJob job = ImportJob.builder()
                .source("USDA")
                .status("STARTED")
                .totalRecords(0)
                .successfulRecords(0)
                .failedRecords(0)
                .startedAt(Instant.now())
                .build();
        when(importService.importFromUsda("chicken", 10))
                .thenReturn(CompletableFuture.completedFuture(job));
        when(adminService.imports(any()))
                .thenReturn(PagedResponse.of(List.of(), 0, 20, 0));

        mockMvc.perform(post("/api/v1/imports/usda"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true));

        mockMvc.perform(get("/api/v1/admin/imports"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true));
    }

    @Test
    @WithMockUser(username = "super@example.com", roles = "SUPER_ADMIN")
    void superAdminCanUpdateUserRoles() throws Exception {
        UUID actorId = UUID.randomUUID();
        UUID targetUserId = UUID.randomUUID();
        AdminService.UserAdminResponse response = new AdminService.UserAdminResponse(
                targetUserId,
                "target@example.com",
                "Target",
                "User",
                true,
                true,
                Set.of("ROLE_USER", "ROLE_PREMIUM_USER"),
                "PREMIUM",
                "ACTIVE",
                Instant.now(),
                Instant.now()
        );

        when(securityUtils.getCurrentUserId(any())).thenReturn(actorId);
        when(adminService.updateRoles(eq(actorId), eq("super@example.com"), eq(targetUserId),
                eq(Set.of("ROLE_USER", "ROLE_PREMIUM_USER"))))
                .thenReturn(response);

        mockMvc.perform(put("/api/v1/admin/users/{id}/roles", targetUserId)
                        .contentType("application/json")
                        .content("{\"roles\":[\"ROLE_USER\",\"ROLE_PREMIUM_USER\"]}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.id").value(targetUserId.toString()))
                .andExpect(jsonPath("$.data.roles.length()").value(2));

        verify(adminService).updateRoles(actorId, "super@example.com", targetUserId,
                Set.of("ROLE_USER", "ROLE_PREMIUM_USER"));
    }
}
