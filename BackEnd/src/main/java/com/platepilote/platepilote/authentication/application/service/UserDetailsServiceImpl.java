package com.platepilote.platepilote.authentication.application.service;

import com.platepilote.platepilote.authentication.domain.entity.OurUser;
import com.platepilote.platepilote.authentication.domain.entity.Role;
import com.platepilote.platepilote.authentication.domain.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Set;
import java.util.stream.Collectors;

/**
 * Implémentation de {@link UserDetailsService} pour Spring Security.
 * <p>
 * Lors de la connexion, Spring Security appelle {@link #loadUserByUsername(String)}
 * pour charger l'utilisateur depuis la base de données et vérifier le mot de passe.
 * </p>
 */
@Service
@RequiredArgsConstructor
public class UserDetailsServiceImpl implements UserDetailsService {

    private final UserRepository userRepository;

    /**
     * Charge un utilisateur par son email (le {@code username} dans notre système).
     * <p>
     * Appelé par Spring Security lors de l'authentification. Convertit l'entité
     * {@link OurUser} en {@link UserDetails} avec les rôles appropriés.
     * </p>
     *
     * @param email l'email de l'utilisateur
     * @return les détails utilisateur avec identifiants et autorités
     * @throws UsernameNotFoundException si aucun utilisateur ne correspond à cet email
     */
    @Override
    @Transactional(readOnly = true)
    public UserDetails loadUserByUsername(String email) throws UsernameNotFoundException {
        OurUser user = userRepository.findByEmail(email)
                .orElseThrow(() -> new UsernameNotFoundException("User not found with email: " + email));

        Set<SimpleGrantedAuthority> authorities = user.getRoles().stream()
                .map(Role::getName)
                .map(SimpleGrantedAuthority::new)
                .collect(Collectors.toSet());
        if (authorities.isEmpty()) {
            authorities.add(new SimpleGrantedAuthority("ROLE_USER"));
        }

        return new org.springframework.security.core.userdetails.User(
                user.getEmail(),
                user.getPasswordHash() == null ? "{noop}oauth2" : user.getPasswordHash(),
                user.getEnabled(),
                true, true, true,
                authorities
        );
    }
}
