package com.platepilote.platepilote.authentication.presentation;

import com.platepilote.platepilote.authentication.application.dto.AuthenticationResponse;
import com.platepilote.platepilote.authentication.application.service.AuthService;
import com.platepilote.platepilote.authentication.application.service.EmailVerificationService;
import com.platepilote.platepilote.common.security.SecurityUtils;
import org.junit.jupiter.api.Test;
import org.springframework.http.HttpStatus;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

class AuthControllerTest {

    @Test
    void refreshAcceptsRefreshTokenFromRequestBody() {
        AuthService authService = mock(AuthService.class);
        AuthenticationResponse authenticationResponse = mock(AuthenticationResponse.class);
        when(authService.refreshToken("refresh-token-value")).thenReturn(authenticationResponse);

        AuthController controller = new AuthController(
                authService,
                mock(EmailVerificationService.class),
                mock(SecurityUtils.class)
        );

        var response = controller.refresh(
                new AuthController.RefreshTokenRequest("refresh-token-value")
        );

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(response.getBody()).isNotNull();
        verify(authService).refreshToken("refresh-token-value");
    }
}
