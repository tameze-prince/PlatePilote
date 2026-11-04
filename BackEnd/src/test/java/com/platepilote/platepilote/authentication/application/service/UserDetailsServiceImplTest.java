package com.platepilote.platepilote.authentication.application.service;

import com.platepilote.platepilote.authentication.domain.entity.OurUser;
import com.platepilote.platepilote.authentication.domain.repository.UserRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.core.userdetails.UserDetails;

import java.util.Optional;
import java.util.Set;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class UserDetailsServiceImplTest {

    @Mock
    private UserRepository userRepository;

    @Test
    void disabledAccountProducesDisabledUserDetails() {
        OurUser user = user("disabled@example.com");
        user.setEnabled(false);
        when(userRepository.findByEmail(user.getEmail())).thenReturn(Optional.of(user));

        UserDetails details = new UserDetailsServiceImpl(userRepository).loadUserByUsername(user.getEmail());

        assertThat(details.isEnabled()).isFalse();
    }

    @Test
    void softDeletedAccountProducesDisabledUserDetails() {
        OurUser user = user("deleted@example.com");
        user.softDelete();
        when(userRepository.findByEmail(user.getEmail())).thenReturn(Optional.of(user));

        UserDetails details = new UserDetailsServiceImpl(userRepository).loadUserByUsername(user.getEmail());

        assertThat(details.isEnabled()).isFalse();
    }

    private OurUser user(String email) {
        return OurUser.builder()
                .email(email)
                .passwordHash("encoded")
                .enabled(true)
                .roles(Set.of())
                .build();
    }
}
