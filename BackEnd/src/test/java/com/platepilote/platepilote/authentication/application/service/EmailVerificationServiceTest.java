package com.platepilote.platepilote.authentication.application.service;

import com.platepilote.platepilote.authentication.application.config.EmailVerificationProperties;
import com.platepilote.platepilote.authentication.domain.entity.EmailVerificationToken;
import com.platepilote.platepilote.authentication.domain.entity.OurUser;
import com.platepilote.platepilote.authentication.domain.repository.EmailVerificationTokenRepository;
import com.platepilote.platepilote.authentication.domain.repository.UserRepository;
import com.platepilote.platepilote.common.kernel.BusinessRuleViolationException;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;

import java.time.Instant;
import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class EmailVerificationServiceTest {

    @Mock private EmailVerificationTokenRepository tokenRepository;
    @Mock private UserRepository userRepository;
    @Mock private JavaMailSender mailSender;

    private EmailVerificationService service;

    @BeforeEach
    void setUp() {
        EmailVerificationProperties properties = new EmailVerificationProperties();
        properties.setFrom("PlatePilote <no-reply@test.platepilote.com>");
        properties.setFrontendUrl("https://app.platepilote.com/verify-email");
        properties.setExpirationHours(24);
        service = new EmailVerificationService(tokenRepository, userRepository, mailSender, properties);
    }

    @Test
    void sendVerificationEmailStoresTokenAndSendsMail() {
        OurUser user = user(false);
        when(tokenRepository.save(any(EmailVerificationToken.class))).thenAnswer(invocation -> invocation.getArgument(0));

        service.sendVerificationEmail(user);

        verify(tokenRepository).markActiveTokensUsedForUser(user.getId());
        ArgumentCaptor<EmailVerificationToken> tokenCaptor = ArgumentCaptor.forClass(EmailVerificationToken.class);
        verify(tokenRepository).save(tokenCaptor.capture());
        assertThat(tokenCaptor.getValue().getUserId()).isEqualTo(user.getId());
        assertThat(tokenCaptor.getValue().getExpiresAt()).isAfter(Instant.now().plusSeconds(23 * 3600));

        ArgumentCaptor<SimpleMailMessage> messageCaptor = ArgumentCaptor.forClass(SimpleMailMessage.class);
        verify(mailSender).send(messageCaptor.capture());
        assertThat(messageCaptor.getValue().getTo()).containsExactly("user@example.com");
        assertThat(messageCaptor.getValue().getText()).contains("https://app.platepilote.com/verify-email?token=");
    }

    @Test
    void verifyEmailMarksUserAndTokenVerified() {
        UUID userId = UUID.randomUUID();
        OurUser user = user(false);
        user.setId(userId);
        EmailVerificationToken token = EmailVerificationToken.builder()
                .userId(userId)
                .token("token")
                .expiresAt(Instant.now().plusSeconds(3600))
                .used(false)
                .build();
        when(tokenRepository.findByToken("token")).thenReturn(Optional.of(token));
        when(userRepository.findById(userId)).thenReturn(Optional.of(user));

        service.verifyEmail("token");

        assertThat(user.getEmailVerified()).isTrue();
        assertThat(token.getUsed()).isTrue();
        verify(userRepository).save(user);
        verify(tokenRepository).save(token);
    }

    @Test
    void verifyEmailRejectsExpiredToken() {
        EmailVerificationToken token = EmailVerificationToken.builder()
                .userId(UUID.randomUUID())
                .token("token")
                .expiresAt(Instant.now().minusSeconds(1))
                .used(false)
                .build();
        when(tokenRepository.findByToken("token")).thenReturn(Optional.of(token));

        assertThatThrownBy(() -> service.verifyEmail("token"))
                .isInstanceOf(BusinessRuleViolationException.class)
                .hasMessageContaining("expired");

        verify(userRepository, never()).save(any());
    }

    private static OurUser user(boolean emailVerified) {
        OurUser user = OurUser.builder()
                .email("user@example.com")
                .firstName("User")
                .lastName("One")
                .provider("local")
                .enabled(true)
                .emailVerified(emailVerified)
                .build();
        user.setId(UUID.randomUUID());
        return user;
    }
}
