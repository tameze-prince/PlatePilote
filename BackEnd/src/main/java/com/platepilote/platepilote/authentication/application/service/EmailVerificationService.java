package com.platepilote.platepilote.authentication.application.service;

import com.platepilote.platepilote.authentication.application.config.EmailVerificationProperties;
import com.platepilote.platepilote.authentication.domain.entity.EmailVerificationToken;
import com.platepilote.platepilote.authentication.domain.entity.OurUser;
import com.platepilote.platepilote.authentication.domain.repository.EmailVerificationTokenRepository;
import com.platepilote.platepilote.authentication.domain.repository.UserRepository;
import com.platepilote.platepilote.common.kernel.BusinessRuleViolationException;
import com.platepilote.platepilote.common.kernel.ResourceNotFoundException;
import jakarta.mail.MessagingException;
import jakarta.mail.internet.MimeMessage;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.mail.MailException;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.thymeleaf.TemplateEngine;
import org.thymeleaf.context.Context;

import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.UUID;

/**
 * Service de vérification des emails (confirmation d'inscription et réinitialisation du mot de passe).
 * <p>
 * Utilise Brevo SMTP (configuré dans {@code application.yml} via la variable {@code BREVO_SMTP_KEY}).
 * Les emails sont rendus en HTML avec Thymeleaf (templates dans {@code src/main/resources/templates/email/}).
 * </p>
 */
@Service
@RequiredArgsConstructor
@Slf4j
@SuppressWarnings("null") // Suppression des warnings de nullabilité pour les champs injectés et les variables locales
public class EmailVerificationService {

    private final EmailVerificationTokenRepository tokenRepository;
    private final UserRepository userRepository;
    private final JavaMailSender mailSender;
    private final TemplateEngine templateEngine;
    private final EmailVerificationProperties properties;

    /**
     * Envoie un email de vérification à l'utilisateur.
     * <p>
     * Marque les tokens actifs existants comme utilisés, puis crée un nouveau token
     * et envoie l'email.
     * </p>
     *
     * @param user l'utilisateur à qui envoyer l'email
     */
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
        sendHtmlEmail(user.getEmail(), user.getFirstName(), token, "email-verification");
    }

    /**
     * Renvoie l'email de vérification à un utilisateur existant.
     *
     * @param email l'email de l'utilisateur
     * @throws ResourceNotFoundException si aucun utilisateur ne correspond
     */
    @Transactional
    public void resendVerificationEmail(String email) {
        OurUser user = userRepository.findByEmail(email)
                .orElseThrow(() -> new ResourceNotFoundException("User", "email", email));
        sendVerificationEmail(user);
    }

    /**
     * Vérifie l'email d'un utilisateur à partir d'un token.
     *
     * @param token le token de vérification
     * @throws BusinessRuleViolationException si le token est invalide, déjà utilisé ou expiré
     */
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
                .orElseThrow(() -> new ResourceNotFoundException("User", "id",
                        verificationToken.getUserId().toString()));
        user.setEmailVerified(true);
        verificationToken.setUsed(true);
        userRepository.save(user);
        tokenRepository.save(verificationToken);
    }

    /**
     * Envoie un email stylisé de réinitialisation de mot de passe.
     * <p>
     * Appelé par {@link AuthService#forgotPassword(String)}.
     * </p>
     *
     * @param user      l'utilisateur
     * @param resetToken le token de réinitialisation
     */
    public void sendPasswordResetEmail(OurUser user, String resetToken) {
        String resetLink = properties.getFrontendUrl().replace("/verify-email", "/reset-password")
                + "?token=" + resetToken;
        sendHtmlEmail(user.getEmail(), user.getFirstName(), resetLink, "password-reset");
    }

    /**
     * Envoie un email HTML via Thymeleaf.
     *
     * @param to           le destinataire
     * @param firstName    le prénom du destinataire
     * @param link         le lien (vérification ou réinitialisation)
     * @param templateName le nom du template Thymeleaf
     */
    private void sendHtmlEmail(String to, String firstName, String link, String templateName) {
        Context ctx = new Context();
        ctx.setVariable("firstName", firstName != null && !firstName.isBlank() ? firstName : "there");
        if ("password-reset".equals(templateName)) {
            ctx.setVariable("resetLink", link);
        } else {
            ctx.setVariable("verificationLink", link);
            ctx.setVariable("expirationHours", properties.getExpirationHours());
        }

        String htmlBody = templateEngine.process("email/" + templateName, ctx);
        String textBody = "Hi " + ctx.getVariable("firstName") + ",\n\n"
                + ("password-reset".equals(templateName)
                    ? "Reset your password here: " + link
                    : "Verify your email here: " + link)
                + "\n\nIf you did not request this, ignore this email.";

        try {
            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");
            helper.setFrom(properties.getFrom());
            helper.setTo(to);
            helper.setSubject("password-reset".equals(templateName)
                    ? "Reset your PlatePilote password"
                    : "Verify your PlatePilote email");
            helper.setText(textBody, htmlBody);
            mailSender.send(message);
        } catch (MessagingException | MailException ex) {
            log.warn("Unable to send email to {} via sender {}: {}",
                    to, properties.getFrom(), ex.getMessage());
            if (properties.isFailOnSendError()) {
                throw new BusinessRuleViolationException("Unable to send email");
            }
        }
    }
}
