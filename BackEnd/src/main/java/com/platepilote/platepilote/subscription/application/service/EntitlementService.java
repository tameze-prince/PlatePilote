package com.platepilote.platepilote.subscription.application.service;

import com.platepilote.platepilote.authentication.domain.entity.OurUser;
import com.platepilote.platepilote.authentication.domain.entity.Role;
import com.platepilote.platepilote.authentication.domain.repository.RoleRepository;
import com.platepilote.platepilote.authentication.domain.repository.UserRepository;
import com.platepilote.platepilote.common.kernel.BusinessRuleViolationException;
import com.platepilote.platepilote.common.kernel.ResourceNotFoundException;
import com.platepilote.platepilote.subscription.domain.entity.UserEntitlement;
import com.platepilote.platepilote.subscription.domain.repository.UserEntitlementRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.UUID;

/**
 * Service métier pour la gestion des droits (entitlements) des utilisateurs.
 * Gère l'octroi et la révocation du statut premium.
 */
@Service
@RequiredArgsConstructor
@Transactional
public class EntitlementService {

    /** Clé d'entitlement pour le statut premium. */
    public static final String PREMIUM_ENTITLEMENT = "premium";

    private final UserEntitlementRepository userEntitlementRepository;
    private final UserRepository userRepository;
    private final RoleRepository roleRepository;

    /**
     * Vérifie si un utilisateur possède un entitlement actif et non expiré.
     *
     * @param userId         identifiant de l'utilisateur
     * @param entitlementKey clé de l'entitlement
     * @return true si l'entitlement est actif et valide
     */
    @Transactional(readOnly = true)
    public boolean hasActiveEntitlement(UUID userId, String entitlementKey) {
        return userEntitlementRepository.findByUserIdAndEntitlementKey(userId, entitlementKey)
                .filter(entitlement -> "ACTIVE".equals(entitlement.getStatus()))
                .filter(entitlement -> entitlement.getExpiresAt() == null
                        || entitlement.getExpiresAt().isAfter(Instant.now()))
                .isPresent();
    }

    /**
     * Accorde le statut premium à un utilisateur.
     *
     * @param userId    identifiant de l'utilisateur
     * @param source    source de l'octroi (STRIPE, INTERNAL, etc.)
     * @param expiresAt date d'expiration du premium
     * @return l'entitlement créé ou mis à jour
     */
    public UserEntitlement grantPremium(UUID userId, String source, Instant expiresAt) {
        UserEntitlement entitlement = userEntitlementRepository
                .findByUserIdAndEntitlementKey(userId, PREMIUM_ENTITLEMENT)
                .orElseGet(() -> UserEntitlement.builder()
                        .userId(userId)
                        .entitlementKey(PREMIUM_ENTITLEMENT)
                        .startsAt(Instant.now())
                        .build());

        entitlement.setSource(source == null || source.isBlank() ? "INTERNAL" : source);
        entitlement.setStatus("ACTIVE");
        entitlement.setExpiresAt(expiresAt);
        entitlement.setLastVerifiedAt(Instant.now());
        UserEntitlement saved = userEntitlementRepository.save(entitlement);
        syncPremiumRole(userId);
        return saved;
    }

    /**
     * Révoque le statut premium d'un utilisateur.
     *
     * @param userId identifiant de l'utilisateur
     */
    public void revokePremium(UUID userId) {
        userEntitlementRepository.findByUserIdAndEntitlementKey(userId, PREMIUM_ENTITLEMENT)
                .ifPresent(entitlement -> {
                    entitlement.setStatus("CANCELLED");
                    entitlement.setLastVerifiedAt(Instant.now());
                    userEntitlementRepository.save(entitlement);
                });
        syncPremiumRole(userId);
    }

    /**
     * Synchronise le rôle ROLE_PREMIUM_USER sur l'utilisateur
     * en fonction de son entitlement premium actif.
     *
     * @param userId identifiant de l'utilisateur
     */
    public void syncPremiumRole(UUID userId) {
        OurUser user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User", "id", userId.toString()));
        boolean premium = hasActiveEntitlement(userId, PREMIUM_ENTITLEMENT);

        if (premium) {
            Role role = roleRepository.findByName("ROLE_PREMIUM_USER")
                    .orElseThrow(() -> new BusinessRuleViolationException("Role not configured: ROLE_PREMIUM_USER"));
            user.getRoles().add(role);
        } else {
            user.getRoles().removeIf(role -> "ROLE_PREMIUM_USER".equals(role.getName()));
        }
        userRepository.save(user);
    }
}
