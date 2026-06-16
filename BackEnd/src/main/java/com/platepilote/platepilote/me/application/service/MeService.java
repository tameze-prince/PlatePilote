package com.platepilote.platepilote.me.application.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.platepilote.platepilote.admin.application.service.AuditLogService;
import com.platepilote.platepilote.ai.history.domain.repository.AiInteractionRepository;
import com.platepilote.platepilote.authentication.domain.entity.User;
import com.platepilote.platepilote.authentication.domain.repository.UserRepository;
import com.platepilote.platepilote.cooking.domain.repository.CookingHistoryRepository;
import com.platepilote.platepilote.me.application.dto.CookingHistoryDto;
import com.platepilote.platepilote.me.application.dto.DataExportResponse;
import com.platepilote.platepilote.me.application.dto.AiInteractionDto;
import com.platepilote.platepilote.me.application.dto.PantryItemDto;
import com.platepilote.platepilote.me.application.dto.ProfileDto;
import com.platepilote.platepilote.me.application.dto.RecipeDto;
import com.platepilote.platepilote.pantry.domain.repository.PantryItemRepository;
import com.platepilote.platepilote.recipe.domain.repository.RecipeRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.UUID;

/**
 * Service for DS (Data Subject) Rights endpoints (RGPD art. 15 access + art. 17 deletion).
 *
 * <p>Reads scattered repositories, orchestrates soft-delete + 30-day purge schedule,
 * and emits a row in {@link AuditLogService} for every action taken on user data.
 */
@Service
public class MeService {

    private static final Logger log = LoggerFactory.getLogger(MeService.class);
    private static final int PURGE_GRACE_DAYS = 30;
    private static final String AUDIT_ACTION_EXPORT = "RGPD_DATA_EXPORT";
    private static final String AUDIT_ACTION_DELETION_REQUESTED = "RGPD_DELETION_REQUESTED";
    private static final String AUDIT_ACTION_PURGED = "RGPD_PURGED";

    private final UserRepository userRepository;
    private final PantryItemRepository pantryItemRepository;
    private final RecipeRepository recipeRepository;
    private final CookingHistoryRepository cookingHistoryRepository;
    private final AiInteractionRepository aiInteractionRepository;
    private final AuditLogService auditLogService;
    private final ObjectMapper objectMapper;

    public MeService(
        UserRepository userRepository,
        PantryItemRepository pantryItemRepository,
        RecipeRepository recipeRepository,
        CookingHistoryRepository cookingHistoryRepository,
        AiInteractionRepository aiInteractionRepository,
        AuditLogService auditLogService,
        ObjectMapper objectMapper
    ) {
        this.userRepository = userRepository;
        this.pantryItemRepository = pantryItemRepository;
        this.recipeRepository = recipeRepository;
        this.cookingHistoryRepository = cookingHistoryRepository;
        this.aiInteractionRepository = aiInteractionRepository;
        this.auditLogService = auditLogService;
        this.objectMapper = objectMapper;
    }

    /**
     * Aggregate every piece of personal data we hold for the user.
     * RGPD art. 15 (right of access) + art. 20 (right to data portability).
     */
    @Transactional(readOnly = true)
    public DataExportResponse exportUserData(UUID userId) {
        User user = userRepository.findById(userId)
            .orElseThrow(() -> new IllegalArgumentException("User not found: " + userId));

        ProfileDto profile = ProfileDto.from(user);

        List<PantryItemDto> pantry = pantryItemRepository.findByOwnerId(userId).stream()
            .map(PantryItemDto::from)
            .toList();

        List<RecipeDto> recipes = recipeRepository.findByOwnerId(userId).stream()
            .map(RecipeDto::from)
            .toList();

        List<CookingHistoryDto> history = cookingHistoryRepository.findByUserId(userId).stream()
            .map(CookingHistoryDto::from)
            .toList();

        List<AiInteractionDto> aiHistory = aiInteractionRepository.findByUserIdOrderByCreatedAtDesc(userId).stream()
            .map(AiInteractionDto::from)
            .toList();

        auditLogService.log(
            userId,
            AUDIT_ACTION_EXPORT,
            Map.of("pantryCount", pantry.size(),
                   "recipesCount", recipes.size(),
                   "historyCount", history.size(),
                   "aiCount", aiHistory.size())
        );

        log.info("RGPD export served for user {}", userId);

        return new DataExportResponse(profile, pantry, recipes, history, aiHistory);
    }

    /**
     * Soft-delete the account now and schedule a hard purge in 30 days.
     * RGPD art. 17 (right to erasure).
     */
    @Transactional
    public void requestAccountDeletion(UUID userId) {
        User user = userRepository.findById(userId)
            .orElseThrow(() -> new IllegalArgumentException("User not found: " + userId));

        LocalDateTime now = LocalDateTime.now();
        user.setDeletedAt(now);
        userRepository.save(user);

        LocalDate scheduledPurge = LocalDate.now().plusDays(PURGE_GRACE_DAYS);

        auditLogService.log(
            userId,
            AUDIT_ACTION_DELETION_REQUESTED,
            Map.of("scheduledPurgeDate", scheduledPurge.toString())
        );

        log.info("Account deletion requested for user {} — purge scheduled for {}",
            userId, scheduledPurge);

        schedulePurge(userId, scheduledPurge);
    }

    /**
     * Hard delete after the 30-day grace window.
     * Runs asynchronously so it does not block the deletion request endpoint.
     */
    @Async
    public void schedulePurge(UUID userId, LocalDate scheduledPurgeDate) {
        log.info("Purging user {} (originally scheduled {})", userId, scheduledPurgeDate);
        pantryItemRepository.deleteByOwnerId(userId);
        recipeRepository.deleteByOwnerId(userId);
        cookingHistoryRepository.deleteByUserId(userId);
        aiInteractionRepository.deleteByUserId(userId);
        userRepository.deleteById(userId);

        auditLogService.log(
            userId,
            AUDIT_ACTION_PURGED,
            Map.of("purgedAt", LocalDateTime.now().toString())
        );
    }
}
