package com.platepilote.platepilote.authentication.application.service;

import com.platepilote.platepilote.authentication.application.config.EmailVerificationProperties;
import com.platepilote.platepilote.authentication.domain.entity.EmailVerificationToken;
import com.platepilote.platepilote.authentication.domain.entity.OurUser;
import com.platepilote.platepilote.authentication.domain.repository.EmailVerificationTokenRepository;
import com.platepilote.platepilote.authentication.domain.repository.UserRepository;
import com.platepilote.platepilote.common.kernel.BusinessRuleViolationException;
import com.platepilote.platepilote.common.kernel.ResourceNotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.mail.MailException;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class EmailVerificationService {

    private final EmailVerificationTokenRepository tokenRepository;
    private final UserRepository userRepository;
    private final JavaMailSender mailSender;
    private final EmailVerificationProperties properties;

    @Transactional
    public void sendVerificationEmail(OurUser user) {
        if (Boolean.TRUE.equals(user.getEmailVerified())) {
            return;
        }
        tokenRepository.markActiveTokensUsedForUser(user.getId());
        String token = UUID.randomUUID().toString();
        tokenRepository.save(EmailVerificationToken.builder()
                .userId(user.getId())
                .token(token)
                .expiresAt(Instant.now().plus(properties.getExpirationHours(), ChronoUnit.HOURS))
                .used(false)
                .build());
        sendEmail(user, token);
    }

    @Transactional
    public void resendVerificationEmail(String email) {
        OurUser user = userRepository.findByEmail(email)
                .orElseThrow(() -> new ResourceNotFoundException("User", "email", email));
        sendVerificationEmail(user);
    }

    @Transactional
    public void verifyEmail(String token) {
        EmailVerificationToken verificationToken = tokenRepository.findByToken(token)
                .orElseThrow(() -> new BusinessRuleViolationException("Invalid email verification token"));
        if (Boolean.TRUE.equals(verificationToken.getUsed())) {
            throw new BusinessRuleViolationException("Email verification token has already been used");
        }
        if (verificationToken.getExpiresAt().isBefore(Instant.now())) {
            throw new BusinessRuleViolationException("Email verification token has expired");
        }
        OurUser user = userRepository.findById(verificationToken.getUserId())
                .orElseThrow(() -> new ResourceNotFoundException("User", "id", verificationToken.getUserId().toString()));
        user.setEmailVerified(true);
        verificationToken.setUsed(true);
        userRepository.save(user);
        tokenRepository.save(verificationToken);
    }

    private void sendEmail(OurUser user, String token) {
        String verificationLink = properties.getFrontendUrl() + "?token=" + token;
        SimpleMailMessage message = new SimpleMailMessage();
        message.setFrom(properties.getFrom());
        message.setTo(user.getEmail());
        message.setSubject("Verify your PlatePilote email");
        message.setText("""
                Hi %s,

                Welcome to PlatePilote. Verify your email address using this link:

                %s

                This link expires in %d hours.

                If you did not create a PlatePilote account, you can ignore this email.
                """.formatted(user.getFirstName(), verificationLink, properties.getExpirationHours()));
        try {
            mailSender.send(message);
        } catch (MailException ex) {
            throw new BusinessRuleViolationException("Unable to send verification email");
        }
    }
}
