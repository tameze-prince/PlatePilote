package com.platepilote.platepilote.common.security;

/**
 * Service de gestion des jetons JWT ({@code JSON Web Token}).
 * <p>
 * Crée et valide les jetons d'accès (accès API, courte durée) et de rafraîchissement
 * (longue durée, permet d'obtenir un nouveau jeton d'accès).
 * Utilise une clé secrète configurée dans les propriétés de l'application.
 * </p>
 */
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.io.Decoders;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Service;

import javax.crypto.SecretKey;
import java.time.Instant;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.util.function.Function;

@Service
public class JwtService {

    /** Clé secrète pour signer et vérifier les jetons JWT. */
    @Value("${app.jwt.secret}")
    private String secretKey;

    /** Durée de validité du jeton d'accès en millisecondes (défaut : 1 heure). */
    @Value("${app.jwt.expiration}")
    private long jwtExpiration;

    /** Durée de validité du jeton de rafraîchissement en millisecondes (défaut : 7 jours). */
    @Value("${app.jwt.refresh-expiration}")
    private long refreshExpiration;

    /**
     * Extrait le nom d'utilisateur (email) du jeton JWT.
     *
     * @param token jeton JWT
     * @return nom d'utilisateur contenu dans le jeton
     */
    public String extractUsername(String token) {
        return extractClaim(token, Claims::getSubject);
    }

    /**
     * Extrait une information (claim) du jeton JWT via une fonction de résolution.
     *
     * @param token          jeton JWT
     * @param claimsResolver fonction de résolution du claim
     * @param <T>            type du claim
     * @return valeur du claim
     */
    public <T> T extractClaim(String token, Function<Claims, T> claimsResolver) {
        final Claims claims = extractAllClaims(token);
        return claimsResolver.apply(claims);
    }

    /**
     * Génère un nouveau jeton d'accès pour un utilisateur.
     *
     * @param userDetails informations de l'utilisateur
     * @return jeton JWT d'accès
     */
    public String generateToken(UserDetails userDetails) {
        return generateToken(new HashMap<>(), userDetails);
    }

    /**
     * Génère un jeton d'accès avec des claims supplémentaires.
     *
     * @param extraClaims données supplémentaires à inclure
     * @param userDetails informations de l'utilisateur
     * @return jeton JWT d'accès
     */
    public String generateToken(Map<String, Object> extraClaims, UserDetails userDetails) {
        return buildToken(extraClaims, userDetails, jwtExpiration);
    }

    /**
     * Génère un jeton de rafraîchissement (durée de validité plus longue).
     *
     * @param userDetails informations de l'utilisateur
     * @return jeton JWT de rafraîchissement
     */
    public String generateRefreshToken(UserDetails userDetails) {
        return buildToken(new HashMap<>(), userDetails, refreshExpiration);
    }

    /**
     * Construit le jeton JWT avec les claims, la date d'émission, l'expiration et la signature.
     *
     * @param extraClaims claims supplémentaires
     * @param userDetails informations de l'utilisateur
     * @param expiration  durée de validité en ms
     * @return jeton JWT signé
     */
    private String buildToken(Map<String, Object> extraClaims, UserDetails userDetails, long expiration) {
        return Jwts.builder()
                .claims(extraClaims)
                .subject(userDetails.getUsername())
                .issuedAt(new Date(System.currentTimeMillis()))
                .expiration(new Date(System.currentTimeMillis() + expiration))
                .signWith(getSignInKey())
                .compact();
    }

    /**
     * Valide un jeton JWT en vérifiant le nom d'utilisateur et l'expiration.
     *
     * @param token       jeton JWT
     * @param userDetails informations de l'utilisateur attendu
     * @return {@code true} si le jeton est valide
     */
    public boolean isTokenValid(String token, UserDetails userDetails) {
        final String username = extractUsername(token);
        return (username.equals(userDetails.getUsername())) && !isTokenExpired(token);
    }

    /**
     * Vérifie si le jeton a expiré.
     *
     * @param token jeton JWT
     * @return {@code true} si le jeton a expiré
     */
    private boolean isTokenExpired(String token) {
        return extractExpiration(token).before(new Date());
    }

    /**
     * Extrait la date d'expiration du jeton.
     *
     * @param token jeton JWT
     * @return date d'expiration
     */
    private Date extractExpiration(String token) {
        return extractClaim(token, Claims::getExpiration);
    }

    /**
     * Extrait l'Instant d'expiration du jeton.
     *
     * @param token jeton JWT
     * @return instant d'expiration
     */
    public Instant extractExpirationInstant(String token) {
    	return extractExpiration(token).toInstant();
    }

    /**
     * Extrait tous les claims du jeton après vérification de la signature.
     *
     * @param token jeton JWT
     * @return tous les claims du jeton
     */
    private Claims extractAllClaims(String token) {
        return Jwts.parser()
                .verifyWith(getSignInKey())
                .build()
                .parseSignedClaims(token)
                .getPayload();
    }

    /**
     * Génère un jeton de réinitialisation de mot de passe (valable 30 minutes).
     *
     * @param email email de l'utilisateur
     * @return jeton JWT de réinitialisation
     */
    public String generateResetToken(String email) {
        return Jwts.builder()
                .subject(email)
                .issuedAt(new Date(System.currentTimeMillis()))
                .expiration(new Date(System.currentTimeMillis() + 1000 * 60 * 30))
                .signWith(getSignInKey())
                .compact();
    }

    /**
     * Vérifie si un jeton de réinitialisation est valide pour un email donné.
     *
     * @param token jeton JWT de réinitialisation
     * @param email email attendu
     * @return {@code true} si le jeton est valide
     */
    public boolean isResetTokenValid(String token, String email) {
        try {
            return extractUsername(token).equals(email) && !isTokenExpired(token);
        } catch (Exception e) {
            return false;
        }
    }

    /**
     * Convertit la clé secrète base64 en clé cryptographique HMAC-SHA.
     *
     * @return clé secrète HMAC
     */
    private SecretKey getSignInKey() {
        byte[] keyBytes = Decoders.BASE64.decode(secretKey);
        return Keys.hmacShaKeyFor(keyBytes);
    }
}
