package com.platepilote.platepilote.admin.application.service;

import com.platepilote.platepilote.admin.domain.entity.AuditLog;
import com.platepilote.platepilote.admin.domain.entity.FeatureFlag;
import com.platepilote.platepilote.admin.domain.entity.SystemSetting;
import com.platepilote.platepilote.admin.domain.repository.AiUsageMetricRepository;
import com.platepilote.platepilote.admin.domain.repository.AuditLogRepository;
import com.platepilote.platepilote.admin.domain.repository.FeatureFlagRepository;
import com.platepilote.platepilote.admin.domain.repository.SystemSettingRepository;
import com.platepilote.platepilote.authentication.domain.entity.OurUser;
import com.platepilote.platepilote.authentication.domain.entity.Role;
import com.platepilote.platepilote.authentication.domain.repository.RoleRepository;
import com.platepilote.platepilote.authentication.domain.repository.UserRepository;
import com.platepilote.platepilote.billing.domain.entity.BillingEvent;
import com.platepilote.platepilote.billing.domain.repository.BillingEventRepository;
import com.platepilote.platepilote.common.dto.PagedResponse;
import com.platepilote.platepilote.common.kernel.BusinessRuleViolationException;
import com.platepilote.platepilote.common.kernel.ResourceNotFoundException;
import com.platepilote.platepilote.imports.domain.entity.ImportJob;
import com.platepilote.platepilote.imports.domain.repository.ImportJobRepository;
import com.platepilote.platepilote.ingredients.domain.entity.Ingredient;
import com.platepilote.platepilote.ingredients.domain.repository.IngredientRepository;
import com.platepilote.platepilote.recipes.domain.entity.Recipe;
import com.platepilote.platepilote.recipes.domain.repository.RecipeRepository;
import com.platepilote.platepilote.recommendation.domain.repository.RecommendationEventRepository;
import com.platepilote.platepilote.subscription.domain.entity.Subscription;
import com.platepilote.platepilote.subscription.domain.repository.SubscriptionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional
public class AdminService {

    private final UserRepository userRepository;
    private final RoleRepository roleRepository;
    private final SubscriptionRepository subscriptionRepository;
    private final RecipeRepository recipeRepository;
    private final IngredientRepository ingredientRepository;
    private final ImportJobRepository importJobRepository;
    private final AuditLogRepository auditLogRepository;
    private final FeatureFlagRepository featureFlagRepository;
    private final SystemSettingRepository systemSettingRepository;
    private final RecommendationEventRepository recommendationEventRepository;
    private final AiUsageMetricRepository aiUsageMetricRepository;
    private final BillingEventRepository billingEventRepository;
    private final AuditLogService auditLogService;

    @Transactional(readOnly = true)
    public OverviewResponse overview() {
        Instant monthStart = Instant.now().minus(30, ChronoUnit.DAYS);
        long totalUsers = userRepository.count();
        long premiumUsers = userRepository.findAll().stream()
                .filter(user -> user.getRoles().stream().anyMatch(role -> "ROLE_PREMIUM_USER".equals(role.getName())))
                .count();
        long recipes = recipeRepository.count();
        long ingredients = ingredientRepository.count();
        long imports = importJobRepository.count();
        long recommendationRequests = recommendationEventRepository.countByCreatedAtAfter(monthStart);
        long aiRequests = aiUsageMetricRepository.countByCreatedAtAfter(monthStart);
        double conversionRate = totalUsers == 0 ? 0 : (premiumUsers * 100.0) / totalUsers;
        return new OverviewResponse(totalUsers, premiumUsers, round(conversionRate), recipes, ingredients,
                imports, recommendationRequests, aiRequests, auditLogRepository.countByCreatedAtAfter(monthStart));
    }

    @Transactional(readOnly = true)
    public PagedResponse<UserAdminResponse> users(Pageable pageable) {
        return users(pageable, null);
    }

    @Transactional(readOnly = true)
    public PagedResponse<UserAdminResponse> users(Pageable pageable, String query) {
        Page<OurUser> page = query == null || query.isBlank()
                ? userRepository.findAll(pageable)
                : userRepository.search(query, pageable);
        List<UserAdminResponse> content = page.getContent().stream()
                .map(this::toUserResponse)
                .collect(Collectors.toList());
        return PagedResponse.of(content, page.getNumber(), page.getSize(), page.getTotalElements());
    }

    @Transactional(readOnly = true)
    public UserAdminResponse user(UUID id) {
        return userRepository.findById(id)
                .map(this::toUserResponse)
                .orElseThrow(() -> new ResourceNotFoundException("User", "id", id.toString()));
    }

    public UserAdminResponse suspendUser(UUID actorId, String actorEmail, UUID userId, boolean suspended) {
        OurUser user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User", "id", userId.toString()));
        user.setEnabled(!suspended);
        OurUser saved = userRepository.save(user);
        auditLogService.log(actorId, actorEmail, suspended ? "USER_SUSPENDED" : "USER_REACTIVATED",
                "User", userId.toString(), Map.of("enabled", saved.getEnabled()));
        return toUserResponse(saved);
    }

    public UserAdminResponse updateRoles(UUID actorId, String actorEmail, UUID userId, Set<String> roleNames) {
        OurUser user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User", "id", userId.toString()));
        Set<Role> roles = roleNames.stream()
                .map(this::findRole)
                .collect(Collectors.toSet());
        if (roles.isEmpty()) {
            throw new BusinessRuleViolationException("A user must have at least one role");
        }
        user.setRoles(roles);
        OurUser saved = userRepository.save(user);
        auditLogService.log(actorId, actorEmail, "USER_ROLES_UPDATED", "User", userId.toString(),
                Map.of("roles", roleNames));
        return toUserResponse(saved);
    }

    @Transactional(readOnly = true)
    public PagedResponse<ImportJobResponse> imports(Pageable pageable) {
        Page<ImportJob> page = importJobRepository.findByDeletedAtIsNullOrderByCreatedAtDesc(pageable);
        return PagedResponse.of(page.getContent().stream().map(this::toImportResponse).toList(),
                page.getNumber(), page.getSize(), page.getTotalElements());
    }

    @Transactional(readOnly = true)
    public ImportJobResponse importJob(UUID id) {
        return importJobRepository.findById(id)
                .map(this::toImportResponse)
                .orElseThrow(() -> new ResourceNotFoundException("ImportJob", "id", id.toString()));
    }

    public ImportJob retryImport(UUID actorId, String actorEmail, UUID id) {
        ImportJob job = importJobRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("ImportJob", "id", id.toString()));
        job.setStatus("RETRY_REQUESTED");
        ImportJob saved = importJobRepository.save(job);
        auditLogService.log(actorId, actorEmail, "IMPORT_RETRY_REQUESTED", "ImportJob", id.toString(), Map.of("source", job.getSource()));
        return saved;
    }

    @Transactional(readOnly = true)
    public PagedResponse<RecipeAdminResponse> recipes(Pageable pageable, String query) {
        Page<Recipe> page = query == null || query.isBlank()
                ? recipeRepository.findAll(pageable)
                : recipeRepository.searchPublicRecipes(query, pageable);
        return PagedResponse.of(page.getContent().stream().map(this::toRecipeResponse).toList(),
                page.getNumber(), page.getSize(), page.getTotalElements());
    }

    @Transactional(readOnly = true)
    public PagedResponse<IngredientAdminResponse> ingredients(Pageable pageable, String query) {
        Page<Ingredient> page = query == null || query.isBlank()
                ? ingredientRepository.findAll(pageable)
                : ingredientRepository.search(query, pageable);
        return PagedResponse.of(page.getContent().stream().map(this::toIngredientResponse).toList(),
                page.getNumber(), page.getSize(), page.getTotalElements());
    }

    @Transactional(readOnly = true)
    public PagedResponse<SubscriptionAdminResponse> subscriptions(Pageable pageable) {
        Page<Subscription> page = subscriptionRepository.findAll(pageable);
        return PagedResponse.of(page.getContent().stream().map(this::toSubscriptionResponse).toList(),
                page.getNumber(), page.getSize(), page.getTotalElements());
    }

    @Transactional(readOnly = true)
    public PagedResponse<AuditLog> auditLogs(Pageable pageable) {
        Page<AuditLog> page = auditLogRepository.findAllByOrderByCreatedAtDesc(pageable);
        return PagedResponse.of(page.getContent(), page.getNumber(), page.getSize(), page.getTotalElements());
    }

    @Transactional(readOnly = true)
    public List<FeatureFlag> featureFlags() {
        return featureFlagRepository.findAll();
    }

    @Transactional(readOnly = true)
    public List<SystemSetting> systemSettings() {
        return systemSettingRepository.findAll();
    }

    public SystemSetting updateSystemSetting(UUID actorId, String actorEmail, String key, String value) {
        SystemSetting setting = systemSettingRepository.findBySettingKey(key)
                .orElseGet(() -> SystemSetting.builder().settingKey(key).description("Admin configured setting").build());
        setting.setSettingValue(value);
        SystemSetting saved = systemSettingRepository.save(setting);
        auditLogService.log(actorId, actorEmail, "SYSTEM_SETTING_UPDATED", "SystemSetting", key, Map.of("value", value));
        return saved;
    }

    @Transactional(readOnly = true)
    public RecommendationAnalyticsResponse recommendationAnalytics() {
        Instant monthStart = Instant.now().minus(30, ChronoUnit.DAYS);
        long requests = recommendationEventRepository.countByCreatedAtAfter(monthStart);
        long quotaBlocks = recommendationEventRepository.countByCreatedAtAfterAndQuotaLimitedTrue(monthStart);
        long emptyResults = recommendationEventRepository.countByCreatedAtAfterAndResultCount(monthStart, 0);
        return new RecommendationAnalyticsResponse(requests, quotaBlocks, emptyResults);
    }

    @Transactional(readOnly = true)
    public PagedResponse<BillingEventResponse> billingEvents(Pageable pageable) {
        Page<BillingEvent> page = billingEventRepository.findAllByOrderByCreatedAtDesc(pageable);
        return PagedResponse.of(page.getContent().stream().map(this::toBillingEventResponse).toList(),
                page.getNumber(), page.getSize(), page.getTotalElements());
    }

    public FeatureFlag toggleFeatureFlag(UUID actorId, String actorEmail, String key) {
        FeatureFlag flag = featureFlagRepository.findByFlagKey(key)
                .orElseThrow(() -> new ResourceNotFoundException("FeatureFlag", "key", key));
        flag.setEnabled(!Boolean.TRUE.equals(flag.getEnabled()));
        FeatureFlag saved = featureFlagRepository.save(flag);
        auditLogService.log(actorId, actorEmail, "FEATURE_FLAG_TOGGLED", "FeatureFlag", key,
                Map.of("enabled", saved.getEnabled()));
        return saved;
    }

    private Role findRole(String roleName) {
        String normalized = roleName.startsWith("ROLE_") ? roleName : "ROLE_" + roleName;
        return roleRepository.findByName(normalized)
                .orElseThrow(() -> new ResourceNotFoundException("Role", "name", normalized));
    }

    private UserAdminResponse toUserResponse(OurUser user) {
        Set<String> roles = user.getRoles().stream()
                .map(Role::getName)
                .collect(Collectors.toSet());
        Subscription subscription = subscriptionRepository.findByUserId(user.getId()).orElse(null);
        return new UserAdminResponse(user.getId(), user.getEmail(), user.getFirstName(), user.getLastName(),
                user.getEnabled(), user.getEmailVerified(), roles,
                subscription == null ? "NONE" : subscription.getPlanType(),
                subscription == null ? "NONE" : subscription.getStatus(),
                user.getCreatedAt(), user.getUpdatedAt());
    }

    private double round(double value) {
        return Math.round(value * 100.0) / 100.0;
    }

    private RecipeAdminResponse toRecipeResponse(Recipe recipe) {
        return new RecipeAdminResponse(recipe.getId(), recipe.getName(), recipe.getCuisineType(), recipe.getMealType(),
                recipe.getIsPublic(), recipe.getEnabled(), recipe.getVerified(), recipe.getVerificationStatus(),
                recipe.getConfidenceScore(), recipe.getCreatedAt(), recipe.getUpdatedAt());
    }

    private IngredientAdminResponse toIngredientResponse(Ingredient ingredient) {
        return new IngredientAdminResponse(ingredient.getId(), ingredient.getCanonicalName(), ingredient.getSlug(),
                ingredient.getCategory(), ingredient.getDefaultUnit(), ingredient.getCreatedAt(),
                ingredient.getUpdatedAt());
    }

    private SubscriptionAdminResponse toSubscriptionResponse(Subscription subscription) {
        return new SubscriptionAdminResponse(subscription.getId(), subscription.getUserId(), subscription.getPlanType(),
                subscription.getStatus(), subscription.getProvider(), subscription.getProviderSubscriptionId(),
                subscription.getExpiresAt(), subscription.getLastVerifiedAt(), subscription.getCancelAtPeriodEnd(),
                subscription.getCreatedAt(), subscription.getUpdatedAt());
    }

    private ImportJobResponse toImportResponse(ImportJob job) {
        return new ImportJobResponse(job.getId(), job.getSource(), job.getStatus(), job.getTotalRecords(),
                job.getSuccessfulRecords(), job.getFailedRecords(), job.getErrorMessage(), job.getStartedAt(),
                job.getCompletedAt(), job.getCreatedAt());
    }

    private BillingEventResponse toBillingEventResponse(BillingEvent event) {
        return new BillingEventResponse(event.getId(), event.getProvider(), event.getEventId(), event.getEventType(),
                event.getProcessed(), event.getErrorMessage(), event.getCreatedAt(), event.getProcessedAt());
    }

    public record OverviewResponse(
            long totalUsers,
            long premiumSubscribers,
            double premiumConversionRate,
            long totalRecipes,
            long totalIngredients,
            long totalImports,
            long recommendationRequestsLast30Days,
            long aiRequestsLast30Days,
            long auditEventsLast30Days
    ) {}

    public record UserAdminResponse(
            UUID id,
            String email,
            String firstName,
            String lastName,
            Boolean enabled,
            Boolean emailVerified,
            Set<String> roles,
            String planType,
            String subscriptionStatus,
            Instant createdAt,
            Instant updatedAt
    ) {}

    public record RecipeAdminResponse(UUID id, String name, String cuisineType, String mealType,
                                      Boolean isPublic, Boolean enabled, Boolean verified,
                                      String verificationStatus, Double confidenceScore,
                                      Instant createdAt, Instant updatedAt) {}

    public record IngredientAdminResponse(UUID id, String canonicalName, String slug, String category,
                                          String defaultUnit, Instant createdAt, Instant updatedAt) {}

    public record SubscriptionAdminResponse(UUID id, UUID userId, String planType, String status,
                                            String provider, String providerSubscriptionId,
                                            Instant expiresAt, Instant lastVerifiedAt,
                                            Boolean cancelAtPeriodEnd, Instant createdAt, Instant updatedAt) {}

    public record ImportJobResponse(UUID id, String source, String status, Integer totalRecords,
                                    Integer successfulRecords, Integer failedRecords, String errorMessage,
                                    Instant startedAt, Instant completedAt, Instant createdAt) {}

    public record RecommendationAnalyticsResponse(long requestsLast30Days, long quotaBlocksLast30Days,
                                                  long emptyResultRequestsLast30Days) {}

    public record BillingEventResponse(UUID id, String provider, String eventId, String eventType,
                                       Boolean processed, String errorMessage,
                                       Instant createdAt, Instant processedAt) {}
}
