package com.platepilote.platepilote.recommendation.domain.repository;

import com.platepilote.platepilote.recommendation.domain.entity.UserInteraction;
import org.springframework.data.jpa.repository.JpaRepository;
import java.time.Instant;
import java.util.List;
import java.util.UUID;

/**
 * Repository pour l'accès aux données des interactions utilisateur avec les recettes.
 * <p>
 * Les interactions sont utilisées par le moteur de recommandation pour calculer les scores de feedback.
 */
public interface UserInteractionRepository extends JpaRepository<UserInteraction, UUID> {

    /**
     * Récupère les interactions d'un utilisateur depuis une date donnée (période glissante de 120 jours).
     *
     * @param userId    identifiant de l'utilisateur
     * @param createdAt date de début de la période
     * @return liste des interactions trouvées
     */
    List<UserInteraction> findByUserIdAndCreatedAtAfter(UUID userId, Instant createdAt);
}
