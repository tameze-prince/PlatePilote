package com.platepilote.platepilote.common.security;

import com.platepilote.platepilote.authentication.domain.entity.OurUser;
import com.platepilote.platepilote.authentication.domain.repository.UserRepository;
import com.platepilote.platepilote.common.kernel.ResourceNotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Component;

import java.util.UUID;

/**
 * Utilitaires de sécurité pour l'application.
 * <p>
 * Permet de récupérer l'identifiant de l'utilisateur courant
 * et de vérifier la propriété d'une ressource.
 * </p>
 */
@Component
@RequiredArgsConstructor
public class SecurityUtils {

    private final UserRepository userRepository;

    /**
     * Récupère l'identifiant UUID de l'utilisateur courant à partir de ses {@link UserDetails}.
     *
     * @param userDetails informations de l'utilisateur authentifié
     * @return identifiant UUID de l'utilisateur
     */
    public UUID getCurrentUserId(UserDetails userDetails) {
        String email = userDetails.getUsername();
        OurUser user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found: " + email));
        return user.getId();
    }

    /**
     * Vérifie que l'utilisateur demandeur est bien le propriétaire de la ressource.
     * <p>
     * Si la vérification échoue, une {@link ResourceNotFoundException} est levée
     * pour éviter de révéler l'existence d'une ressource appartenant à un autre utilisateur.
     * </p>
     *
     * @param resourceOwnerId   identifiant du propriétaire de la ressource
     * @param requestingUserId  identifiant de l'utilisateur demandeur
     * @param resourceType      type de ressource (ex : "Recipe")
     * @param resourceId        identifiant de la ressource
     */
    public void verifyOwnership(UUID resourceOwnerId, UUID requestingUserId, String resourceType, String resourceId) {
        if (!resourceOwnerId.equals(requestingUserId)) {
            throw new ResourceNotFoundException(resourceType, "id", resourceId);
        }
    }
}
