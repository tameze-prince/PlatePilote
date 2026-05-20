package com.platepilote.platepilote.common.config;

import com.platepilote.platepilote.authentication.application.config.EmailVerificationProperties;
import org.junit.jupiter.api.Test;
import org.springframework.boot.autoconfigure.mail.MailProperties;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.boot.test.context.runner.ApplicationContextRunner;

import static org.assertj.core.api.Assertions.assertThat;

class EmailConfigurationBindingTest {

    private final ApplicationContextRunner contextRunner = new ApplicationContextRunner()
            .withUserConfiguration(TestConfig.class);

    @Test
    void brevoEnvironmentVariablesBindToSpringMailAndVerificationProperties() {
        contextRunner
                .withPropertyValues(
                        "spring.mail.host=smtp-relay.brevo.com",
                        "spring.mail.port=587",
                        "spring.mail.username=brevo-login@example.com",
                        "spring.mail.password=smtp-key",
                        "app.email.verification.from=PlatePilote <brevo-login@example.com>",
                        "app.email.verification.frontend-url=http://localhost:3000/verify-email",
                        "app.email.verification.expiration-hours=24",
                        "app.email.verification.fail-on-send-error=false")
                .run(context -> {
                    MailProperties mail = context.getBean(MailProperties.class);
                    EmailVerificationProperties verification = context.getBean(EmailVerificationProperties.class);

                    assertThat(mail.getHost()).isEqualTo("smtp-relay.brevo.com");
                    assertThat(mail.getPort()).isEqualTo(587);
                    assertThat(mail.getUsername()).isEqualTo("brevo-login@example.com");
                    assertThat(mail.getPassword()).isEqualTo("smtp-key");
                    assertThat(verification.getFrom()).isEqualTo("PlatePilote <brevo-login@example.com>");
                    assertThat(verification.getFrontendUrl()).isEqualTo("http://localhost:3000/verify-email");
                    assertThat(verification.getExpirationHours()).isEqualTo(24);
                    assertThat(verification.isFailOnSendError()).isFalse();
                });
    }

    @EnableConfigurationProperties({MailProperties.class, EmailVerificationProperties.class})
    static class TestConfig {
    }
}
