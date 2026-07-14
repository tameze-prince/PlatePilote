package com.platepilote.platepilote.common.security;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.runner.ApplicationContextRunner;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;
import org.springframework.test.context.support.TestPropertySourceUtils;

import java.lang.reflect.Field;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * Verifies that the production JWT wiring refuses to start when
 * {@code app.jwt.secret} is empty or suspiciously short. The Beta APK gate
 * relies on this fail-fast behaviour so that an unconfigured environment
 * cannot ship with a placeholder secret.
 */
class JwtSecretFailFastTest {

    /** 64-char Base64 string with >= 48 bytes of entropy after decoding. */
    private static final String VALID_BASE64_SECRET =
            "Y2hhbmdlLXRoaXMtdG8tYS1sb25nLXNlY3VyZS1rZXktaW4tcHJvZHVjdGlvbi1lbnZpcm9ubWVudC1wbGVhc2U=";

    private final ApplicationContextRunner runner = new ApplicationContextRunner();

    @Test
    void applicationContextRefusesToStartWhenJwtSecretIsBlank() {
        runner
                .withUserConfiguration(JwtService.class)
                .withInitializer(context ->
                        TestPropertySourceUtils.addInlinedPropertiesToEnvironment(
                                (AnnotationConfigApplicationContext) context,
                                "app.jwt.secret=",
                                "app.jwt.expiration=3600000",
                                "app.jwt.refresh-expiration=604800000"))
                .run(context -> {
                    Throwable raised = null;
                    try {
                        context.getBean(JwtService.class);
                    } catch (Throwable t) {
                        raised = t;
                    }
                    assertThat(raised)
                            .as("JwtService must decline to construct with an empty secret.")
                            .isNotNull();
                    assertThat(containsRootMessage(raised,
                            "app.jwt.secret is missing")).isTrue();
                });
    }

    @Test
    void applicationContextRefusesToStartWhenJwtSecretIsTooShort() {
        runner
                .withUserConfiguration(JwtService.class)
                .withInitializer(context ->
                        TestPropertySourceUtils.addInlinedPropertiesToEnvironment(
                                (AnnotationConfigApplicationContext) context,
                                "app.jwt.secret=dG9vc2hvcnQ=",
                                "app.jwt.expiration=3600000",
                                "app.jwt.refresh-expiration=604800000"))
                .run(context -> {
                    Throwable raised = null;
                    try {
                        context.getBean(JwtService.class);
                    } catch (Throwable t) {
                        raised = t;
                    }
                    assertThat(raised)
                            .as("JwtService must decline with a too-short secret.")
                            .isNotNull();
                    assertThat(containsRootMessage(raised,
                            "suspiciously short")).isTrue();
                });
    }

    @Test
    void applicationContextStartsWhenJwtSecretIsPresent() {
        runner
                .withUserConfiguration(JwtService.class)
                .withInitializer(context ->
                        TestPropertySourceUtils.addInlinedPropertiesToEnvironment(
                                (AnnotationConfigApplicationContext) context,
                                "app.jwt.secret=" + VALID_BASE64_SECRET,
                                "app.jwt.expiration=3600000",
                                "app.jwt.refresh-expiration=604800000"))
                .run(context -> {
                    assertThat(context).hasNotFailed();
                    JwtService service = context.getBean(JwtService.class);
                    Field field = JwtService.class.getDeclaredField("secretKey");
                    field.setAccessible(true);
                    assertThat(field.get(service)).isEqualTo(VALID_BASE64_SECRET);
                });
    }

    private static boolean containsRootMessage(Throwable t, String snippet) {
        Throwable cur = t;
        while (cur != null) {
            if (cur.getMessage() != null && cur.getMessage().contains(snippet)) {
                return true;
            }
            cur = cur.getCause();
        }
        return false;
    }
}
