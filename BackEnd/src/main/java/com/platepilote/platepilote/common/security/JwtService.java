package com.platepilote.platepilote.common.security;

/**
 * JWT SERVICE - JSON WEB TOKEN CREATION AND VALIDATION
 * ======================================================
 * 
 * WHAT IT IS:
 * This class handles all JWT (JSON Web Token) operations.
 * 
 * WHAT IS A JWT?
 * A JWT is a compact, URL-safe token that contains user information.
 * Format: "header.payload.signature" (e.g., "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJqb2huIn0.abc123")
 * 
 * HOW JWT WORKS IN THIS APP:
 * 1. User logs in with email/password
 * 2. Server validates credentials and generates a JWT
 * 3. Server sends JWT back to the client (Flutter app)
 * 4. Client includes JWT in every subsequent request (Authorization: Bearer <token>)
 * 5. Server validates the JWT on each request to identify the user
 * 
 * TWO TYPES OF TOKENS:
 * - Access Token: Short-lived (1 hour), used for API requests
 * - Refresh Token: Long-lived (7 days), used to get new access tokens
 * 
 * WHY TWO TOKENS?
 * - If access token is stolen, it expires quickly (1 hour)
 * - Refresh token is stored securely and only used to get new access tokens
 * - If refresh token is compromised, it can be revoked
 */

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.io.Decoders;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Service;

import javax.crypto.SecretKey;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.util.function.Function;

@Service  // Tells Spring: "This is a service bean"
public class JwtService {

    /**
     * Secret key used to sign and verify JWT tokens.
     * Must be kept secret - if someone gets this key, they can forge tokens.
     * In production, this should be a long random string stored in environment variables.
     */
    @Value("${app.jwt.secret}")
    private String secretKey;

    /**
     * Access token expiration time in milliseconds (default: 1 hour = 3,600,000 ms)
     */
    @Value("${app.jwt.expiration}")
    private long jwtExpiration;

    /**
     * Refresh token expiration time in milliseconds (default: 7 days = 604,800,000 ms)
     */
    @Value("${app.jwt.refresh-expiration}")
    private long refreshExpiration;

    /**
     * Extract the username (email) from a JWT token.
     * Used to identify which user the token belongs to.
     */
    public String extractUsername(String token) {
        return extractClaim(token, Claims::getSubject);
    }

    /**
     * Extract any claim from the JWT token using a resolver function.
     * Claims are the data stored inside the token (username, expiration, etc.)
     */
    public <T> T extractClaim(String token, Function<Claims, T> claimsResolver) {
        final Claims claims = extractAllClaims(token);
        return claimsResolver.apply(claims);
    }

    /**
     * Generate a new access token for a user.
     * Called after successful login or registration.
     */
    public String generateToken(UserDetails userDetails) {
        return generateToken(new HashMap<>(), userDetails);
    }

    /**
     * Generate a new access token with additional claims.
     * Claims are extra data you want to store in the token (e.g., user role).
     */
    public String generateToken(Map<String, Object> extraClaims, UserDetails userDetails) {
        return buildToken(extraClaims, userDetails, jwtExpiration);
    }

    /**
     * Generate a refresh token (longer-lived than access token).
     */
    public String generateRefreshToken(UserDetails userDetails) {
        return buildToken(new HashMap<>(), userDetails, refreshExpiration);
    }

    /**
     * Internal method that actually builds the JWT token.
     * Sets the subject (username), issued date, expiration date, and signs it with the secret key.
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
     * Validate a JWT token.
     * Checks that:
     * 1. The username in the token matches the provided user
     * 2. The token hasn't expired
     */
    public boolean isTokenValid(String token, UserDetails userDetails) {
        final String username = extractUsername(token);
        return (username.equals(userDetails.getUsername())) && !isTokenExpired(token);
    }

    /**
     * Check if a token has expired.
     */
    private boolean isTokenExpired(String token) {
        return extractExpiration(token).before(new Date());
    }

    /**
     * Extract the expiration date from a token.
     */
    private Date extractExpiration(String token) {
        return extractClaim(token, Claims::getExpiration);
    }

    /**
     * Extract all claims from a token by parsing and verifying it.
     */
    private Claims extractAllClaims(String token) {
        return Jwts.parser()
                .verifyWith(getSignInKey())
                .build()
                .parseSignedClaims(token)
                .getPayload();
    }

    /**
     * Convert the base64-encoded secret key string into a cryptographic key.
     */
    private SecretKey getSignInKey() {
        byte[] keyBytes = Decoders.BASE64.decode(secretKey);
        return Keys.hmacShaKeyFor(keyBytes);
    }
}
