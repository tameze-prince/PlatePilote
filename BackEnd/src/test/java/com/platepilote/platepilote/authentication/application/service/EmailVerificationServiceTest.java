package com.platepilote.platepilote.authentication.application.service;

import com.platepilote.platepilote.authentication.application.config.EmailVerificationProperties;
import com.platepilote.platepilote.authentication.domain.entity.EmailVerificationToken;
import com.platepilote.platepilote.authentication.domain.entity.OurUser;
import com.platepilote.platepilote.authentication.domain.repository.EmailVerificationTokenRepository;
import com.platepilote.platepilote.authentication.domain.repository.UserRepository;
import com.platepilote.platepilote.common.kernel.BusinessRuleViolationException;
import jakarta.mail.internet.MimeMessage;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.mockito.junit.jupiter.MockitoSettings;
import org.mockito.quality.Strictness;
import org.springframework.mail.MailSendException;
import org.springframework.mail.javamail.JavaMailSender;
import org.thymeleaf.TemplateEngine;
import org.thymeleaf.context.Context;

import java.time.Instant;
import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
@MockitoSettings(strictness = Strictness.LENIENT)
class EmailVerificationServiceTest {

    @Mock private EmailVerificationTokenRepository tokenRepository;
    @Mock private UserRepository userRepository;
    @Mock private JavaMailSender mailSender;
    @Mock private TemplateEngine templateEngine;
    @Mock private MimeMessage mimeMessage;

    private EmailVerificationProperties properties;
    private EmailVerificationService service;

    @BeforeEach
    void setUp() {
        properties = new EmailVerificationProperties();
        properties.setFrom("PlatePilote <no-reply@test.platepilote.com>");
        properties.setFrontendUrl("https://app.platepilote.com/verify-email");
        properties.setExpirationHours(24);
        properties.setFailOnSendError(false);
        service = new EmailVerificationService(tokenRepository, userRepository, mailSender, templateEngine, properties);
    }

    private void stubTemplateEngine(String output) {
        when(templateEngine.process(eq("email/email-verification"), any(Context.class))).thenReturn(output);
        when(templateEngine.process(eq("email/password-reset"), any(Context.class))).thenReturn(output);
    }

    @Test
    void sendVerificationEmailStoresTokenAndSendsMail() {
        OurUser user = user(false);
        when(tokenRepository.save(any(EmailVerificationToken.class))).thenAnswer(invocation -> invocation.getArgument(0));
        when(mailSender.createMimeMessage()).thenReturn(mimeMessage);
        stubTemplateEngine("<html>Hello</html>");

        service.sendVerificationEmail(user);

        verify(tokenRepository).markActiveTokensUsedForUser(user.getId());
        ArgumentCaptor<EmailVerificationToken> tokenCaptor = ArgumentCaptor.forClass(EmailVerificationToken.class);
        verify(tokenRepository).save(tokenCaptor.capture());
        assertThat(tokenCaptor.getValue().getUserId()).isEqualTo(user.getId());
        assertThat(tokenCaptor.getValue().getExpiresAt()).isAfter(Instant.now().plusSeconds(23 * 3600));

        verify(mailSender).createMimeMessage();
        verify(mailSender).send(any(MimeMessage.class));
    }

    @Test
    void sendVerificationEmailDoesNotBlockRegistrationWhenMailFailsByDefault() {
        OurUser user = user(false);
        when(tokenRepository.save(any(EmailVerificationToken.class))).thenAnswer(invocation -> invocation.getArgument(0));
        when(mailSender.createMimeMessage()).thenReturn(mimeMessage);
        doThrow(new MailSendException("smtp rejected sender")).when(mailSender).send(any(MimeMessage.class));
        stubTemplateEngine("<html>Hello</html>");

        // Should NOT throw — failOnSendError is false
        service.sendVerificationEmail(user);

        verify(tokenRepository).save(any(EmailVerificationToken.class));
    }

    @Test
    void sendVerificationEmailCanFailFastInStrictMode() {
        EmailVerificationProperties strictProperties = new EmailVerificationProperties();
        strictProperties.setFrom("PlatePilote <no-reply@test.platepilote.com>");
        strictProperties.setFrontendUrl("https://app.platepilote.com/verify-email");
        strictProperties.setExpirationHours(24);
        strictProperties.setFailOnSendError(true);
        service = new EmailVerificationService(tokenRepository, userRepository, mailSender, templateEngine, strictProperties);

        OurUser user = user(false);
        when(tokenRepository.save(any(EmailVerificationToken.class))).thenAnswer(invocation -> invocation.getArgument(0));
        when(mailSender.createMimeMessage()).thenReturn(mimeMessage);
        doThrow(new MailSendException("smtp rejected sender")).when(mailSender).send(any(MimeMessage.class));
        stubTemplateEngine("<html>Hello</html>");

        assertThatThrownBy(() -> service.sendVerificationEmail(user))
                .isInstanceOf(BusinessRuleViolationException.class)
                .hasMessageContaining("Unable to send email");
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