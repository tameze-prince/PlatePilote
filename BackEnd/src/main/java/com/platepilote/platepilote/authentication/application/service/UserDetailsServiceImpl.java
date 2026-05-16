package com.platepilote.platepilote.authentication.application.service;

/**
 * USER DETAILS SERVICE IMPL - SPRING SECURITY USER LOADER
 * ========================================================
 * 
 * WHAT IT IS:
 * Implementation of Spring Security's UserDetailsService interface.
 * 
 * WHAT IT DOES:
 * When a user tries to log in, Spring Security calls this service to:
 * 1. Load the user from the database by email
 * 2. Return a UserDetails object that Spring Security can use to verify the password
 * 
 * HOW IT FITS INTO LOGIN FLOW:
 * 1. User sends POST /api/v1/auth/login with email + password
 * 2. AuthController calls AuthService.login()
 * 3. AuthService calls AuthenticationManager.authenticate()
 * 4. AuthenticationManager calls this loadUserByUsername() to get user from DB
 * 5. Spring Security compares the provided password with the stored passwordHash
 * 6. If match -> login successful, JWT generated
 * 7. If no match -> login failed, 401 error returned
 */

import com.platepilote.platepilote.authentication.domain.entity.OurUser;
import com.platepilote.platepilote.authentication.domain.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class UserDetailsServiceImpl implements UserDetailsService {

    private final UserRepository userRepository;

    /**
     * Load user by email (username = email in our system).
     * Called by Spring Security during authentication.
     * 
     * @param email The email address to look up
     * @return UserDetails object with user's credentials and authorities
     * @throws UsernameNotFoundException if no user exists with this email
     */
    @Override
    @Transactional(readOnly = true)  // Read-only transaction for performance
    public UserDetails loadUserByUsername(String email) throws UsernameNotFoundException {
        OurUser user = userRepository.findByEmail(email)
                .orElseThrow(() -> new UsernameNotFoundException("User not found with email: " + email));

        // Convert our OurUser entity to Spring Security's UserDetails format
        return new org.springframework.security.core.userdetails.User(
                user.getEmail(),
                user.getPasswordHash(),
                user.getEnabled(),
                true, true, true,  // accountNonExpired, credentialsNonExpired, accountNonLocked
                List.of(new SimpleGrantedAuthority("ROLE_USER"))  // Default role
        );
    }
}
