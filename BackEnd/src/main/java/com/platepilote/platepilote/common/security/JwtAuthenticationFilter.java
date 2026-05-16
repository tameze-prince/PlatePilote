package com.platepilote.platepilote.common.security;

/**
 * JWT AUTHENTICATION FILTER - INTERCEPTS EVERY HTTP REQUEST
 * ==========================================================
 * 
 * WHAT IT IS:
 * This is a servlet filter that runs BEFORE every HTTP request reaches the controllers.
 * 
 * WHAT IT DOES:
 * 1. Checks if the request has an "Authorization: Bearer <token>" header
 * 2. If yes, extracts the JWT token
 * 3. Validates the token (checks signature, expiration)
 * 4. If valid, sets the authenticated user in Spring Security context
 * 5. If invalid or missing, the request continues (will be rejected by SecurityConfig)
 * 
 * REQUEST FLOW:
 * Client Request -> JwtAuthenticationFilter -> SecurityConfig -> Controller
 * 
 * EXAMPLE:
 * Request: GET /api/v1/pantry/items
 * Header: Authorization: Bearer eyJhbGciOiJIUzI1NiJ9...
 * Filter: Validates token, identifies user as "john@email.com"
 * Controller: Receives request with authenticated user
 */

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.lang.NonNull;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;

@Component  // Tells Spring: "This is a bean that should be auto-detected"
@RequiredArgsConstructor  // Lombok: Generates constructor for final fields
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    private final JwtService jwtService;
    private final UserDetailsService userDetailsService;

    /**
     * This method is called for EVERY HTTP request.
     * It checks for a JWT token and validates it.
     */
    @Override
    protected void doFilterInternal(
            @NonNull HttpServletRequest request,
            @NonNull HttpServletResponse response,
            @NonNull FilterChain filterChain
    ) throws ServletException, IOException {
        
        // Get the Authorization header (e.g., "Bearer eyJhbGciOiJIUzI1NiJ9...")
        final String authHeader = request.getHeader("Authorization");

        // If no header or doesn't start with "Bearer ", skip JWT validation
        // (This might be a public endpoint like /api/v1/auth/login)
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            filterChain.doFilter(request, response);
            return;
        }

        // Extract the JWT token (remove "Bearer " prefix)
        final String jwt = authHeader.substring(7);
        
        // Extract the username (email) from the token
        final String userEmail = jwtService.extractUsername(jwt);

        // If we got a username and the user isn't already authenticated
        if (userEmail != null && SecurityContextHolder.getContext().getAuthentication() == null) {
            // Load the full user details from the database
            UserDetails userDetails = this.userDetailsService.loadUserByUsername(userEmail);
            
            // Verify the token is still valid (not expired, signature matches)
            if (jwtService.isTokenValid(jwt, userDetails)) {
                // Create an authentication token with the user's details and authorities
                UsernamePasswordAuthenticationToken authToken = new UsernamePasswordAuthenticationToken(
                        userDetails,
                        null,  // No password needed - we already validated the JWT
                        userDetails.getAuthorities()  // User's roles/permissions
                );
                
                // Add request details to the authentication token
                authToken.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));
                
                // Set the authentication in Spring Security context
                // This marks the user as authenticated for this request
                SecurityContextHolder.getContext().setAuthentication(authToken);
            }
        }
        
        // Continue the filter chain (pass request to the next filter or controller)
        filterChain.doFilter(request, response);
    }
}
