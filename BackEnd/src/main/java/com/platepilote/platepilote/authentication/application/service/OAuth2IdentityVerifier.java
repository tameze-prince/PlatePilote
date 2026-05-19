package com.platepilote.platepilote.authentication.application.service;

public interface OAuth2IdentityVerifier {

    OAuth2Identity verify(String provider, String idToken);

    record OAuth2Identity(
            String provider,
            String providerId,
            String email,
            boolean emailVerified,
            String firstName,
            String lastName,
            String avatarUrl
    ) {}
}
