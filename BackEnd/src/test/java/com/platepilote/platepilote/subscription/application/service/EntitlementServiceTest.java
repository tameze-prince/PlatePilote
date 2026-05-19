package com.platepilote.platepilote.subscription.application.service;

import com.platepilote.platepilote.authentication.domain.entity.OurUser;
import com.platepilote.platepilote.authentication.domain.entity.Role;
import com.platepilote.platepilote.authentication.domain.repository.RoleRepository;
import com.platepilote.platepilote.authentication.domain.repository.UserRepository;
import com.platepilote.platepilote.subscription.domain.entity.UserEntitlement;
import com.platepilote.platepilote.subscription.domain.repository.UserEntitlementRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.Instant;
import java.util.HashSet;
import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class EntitlementServiceTest {

    @Mock
    private UserEntitlementRepository userEntitlementRepository;
    @Mock
    private UserRepository userRepository;
    @Mock
    private RoleRepository roleRepository;

    private EntitlementService entitlementService;

    @BeforeEach
    void setUp() {
        entitlementService = new EntitlementService(userEntitlementRepository, userRepository, roleRepository);
    }

    @Test
    void grantPremiumCreatesActiveEntitlementAndAddsPremiumRole() {
        UUID userId = UUID.randomUUID();
        Role premiumRole = new Role(UUID.randomUUID(), "ROLE_PREMIUM_USER", "Premium");
        OurUser user = OurUser.builder()
                .email("user@example.com")
                .firstName("User")
                .lastName("One")
                .roles(new HashSet<>())
                .build();
        Instant expiresAt = Instant.now().plusSeconds(3600);

        when(userEntitlementRepository.findByUserIdAndEntitlementKey(userId, EntitlementService.PREMIUM_ENTITLEMENT))
                .thenReturn(Optional.empty())
                .thenReturn(Optional.of(UserEntitlement.builder()
                        .userId(userId)
                        .entitlementKey(EntitlementService.PREMIUM_ENTITLEMENT)
                        .status("ACTIVE")
                        .expiresAt(expiresAt)
                        .build()));
        when(userEntitlementRepository.save(any(UserEntitlement.class)))
                .thenAnswer(invocation -> invocation.getArgument(0));
        when(userRepository.findById(userId)).thenReturn(Optional.of(user));
        when(roleRepository.findByName("ROLE_PREMIUM_USER")).thenReturn(Optional.of(premiumRole));

        UserEntitlement entitlement = entitlementService.grantPremium(userId, "INTERNAL", expiresAt);

        assertThat(entitlement.getStatus()).isEqualTo("ACTIVE");
        assertThat(entitlement.getExpiresAt()).isEqualTo(expiresAt);
        assertThat(user.getRoles()).extracting(Role::getName).containsExactly("ROLE_PREMIUM_USER");
        verify(userRepository).save(user);
    }

    @Test
    void revokePremiumCancelsEntitlementAndRemovesPremiumRole() {
        UUID userId = UUID.randomUUID();
        Role premiumRole = new Role(UUID.randomUUID(), "ROLE_PREMIUM_USER", "Premium");
        OurUser user = OurUser.builder()
                .email("user@example.com")
                .firstName("User")
                .lastName("One")
                .roles(new HashSet<>())
                .build();
        user.getRoles().add(premiumRole);
        UserEntitlement entitlement = UserEntitlement.builder()
                .userId(userId)
                .entitlementKey(EntitlementService.PREMIUM_ENTITLEMENT)
                .status("ACTIVE")
                .expiresAt(Instant.now().plusSeconds(3600))
                .build();

        when(userEntitlementRepository.findByUserIdAndEntitlementKey(userId, EntitlementService.PREMIUM_ENTITLEMENT))
                .thenReturn(Optional.of(entitlement))
                .thenReturn(Optional.of(entitlement));
        when(userRepository.findById(userId)).thenReturn(Optional.of(user));

        entitlementService.revokePremium(userId);

        assertThat(entitlement.getStatus()).isEqualTo("CANCELLED");
        assertThat(user.getRoles()).isEmpty();
        verify(userRepository).save(user);
    }
}
