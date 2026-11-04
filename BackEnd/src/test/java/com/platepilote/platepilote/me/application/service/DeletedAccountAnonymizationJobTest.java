package com.platepilote.platepilote.me.application.service;

import com.platepilote.platepilote.authentication.domain.entity.OurUser;
import com.platepilote.platepilote.authentication.domain.repository.UserRepository;
import org.junit.jupiter.api.Test;
import org.springframework.jdbc.core.JdbcTemplate;
import org.mockito.InOrder;

import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.List;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.inOrder;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

class DeletedAccountAnonymizationJobTest {

    @Test
    void anonymizesExpiredAccountAndRemovesDirectIdentifiers() {
        UserRepository userRepository = mock(UserRepository.class);
        JdbcTemplate jdbcTemplate = mock(JdbcTemplate.class);
        DeletedAccountAnonymizationJob job =
                new DeletedAccountAnonymizationJob(userRepository, jdbcTemplate);

        UUID userId = UUID.randomUUID();
        OurUser user = OurUser.builder()
                .email("person@example.com")
                .passwordHash("$2a$10$old-hash")
                .firstName("Person")
                .lastName("Example")
                .phone("+000000000")
                .avatarUrl("https://cdn.example.com/avatar.png")
                .provider("google")
                .providerId("oauth-user-id")
                .emailVerified(true)
                .enabled(false)
                .analyticsOptOut(false)
                .processingRestricted(false)
                .build();
        user.setId(userId);
        user.setDeletedAt(Instant.now().minus(31, ChronoUnit.DAYS));

        when(userRepository.findAllByEnabledFalseAndDeletedAtBeforeAndAnonymizedAtIsNull(any()))
                .thenReturn(List.of(user));

        job.anonymizeExpiredAccounts();

        assertThat(user.getEmail()).isEqualTo("deleted+" + userId + "@accounts.platepilote.invalid");
        assertThat(user.getFirstName()).isEqualTo("Deleted");
        assertThat(user.getLastName()).isEqualTo("Account");
        assertThat(user.getPasswordHash()).isNull();
        assertThat(user.getPhone()).isNull();
        assertThat(user.getAvatarUrl()).isNull();
        assertThat(user.getProviderId()).isNull();
        assertThat(user.getEmailVerified()).isFalse();
        assertThat(user.getEnabled()).isFalse();
        assertThat(user.getAnalyticsOptOut()).isTrue();
        assertThat(user.getProcessingRestricted()).isTrue();
        assertThat(user.getAnonymizedAt()).isNotNull();
        assertThat(user.getRoles()).isEmpty();

        InOrder deletionOrder = inOrder(jdbcTemplate);
        deletionOrder.verify(jdbcTemplate).update("DELETE FROM meal_plans WHERE user_id = ?", userId);
        deletionOrder.verify(jdbcTemplate).update(
                "DELETE FROM meal_plan_entries " +
                        "WHERE recipe_id IN (SELECT id FROM recipes WHERE user_id = ? AND is_public = FALSE)",
                userId
        );
        deletionOrder.verify(jdbcTemplate).update(
                "DELETE FROM user_interactions " +
                        "WHERE recipe_id IN (SELECT id FROM recipes WHERE user_id = ? AND is_public = FALSE)",
                userId
        );
        deletionOrder.verify(jdbcTemplate).update(
                "DELETE FROM recipes WHERE user_id = ? AND is_public = FALSE",
                userId
        );

        verify(jdbcTemplate).update(
                "UPDATE billing_customers SET email = NULL, provider_customer_id = CONCAT('deleted_', user_id) WHERE user_id = ?",
                userId
        );
        verify(jdbcTemplate).update(
                "UPDATE subscriptions SET provider_subscription_id = NULL, purchase_token = NULL, original_transaction_id = NULL WHERE user_id = ?",
                userId
        );
        verify(userRepository).save(user);
    }
}
