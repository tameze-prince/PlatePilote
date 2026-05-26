package com.platepilote.platepilote.admin.presentation;

import com.platepilote.platepilote.admin.application.service.AdminService;
import com.platepilote.platepilote.admin.domain.entity.FeatureFlag;
import com.platepilote.platepilote.admin.domain.entity.SystemSetting;
import com.platepilote.platepilote.common.dto.ApiResponse;
import com.platepilote.platepilote.common.dto.PagedResponse;
import com.platepilote.platepilote.common.security.SecurityUtils;
import com.platepilote.platepilote.imports.application.service.ImportService;
import com.platepilote.platepilote.imports.domain.entity.ImportJob;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.Set;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/admin")
@RequiredArgsConstructor
public class AdminController {

    private final AdminService adminService;
    private final ImportService importService;
    private final SecurityUtils securityUtils;

    @GetMapping("/overview")
    @PreAuthorize("hasAnyRole('ADMIN','SUPER_ADMIN','ANALYST')")
    public ResponseEntity<ApiResponse<AdminService.OverviewResponse>> overview() {
        return ResponseEntity.ok(ApiResponse.success(adminService.overview()));
    }

    @GetMapping("/users")
    @PreAuthorize("hasAnyRole('ADMIN','SUPER_ADMIN','SUPPORT_AGENT')")
    public ResponseEntity<ApiResponse<PagedResponse<AdminService.UserAdminResponse>>> users(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @RequestParam(required = false) String query) {
        Pageable pageable = PageRequest.of(page, size, Sort.by("createdAt").descending());
        return ResponseEntity.ok(ApiResponse.success(adminService.users(pageable, query)));
    }

    @GetMapping("/users/{id}")
    @PreAuthorize("hasAnyRole('ADMIN','SUPER_ADMIN','SUPPORT_AGENT')")
    public ResponseEntity<ApiResponse<AdminService.UserAdminResponse>> user(@PathVariable UUID id) {
        return ResponseEntity.ok(ApiResponse.success(adminService.user(id)));
    }

    @PutMapping("/users/{id}/suspend")
    @PreAuthorize("hasAnyRole('ADMIN','SUPER_ADMIN')")
    public ResponseEntity<ApiResponse<AdminService.UserAdminResponse>> suspendUser(
            @AuthenticationPrincipal UserDetails userDetails,
            @PathVariable UUID id,
            @RequestParam(defaultValue = "true") boolean suspended) {
        UUID actorId = securityUtils.getCurrentUserId(userDetails);
        return ResponseEntity.ok(ApiResponse.success("User status updated",
                adminService.suspendUser(actorId, userDetails.getUsername(), id, suspended)));
    }

    @PutMapping("/users/{id}/roles")
    @PreAuthorize("hasRole('SUPER_ADMIN')")
    public ResponseEntity<ApiResponse<AdminService.UserAdminResponse>> updateRoles(
            @AuthenticationPrincipal UserDetails userDetails,
            @PathVariable UUID id,
            @RequestBody RoleUpdateRequest request) {
        UUID actorId = securityUtils.getCurrentUserId(userDetails);
        return ResponseEntity.ok(ApiResponse.success("User roles updated",
                adminService.updateRoles(actorId, userDetails.getUsername(), id, request.roles())));
    }

    @GetMapping("/recipes")
    @PreAuthorize("hasAnyRole('ADMIN','SUPER_ADMIN','CONTENT_MANAGER')")
    public ResponseEntity<ApiResponse<PagedResponse<AdminService.RecipeAdminResponse>>> recipes(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @RequestParam(required = false) String query) {
        Pageable pageable = PageRequest.of(page, size, Sort.by("createdAt").descending());
        return ResponseEntity.ok(ApiResponse.success(adminService.recipes(pageable, query)));
    }

    @GetMapping("/ingredients")
    @PreAuthorize("hasAnyRole('ADMIN','SUPER_ADMIN','CONTENT_MANAGER')")
    public ResponseEntity<ApiResponse<PagedResponse<AdminService.IngredientAdminResponse>>> ingredients(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @RequestParam(required = false) String query) {
        Pageable pageable = PageRequest.of(page, size, Sort.by("canonicalName").ascending());
        return ResponseEntity.ok(ApiResponse.success(adminService.ingredients(pageable, query)));
    }

    @GetMapping("/imports")
    @PreAuthorize("hasAnyRole('ADMIN','SUPER_ADMIN','CONTENT_MANAGER')")
    public ResponseEntity<ApiResponse<PagedResponse<AdminService.ImportJobResponse>>> imports(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        Pageable pageable = PageRequest.of(page, size);
        return ResponseEntity.ok(ApiResponse.success(adminService.imports(pageable)));
    }

    @GetMapping("/imports/{id}")
    @PreAuthorize("hasAnyRole('ADMIN','SUPER_ADMIN','CONTENT_MANAGER')")
    public ResponseEntity<ApiResponse<AdminService.ImportJobResponse>> importJob(@PathVariable UUID id) {
        return ResponseEntity.ok(ApiResponse.success(adminService.importJob(id)));
    }

    @PostMapping("/imports/{id}/retry")
    @PreAuthorize("hasAnyRole('ADMIN','SUPER_ADMIN','CONTENT_MANAGER')")
    public ResponseEntity<ApiResponse<ImportJob>> retryImport(
            @AuthenticationPrincipal UserDetails userDetails,
            @PathVariable UUID id) {
        UUID actorId = securityUtils.getCurrentUserId(userDetails);
        return ResponseEntity.ok(ApiResponse.success("Import retry requested",
                adminService.retryImport(actorId, userDetails.getUsername(), id)));
    }

    @PostMapping("/imports/run")
    @PreAuthorize("hasAnyRole('ADMIN','SUPER_ADMIN','CONTENT_MANAGER')")
    public ResponseEntity<ApiResponse<ImportJob>> runImport(
            @RequestParam String source,
            @RequestParam(defaultValue = "chicken") String query,
            @RequestParam(defaultValue = "10") int maxResults) {
        ImportJob job = switch (source.toLowerCase()) {
            case "usda" -> importService.importFromUsda(query, maxResults).join();
            case "open-food-facts", "off" -> importService.importFromOpenFoodFacts(query, maxResults).join();
            case "themealdb", "mealdb" -> importService.importFromMealDb(query, maxResults).join();
            case "edamam" -> importService.importFromEdamam(query, maxResults).join();
            case "spoonacular" -> importService.importFromSpoonacular(query, maxResults).join();
            case "nutritionix" -> importService.importFromNutritionix(query, maxResults).join();
            case "tasty" -> importService.importFromTasty(query, maxResults).join();
            case "barcode-lookup", "barcode" -> importService.importFromBarcodeLookup(query, maxResults).join();
            case "chomp" -> importService.importFromChomp(query, maxResults).join();
            case "recipe-api", "recipeapi" -> importService.importFromRecipeAPI(query, maxResults).join();
            default -> throw new IllegalArgumentException("Unsupported import source: " + source);
        };
        return ResponseEntity.ok(ApiResponse.success("Import started", job));
    }

    @GetMapping("/subscriptions")
    @PreAuthorize("hasAnyRole('ADMIN','SUPER_ADMIN','SUPPORT_AGENT')")
    public ResponseEntity<ApiResponse<PagedResponse<AdminService.SubscriptionAdminResponse>>> subscriptions(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        Pageable pageable = PageRequest.of(page, size);
        return ResponseEntity.ok(ApiResponse.success(adminService.subscriptions(pageable)));
    }

    @GetMapping("/audit-logs")
    @PreAuthorize("hasAnyRole('ADMIN','SUPER_ADMIN')")
    public ResponseEntity<ApiResponse<PagedResponse<com.platepilote.platepilote.admin.domain.entity.AuditLog>>> auditLogs(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        Pageable pageable = PageRequest.of(page, size);
        return ResponseEntity.ok(ApiResponse.success(adminService.auditLogs(pageable)));
    }

    @GetMapping("/feature-flags")
    @PreAuthorize("hasRole('SUPER_ADMIN')")
    public ResponseEntity<ApiResponse<List<FeatureFlag>>> featureFlags() {
        return ResponseEntity.ok(ApiResponse.success(adminService.featureFlags()));
    }

    @GetMapping("/system-settings")
    @PreAuthorize("hasRole('SUPER_ADMIN')")
    public ResponseEntity<ApiResponse<List<SystemSetting>>> systemSettings() {
        return ResponseEntity.ok(ApiResponse.success(adminService.systemSettings()));
    }

    @PutMapping("/system-settings/{key}")
    @PreAuthorize("hasRole('SUPER_ADMIN')")
    public ResponseEntity<ApiResponse<SystemSetting>> updateSystemSetting(
            @AuthenticationPrincipal UserDetails userDetails,
            @PathVariable String key,
            @RequestBody SettingUpdateRequest request) {
        UUID actorId = securityUtils.getCurrentUserId(userDetails);
        return ResponseEntity.ok(ApiResponse.success("System setting updated",
                adminService.updateSystemSetting(actorId, userDetails.getUsername(), key, request.value())));
    }

    @GetMapping("/recommendations/analytics")
    @PreAuthorize("hasAnyRole('ADMIN','SUPER_ADMIN','ANALYST')")
    public ResponseEntity<ApiResponse<AdminService.RecommendationAnalyticsResponse>> recommendationAnalytics() {
        return ResponseEntity.ok(ApiResponse.success(adminService.recommendationAnalytics()));
    }

    @GetMapping("/billing-events")
    @PreAuthorize("hasAnyRole('ADMIN','SUPER_ADMIN')")
    public ResponseEntity<ApiResponse<PagedResponse<AdminService.BillingEventResponse>>> billingEvents(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        Pageable pageable = PageRequest.of(page, size);
        return ResponseEntity.ok(ApiResponse.success(adminService.billingEvents(pageable)));
    }

    @PostMapping("/feature-flags/{key}/toggle")
    @PreAuthorize("hasRole('SUPER_ADMIN')")
    public ResponseEntity<ApiResponse<FeatureFlag>> toggleFeatureFlag(
            @AuthenticationPrincipal UserDetails userDetails,
            @PathVariable String key) {
        UUID actorId = securityUtils.getCurrentUserId(userDetails);
        return ResponseEntity.ok(ApiResponse.success("Feature flag toggled",
                adminService.toggleFeatureFlag(actorId, userDetails.getUsername(), key)));
    }

    public record RoleUpdateRequest(Set<String> roles) {}

    public record SettingUpdateRequest(String value) {}
}
