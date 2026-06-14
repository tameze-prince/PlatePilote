package com.platepilote.platepilote.authentication.domain.repository;

import com.platepilote.platepilote.authentication.domain.entity.Role;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;
import java.util.UUID;

/**
 * Repository JPA pour l'entité {@link Role}.
 * <p>
 * Fournit les opérations d'accès aux données pour les rôles utilisateur.
 * </p>
 */
public interface RoleRepository extends JpaRepository<Role, UUID> {

    /**
     * Recherche un rôle par son nom.
     *
     * @param name le nom du rôle (ex: {@code ROLE_USER})
     * @return le rôle trouvé, ou vide si inexistant
     */
    Optional<Role> findByName(String name);
}
