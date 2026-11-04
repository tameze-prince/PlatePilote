package com.platepilote.platepilote.me.application.service;

import com.platepilote.platepilote.authentication.domain.entity.OurUser;
import com.platepilote.platepilote.authentication.domain.repository.UserRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.List;
import java.util.UUID;

/**
 * Anonymise les comptes supprimés après le délai de grâce.
 *
 * <p>Les données personnelles et données métier sont supprimées. Les traces
 * financières nécessaires à la comptabilité sont conservées avec un identifiant
 * de compte anonymisé ; les emails de facturation sont effacés.</p>
 */
@Service
public class DeletedAccountAnonymizationJob {

    private static final Logger log = LoggerFactory.getLogger(DeletedAccountAnonymizationJob.class);
    private static final int GRACE_PERIOD_DAYS = 30;

    private final UserRepository userRepository;
    private final JdbcTemplate jdbcTemplate;

    public DeletedAccountAnonymizationJob(
            UserRepository userRepository,
            JdbcTemplate jdbcTemplate
    ) {
        this.userRepository = userRepository;
        this.jdbcTemplate = jdbcTemplate;
    }

    @Scheduled(cron = "${app.me.account-anonymization-cron:0 0 3 * * *}", zone = "UTC")
    @Transactional
    public void anonymizeExpiredAccounts() {
        Instant cutoff = Instant.now().minus(GRACE_PERIOD_DAYS, ChronoUnit.DAYS);
        List<OurUser> expiredAccounts = userRepository.findAllByEnabledFalseAndDeletedAtBeforeAndAnonymizedAtIsNull(cutoff);

        for (OurUser user : expiredAccounts) {
            if (user.getDeletedAt() == null || user.getDeletedAt().isAfter(cutoff)) {
                continue;
            }
            anonymize(user);
        }

        if (!expiredAccounts.isEmpty()) {
            log.info("Anonymized {} expired account(s)", expiredAccounts.size());
        }
    }

    private void anonymize(OurUser user) {
        UUID userId = user.getId();

        // Remove personal preferences, profile, content, device and session data.
        deleteByUserId("refresh_tokens", userId);
        deleteByUserId("email_verification_tokens", userId);
        deleteByUserId("user_roles", userId);
        deleteByUserId("user_profiles", userId);
        deleteByUserId("dietary_preferences", userId);
        deleteByUserId("allergies", userId);
        deleteByUserId("cuisine_preferences", userId);
        jdbcTemplate.update(
                "DELETE FROM budget_tracking WHERE budget_id IN (SELECT id FROM budgets WHERE user_id = ?)",
                userId
        );
        deleteByUserId("budgets", userId);
        deleteByUserId("pantry_items", userId);
        deleteByUserId("recipe_ratings", userId);
        deleteByUserId("recipe_favorites", userId);

        // Remove the account's own references before deleting its meal plans.
        // meal_plan_entries has a non-cascading FK to recipes, so all remaining
        // references to this account's private recipes must be removed first.
        deleteByUserId("user_interactions", userId);
        deleteByUserId("meal_plans", userId);
        jdbcTemplate.update(
                "DELETE FROM meal_plan_entries " +
                        "WHERE recipe_id IN (SELECT id FROM recipes WHERE user_id = ? AND is_public = FALSE)",
                userId
        );
        jdbcTemplate.update(
                "DELETE FROM user_interactions " +
                        "WHERE recipe_id IN (SELECT id FROM recipes WHERE user_id = ? AND is_public = FALSE)",
                userId
        );
        jdbcTemplate.update(
                "DELETE FROM recipes WHERE user_id = ? AND is_public = FALSE",
                userId
        );
        jdbcTemplate.update(
                "UPDATE recipes SET user_id = NULL WHERE user_id = ? AND is_public = TRUE",
                userId
        );

        deleteByUserId("grocery_lists", userId);
        deleteByUserId("recommendation_cache", userId);
        deleteByUserId("notifications", userId);
        deleteByUserId("notification_preferences", userId);
        deleteByUserId("user_analytics", userId);
        deleteByUserId("user_entitlements", userId);
        deleteByUserId("swap_tracking", userId);
        deleteByUserId("device_registrations", userId);

        // Keep legally required financial records, but remove direct identifiers
        // and provider references that are no longer needed after cancellation.
        jdbcTemplate.update(
                "UPDATE billing_customers SET email = NULL, provider_customer_id = CONCAT('deleted_', user_id) WHERE user_id = ?",
                userId
        );
        jdbcTemplate.update(
                "UPDATE subscriptions SET provider_subscription_id = NULL, purchase_token = NULL, original_transaction_id = NULL WHERE user_id = ?",
                userId
        );
        jdbcTemplate.update(
                "UPDATE audit_logs SET actor_user_id = NULL, actor_email = NULL WHERE actor_user_id = ?",
                userId
        );
        jdbcTemplate.update("DELETE FROM admin_notes WHERE user_id = ?", userId);
        jdbcTemplate.update("UPDATE admin_notes SET admin_user_id = NULL WHERE admin_user_id = ?", userId);
        jdbcTemplate.update(
                "UPDATE ai_usage_metrics SET user_id = NULL, error_message = NULL WHERE user_id = ?",
                userId
        );

        user.setEmail("deleted+" + userId + "@accounts.platepilote.invalid");
        user.setFirstName("Deleted");
        user.setLastName("Account");
        user.setPasswordHash(null);
        user.setPhone(null);
        user.setAvatarUrl(null);
        user.setProvider("local");
        user.setProviderId(null);
        user.setEmailVerified(false);
        user.setEnabled(false);
        user.setAnalyticsOptOut(true);
        user.setProcessingRestricted(true);
        user.setAnonymizedAt(Instant.now());
        if (user.getRoles() != null) {
            user.getRoles().clear();
        }
        userRepository.save(user);
    }

    private void deleteByUserId(String tableName, UUID userId) {
        // Table names are fixed internal constants at call sites, never request input.
        jdbcTemplate.update("DELETE FROM " + tableName + " WHERE user_id = ?", userId);
    }
}
