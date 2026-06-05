package com.platepilote.platepilote.authentication.application.service;

import com.platepilote.platepilote.authentication.application.dto.AuthenticationResponse;
import com.platepilote.platepilote.authentication.application.dto.LoginRequest;
import com.platepilote.platepilote.authentication.application.dto.OAuth2LoginRequest;
import com.platepilote.platepilote.authentication.application.dto.RegisterRequest;
import com.platepilote.platepilote.authentication.domain.entity.OurUser;
import com.platepilote.platepilote.authentication.domain.entity.RefreshToken;
import com.platepilote.platepilote.authentication.domain.entity.Role;
import com.platepilote.platepilote.authentication.domain.repository.RefreshTokenRepository;
import com.platepilote.platepilote.authentication.domain.repository.RoleRepository;
import com.platepilote.platepilote.authentication.domain.repository.UserRepository;
import com.platepilote.platepilote.common.kernel.BusinessRuleViolationException;
import com.platepilote.platepilote.common.security.JwtService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.time.Instant;
import java.util.HashSet;
import java.util.HexFormat;
import java.util.List;
import java.util.Map;
import java.util.UUID;

/**
 * Service métier pour l'authentification.
 * <p>
 * Gère l'inscription, la connexion, la connexion OAuth2, le rafraîchissement
 * des tokens, la déconnexion et la réinitialisation du mot de passe.
 * </p>
 */
@Service
@RequiredArgsConstructor
@SuppressWarnings("null") // Suppression des warnings de nullabilité pour les champs injectés et les variables locales  
public class AuthService {

    private final UserRepository userRepository;
    private final RefreshTokenRepository refreshTokenRepository;
    private final RoleRepository roleRepository;
    private final PasswordEncoder passwordEncoder;
    private final AuthenticationManager authenticationManager;
    private final JwtService jwtService;
    private final OAuth2IdentityVerifier oAuth2IdentityVerifier;
    private final EmailVerificationService emailVerificationService;

    /**
     * Inscrit un nouvel utilisateur.
     * <p>
     * Vérifie que l'email n'est pas déjà utilisé, hache le mot de passe avec BCrypt,
     * crée l'utilisateur en base, envoie un email de vérification et retourne les tokens JWT.
     * </p>
     *
     * @param request les données d'inscription (prénom, nom, email, mot de passe)
     * @return les tokens JWT d'accès et de rafraîchissement
     * @throws BusinessRuleViolationException si l'email est déjà enregistré
     */
    @Transactional
    public AuthenticationResponse register(RegisterRequest request) {
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new BusinessRuleViolationException("Email already registered");
        }

        Role userRole = roleRepository.findByName("ROLE_USER")
                .orElseThrow(() -> new BusinessRuleViolationException("Default user role is not configured"));

        OurUser user = OurUser.builder()
                .firstName(request.getFirstName())
                .lastName(request.getLastName())
                .email(request.getEmail())
                .passwordHash(passwordEncoder.encode(request.getPassword()))
                .provider("local")
                .emailVerified(false)
                .enabled(true)
                .roles(new HashSet<>(List.of(userRole)))
                .build();

        OurUser savedUser = userRepository.save(user);
        emailVerificationService.sendVerificationEmail(savedUser);

        UserDetails userDetails = userDetails(savedUser);

        String accessToken = jwtService.generateToken(roleClaims(savedUser), userDetails);
        String refreshToken = issueRefreshToken(savedUser, userDetails);

        return AuthenticationResponse.builder()
                .accessToken(accessToken)
                .refreshToken(refreshToken)
                .build();
    }

    /**
     * Authentifie un utilisateur existant.
     * <p>
     * Délégue la validation du mot de passe à Spring Security via {@link AuthenticationManager},
     * puis génère et retourne les tokens JWT.
     * </p>
     *
     * @param request les données de connexion (email, mot de passe)
     * @return les tokens JWT d'accès et de rafraîchissement
     */
    public AuthenticationResponse login(LoginRequest request) {
        authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(request.getEmail(), request.getPassword())
        );

        OurUser user = userRepository.findByEmail(request.getEmail())
                .orElseThrow();

        UserDetails userDetails = userDetails(user);

        String accessToken = jwtService.generateToken(roleClaims(user), userDetails);
        String refreshToken = issueRefreshToken(user, userDetails);

        return AuthenticationResponse.builder()
                .accessToken(accessToken)
                .refreshToken(refreshToken)
                .build();
    }

    /**
     * Connecte un utilisateur via OAuth2.
     * <p>
     * Vérifie le token auprès du fournisseur, crée un nouveau compte ou lie
     * l'identité OAuth2 à un compte existant, puis retourne les tokens JWT.
     * </p>
     *
     * @param request les données de connexion OAuth2
     * @return les tokens JWT d'accès et de rafraîchissement
     * @throws BusinessRuleViolationException si le token est invalide ou l'email manquant
     */
    @Transactional
    public AuthenticationResponse oauth2Login(OAuth2LoginRequest request) {
        OAuth2IdentityVerifier.OAuth2Identity identity = oAuth2IdentityVerifier.verify(
                request.provider(), request.idToken());
        if (identity.email() == null || identity.email().isBlank()) {
            throw new BusinessRuleViolationException("OAuth2 token is missing email");
        }
        if (!identity.emailVerified()) {
            throw new BusinessRuleViolationException("OAuth2 email must be verified");
        }

        Role userRole = roleRepository.findByName("ROLE_USER")
                .orElseThrow(() -> new BusinessRuleViolationException("Default user role is not configured"));

        OurUser user = userRepository.findByProviderIgnoreCaseAndProviderId(identity.provider(), identity.providerId())
                .or(() -> userRepository.findByEmail(identity.email()))
                .map(existing -> linkOAuth2Identity(existing, identity, request))
                .orElseGet(() -> createOAuth2User(identity, request, userRole));

        if (!Boolean.TRUE.equals(user.getEnabled())) {
            throw new BusinessRuleViolationException("User account is disabled");
        }

        OurUser saved = userRepository.save(user);
        UserDetails userDetails = userDetails(saved);
        String accessToken = jwtService.generateToken(roleClaims(saved), userDetails);
        String refreshToken = issueRefreshToken(saved, userDetails);

        return AuthenticationResponse.builder()
                .accessToken(accessToken)
                .refreshToken(refreshToken)
                .build();
    }

    /**
     * Rafraîchit le token d'accès à partir d'un token de rafraîchissement valide.
     * <p>
     * Vérifie que le token de rafraîchissement est valide, non révoqué, non expiré
     * et appartient bien à l'utilisateur, puis révoque l'ancien token et en émet un nouveau.
     * </p>
     *
     * @param refreshToken le token de rafraîchissement
     * @return les nouveaux tokens JWT
     * @throws BusinessRuleViolationException si le token est invalide
     */
    @Transactional
    public AuthenticationResponse refreshToken(String refreshToken) {
        final String email = jwtService.extractUsername(refreshToken);

        if (email == null) {
            throw new BusinessRuleViolationException("Invalid refresh token");
        }

        OurUser user = userRepository.findByEmail(email)
                .orElseThrow(() -> new BusinessRuleViolationException("User not found"));

        if (!Boolean.TRUE.equals(user.getEnabled())) {
            throw new BusinessRuleViolationException("User account is disabled");
        }

        UserDetails userDetails = userDetails(user);

        String tokenHash = hashToken(refreshToken);
        RefreshToken persistedToken = refreshTokenRepository.findByToken(tokenHash)
                .orElseThrow(() -> new BusinessRuleViolationException("Invalid refresh token"));

        boolean revoked = Boolean.TRUE.equals(persistedToken.getRevoked());
        boolean expired = persistedToken.getExpiresAt().isBefore(Instant.now());
        boolean wrongUser = !persistedToken.getUserId().equals(user.getId());

        if (revoked || expired || wrongUser || !jwtService.isTokenValid(refreshToken, userDetails)) {
            throw new BusinessRuleViolationException("Invalid refresh token");
        }

        persistedToken.setRevoked(true);
        refreshTokenRepository.save(persistedToken);

        String newAccessToken = jwtService.generateToken(roleClaims(user), userDetails);
        String newRefreshToken = issueRefreshToken(user, userDetails);

        return AuthenticationResponse.builder()
                .accessToken(newAccessToken)
                .refreshToken(newRefreshToken)
                .build();
    }

    /**
     * Déconnecte l'utilisateur en révoquant un token de rafraîchissement spécifique.
     *
     * @param refreshToken le token de rafraîchissement à révoquer
     */
    @Transactional
    public void logout(String refreshToken) {
        if (refreshToken == null || refreshToken.isBlank()) {
            return;
        }
        String tokenHash = hashToken(refreshToken);
        refreshTokenRepository.findByToken(tokenHash).ifPresent(token -> {
            token.setRevoked(true);
            refreshTokenRepository.save(token);
        });
    }

    /**
     * Déconnecte l'utilisateur de toutes ses sessions en révoquant tous ses tokens actifs.
     *
     * @param userId l'identifiant de l'utilisateur
     */
    @Transactional
    public void logoutAll(UUID userId) {
        refreshTokenRepository.revokeAllActiveForUser(userId);
    }

    /**
     * Initie le processus de réinitialisation du mot de passe.
     * <p>
     * Envoie toujours une réponse de succès pour éviter l'énumération d'emails.
     * Si l'utilisateur existe, un email de réinitialisation est envoyé.
     * </p>
     *
     * @param email l'email du compte
     */
    @Transactional
    public void forgotPassword(String email) {
        userRepository.findByEmail(email).ifPresent(user -> {
            String resetToken = jwtService.generateResetToken(user.getEmail());
            emailVerificationService.sendPasswordResetEmail(user, resetToken);
        });
    }

    /**
     * Réinitialise le mot de passe à l'aide d'un token de réinitialisation valide.
     * <p>
     * Vérifie le token, hache le nouveau mot de passe et révoque tous les tokens
     * de rafraîchissement existants pour des raisons de sécurité.
     * </p>
     *
     * @param token       le token de réinitialisation
     * @param newPassword le nouveau mot de passe
     * @throws BusinessRuleViolationException si le token est invalide ou expiré
     */
    @Transactional
    public void resetPassword(String token, String newPassword) {
        String email = jwtService.extractUsername(token);
        if (email == null) {
            throw new BusinessRuleViolationException("Invalid or expired reset token");
        }

        OurUser user = userRepository.findByEmail(email)
                .orElseThrow(() -> new BusinessRuleViolationException("Invalid or expired reset token"));

        if (!jwtService.isResetTokenValid(token, email)) {
            throw new BusinessRuleViolationException("Invalid or expired reset token");
        }

        user.setPasswordHash(passwordEncoder.encode(newPassword));
        userRepository.save(user);

        refreshTokenRepository.revokeAllActiveForUser(user.getId());
    }

    /**
     * Émet et persiste un nouveau token de rafraîchissement.
     *
     * @param user        l'utilisateur
     * @param userDetails les détails de l'utilisateur pour Spring Security
     * @return le token de rafraîchissement brut
     */
    private String issueRefreshToken(OurUser user, UserDetails userDetails) {
        String refreshToken = jwtService.generateRefreshToken(userDetails);
        refreshTokenRepository.save(RefreshToken.builder()
                .userId(user.getId())
                .token(hashToken(refreshToken))
                .expiresAt(jwtService.extractExpirationInstant(refreshToken))
                .revoked(false)
                .build());
        return refreshToken;
    }

    /**
     * Crée un nouvel utilisateur à partir d'une identité OAuth2.
     *
     * @param identity l'identité OAuth2 vérifiée
     * @param request  la requête OAuth2
     * @param role     le rôle à attribuer
     * @return le nouvel utilisateur
     */
    private OurUser createOAuth2User(OAuth2IdentityVerifier.OAuth2Identity identity,
                                     OAuth2LoginRequest request,
                                     Role userRole) {
        return OurUser.builder()
                .firstName(nameOrFallback(request.firstName(), identity.firstName(), "User"))
                .lastName(nameOrFallback(request.lastName(), identity.lastName(), ""))
                .email(identity.email())
                .passwordHash(null)
                .provider(identity.provider())
                .providerId(identity.providerId())
                .avatarUrl(identity.avatarUrl())
                .emailVerified(true)
                .enabled(true)
                .roles(new HashSet<>(List.of(userRole)))
                .build();
    }

    /**
     * Lie une identité OAuth2 à un compte utilisateur existant.
     *
     * @param user     l'utilisateur existant
     * @param identity l'identité OAuth2 vérifiée
     * @param request  la requête OAuth2
     * @return l'utilisateur mis à jour
     * @throws BusinessRuleViolationException si le compte est déjà lié à une autre identité
     */
    private OurUser linkOAuth2Identity(OurUser user,
                                       OAuth2IdentityVerifier.OAuth2Identity identity,
                                       OAuth2LoginRequest request) {
        boolean sameProvider = identity.provider().equalsIgnoreCase(user.getProvider());
        if (user.getProviderId() != null && sameProvider && !user.getProviderId().equals(identity.providerId())) {
            throw new BusinessRuleViolationException("OAuth2 account is already linked to another identity");
        }
        if (user.getProviderId() == null || sameProvider || "local".equalsIgnoreCase(user.getProvider())) {
            user.setProvider(identity.provider());
            user.setProviderId(identity.providerId());
        }
        user.setEmailVerified(true);
        if (user.getAvatarUrl() == null || user.getAvatarUrl().isBlank()) {
            user.setAvatarUrl(identity.avatarUrl());
        }
        if (request.firstName() != null && !request.firstName().isBlank()) {
            user.setFirstName(request.firstName().trim());
        } else if ((user.getFirstName() == null || user.getFirstName().isBlank()) && identity.firstName() != null) {
            user.setFirstName(identity.firstName());
        }
        if (request.lastName() != null && !request.lastName().isBlank()) {
            user.setLastName(request.lastName().trim());
        } else if ((user.getLastName() == null || user.getLastName().isBlank()) && identity.lastName() != null) {
            user.setLastName(identity.lastName());
        }
        return user;
    }

    /**
     * Retourne une valeur selon la priorité : requête → identité → valeur par défaut.
     *
     * @param requestValue   la valeur de la requête
     * @param identityValue la valeur de l'identité
     * @param fallback       la valeur par défaut
     * @return la meilleure valeur disponible
     */
    private String nameOrFallback(String requestValue, String identityValue, String fallback) {
        if (requestValue != null && !requestValue.isBlank()) {
            return requestValue.trim();
        }
        if (identityValue != null && !identityValue.isBlank()) {
            return identityValue.trim();
        }
        return fallback;
    }

    /**
     * Construit un {@link UserDetails} à partir de l'entité utilisateur.
     *
     * @param user l'utilisateur
     * @return les détails utilisateur pour Spring Security
     */
    private UserDetails userDetails(OurUser user) {
        return new org.springframework.security.core.userdetails.User(
                user.getEmail(),
                user.getPasswordHash() == null ? "{noop}oauth2" : user.getPasswordHash(),
                Boolean.TRUE.equals(user.getEnabled()),
                true,
                true,
                true,
                user.getRoles().stream()
                        .map(Role::getName)
                        .map(SimpleGrantedAuthority::new)
                        .toList()
        );
    }

    /**
     * Hache un token avec SHA-256.
     *
     * @param token le token en clair
     * @return l'empreinte hexadécimale
     */
    private String hashToken(String token) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] hash = digest.digest(token.getBytes(StandardCharsets.UTF_8));
            return HexFormat.of().formatHex(hash);
        } catch (NoSuchAlgorithmException ex) {
            throw new IllegalStateException("SHA-256 is not available", ex);
        }
    }

    /**
     * Construit les revendications de rôles pour le token JWT.
     *
     * @param user l'utilisateur
     * @return une map contenant la liste des rôles
     */
    private Map<String, Object> roleClaims(OurUser user) {
        List<String> roles = user.getRoles().stream()
                .map(Role::getName)
                .toList();
        if (roles.isEmpty()) {
            roles = List.of("ROLE_USER");
        }
        return Map.of("roles", roles);
    }
}
